using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using ExotiCareApi.DTOs;

namespace ExotiCareApi.Services
{
    public class PayPalService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;

        public PayPalService(HttpClient httpClient,
                             IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
        }

        public async Task<string> GetAccessTokenAsync()
        {
            var clientId = _configuration["PayPal:ClientId"];
            var secret = _configuration["PayPal:Secret"];
            var baseUrl = _configuration["PayPal:BaseUrl"];

            var auth =
                Convert.ToBase64String(
                    Encoding.UTF8.GetBytes($"{clientId}:{secret}")
                );

            _httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Basic", auth);

            var content =
                new FormUrlEncodedContent(
                    new[]
                    {
                        new KeyValuePair<string,string>(
                            "grant_type",
                            "client_credentials"
                        )
                    });

            var response =
                await _httpClient.PostAsync(
                    $"{baseUrl}/v1/oauth2/token",
                    content);

            response.EnsureSuccessStatusCode();

            var json =
                await response.Content.ReadAsStringAsync();

            using var document =
                JsonDocument.Parse(json);

            return document.RootElement
                           .GetProperty("access_token")
                           .GetString()!;
        }

        public async Task<PayPalOrderResponseDto> CreateOrderAsync(decimal amount)
        {
            var token = await GetAccessTokenAsync();

            var baseUrl = _configuration["PayPal:BaseUrl"];

            _httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token);
            _httpClient.DefaultRequestHeaders.Remove("Prefer");
            _httpClient.DefaultRequestHeaders.Add("Prefer", "return=representation");

            var order = new
            {
                intent = "CAPTURE",

                payment_source = new
                {
                    paypal = new
                    {
                        experience_context = new
                        {
                            return_url = "exoticcare://paypal/success",
                            cancel_url = "exoticcare://paypal/cancel",
                            user_action = "PAY_NOW"
                        }
                    }
                },

                purchase_units = new[]
                {
                    new
                    {
                        amount = new
                        {
                            currency_code = "PLN",
                            value = amount.ToString(
                                "0.00",
                                System.Globalization.CultureInfo.InvariantCulture)
                        }
                    }
                }
            };

            var json = JsonSerializer.Serialize(order);

            var content = new StringContent(
                json,
                Encoding.UTF8,
                "application/json");

            var response = await _httpClient.PostAsync(
                $"{baseUrl}/v2/checkout/orders",
                content);

            //response.EnsureSuccessStatusCode();
            if (!response.IsSuccessStatusCode)
            {
                var error = await response.Content.ReadAsStringAsync();
                throw new Exception(error);
            }

            var responseJson =
                await response.Content.ReadAsStringAsync();

            Console.WriteLine(responseJson);

            var document = JsonNode.Parse(responseJson);

            var links =
                document?["links"]?.AsArray();

            var orderId = document?["id"]?.ToString();

            foreach (var link in links!)
            {
                var rel = link?["rel"]?.ToString();

                if (rel == "approve" || rel == "payer-action")
                {
                    return new PayPalOrderResponseDto
                    {
                        OrderId = orderId!,
                        ApproveUrl = link["href"]!.ToString()
                    };
                }
            }

            throw new Exception("Nie znaleziono linku approve.");
        }

        public async Task<bool> CaptureOrderAsync(string orderId)
        {
            var token = await GetAccessTokenAsync();

            var baseUrl = _configuration["PayPal:BaseUrl"];

            _httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token);

            var response = await _httpClient.PostAsync(
                $"{baseUrl}/v2/checkout/orders/{orderId}/capture",
                new StringContent("", Encoding.UTF8, "application/json"));

            if (!response.IsSuccessStatusCode)
                return false;

            var json = await response.Content.ReadAsStringAsync();

            using var document = JsonDocument.Parse(json);

            var status = document.RootElement
                .GetProperty("status")
                .GetString();

            return status == "COMPLETED";
        }
    }
}