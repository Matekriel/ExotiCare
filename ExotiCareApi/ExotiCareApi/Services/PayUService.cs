using ExotiCareApi.DTOs;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace ExoticCareAPI.Services
{
    public class PayUService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;

        public PayUService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
        }

        public async Task<string?> GetAccessTokenAsync()
        {
            var clientId = _configuration["PayU:ClientId"];
            var clientSecret = _configuration["PayU:ClientSecret"];

            var request = new HttpRequestMessage(
                HttpMethod.Post,
                "https://secure.snd.payu.com/pl/standard/user/oauth/authorize");

            request.Content = new FormUrlEncodedContent(new[]
            {
                new KeyValuePair<string, string>("grant_type", "client_credentials"),
                new KeyValuePair<string, string>("client_id", clientId!),
                new KeyValuePair<string, string>("client_secret", clientSecret!)
            });

            var response = await _httpClient.SendAsync(request);

            if (!response.IsSuccessStatusCode)
                return null;

            var json = await response.Content.ReadAsStringAsync();

            Console.WriteLine(json);
            Console.WriteLine("--------------------------------");
            Console.WriteLine(response.StatusCode);
            Console.WriteLine(response.Content.Headers.ContentType);

            using var doc = JsonDocument.Parse(json);

            return doc.RootElement
                .GetProperty("access_token")
                .GetString();
        }

        public async Task<PayUOrderResponseDto?> CreateOrderAsync(decimal amount)
        {
            var token = await GetAccessTokenAsync();

            if (string.IsNullOrEmpty(token))
                throw new Exception("Nie udało się pobrać tokenu PayU.");

            var order = new
            {
                notifyUrl = "https://example.com/notify",
                continueUrl = "https://tricycle-tingling-platonic.ngrok-free.dev/api/Payments/payu/return",
                customerIp = "127.0.0.1",
                merchantPosId = _configuration["PayU:PosId"],
                description = "Zakup w ExotiCare",
                currencyCode = "PLN",
                totalAmount = ((int)(amount * 100)).ToString(),

                buyer = new
                {
                    email = "test@example.com",
                    firstName = "Test",
                    lastName = "User",
                    language = "pl"
                },

                products = new[]
                {
            new
            {
                name = "Zamówienie ExotiCare",
                unitPrice = ((int)(amount * 100)).ToString(),
                quantity = "1"
            }
        }
            };

            var request = new HttpRequestMessage(
                HttpMethod.Post,
                "https://secure.snd.payu.com/api/v2_1/orders");

            request.Headers.Authorization =
                new AuthenticationHeaderValue("Bearer", token);

            request.Headers.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/json"));

            request.Content = new StringContent(
                JsonSerializer.Serialize(order),
                Encoding.UTF8,
                "application/json");

            var handler = new HttpClientHandler
            {
                AllowAutoRedirect = false
            };

            using var client = new HttpClient(handler);

            client.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token);

            client.DefaultRequestHeaders.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/json"));

            var response = await client.SendAsync(request);

            var body = await response.Content.ReadAsStringAsync();

            Console.WriteLine("========== PAYU ==========");
            Console.WriteLine($"Status: {response.StatusCode}");

            foreach (var h in response.Headers)
                Console.WriteLine($"{h.Key}: {string.Join(", ", h.Value)}");

            Console.WriteLine("BODY:");
            Console.WriteLine(body);
            Console.WriteLine("==========================");

            if (!response.IsSuccessStatusCode &&
                response.StatusCode != System.Net.HttpStatusCode.Found)
            {
                throw new Exception(body);
            }

            if (string.IsNullOrWhiteSpace(body))
            {
                return new PayUOrderResponseDto
                {
                    OrderId = null,
                    RedirectUri = response.Headers.Location?.ToString()
                };
            }

            using var doc = JsonDocument.Parse(body);

            return new PayUOrderResponseDto
            {
                OrderId = doc.RootElement.GetProperty("orderId").GetString(),
                RedirectUri = doc.RootElement.GetProperty("redirectUri").GetString()
            };
        }
    }
}   