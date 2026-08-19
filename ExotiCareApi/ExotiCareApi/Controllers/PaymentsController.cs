using ExotiCareApi.Services;
using Microsoft.AspNetCore.Mvc;
using ExotiCareApi.DTOs;
using ExoticCareAPI.Services;

namespace ExotiCareApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController : ControllerBase
    {
        private readonly PayPalService _payPalService;
        private readonly PayUService _payUService;

        public PaymentsController(PayPalService payPalService, PayUService payUService)
        {
            _payPalService = payPalService;
            _payUService = payUService;
        }

        [HttpGet("token")]
        public async Task<IActionResult> GetToken()
        {
            var token =
                await _payPalService.GetAccessTokenAsync();

            return Ok(new
            {
                AccessToken = token
            });
        }

        [HttpGet("payu/token")]
        public async Task<IActionResult> GetPayUToken()
        {
            var token = await _payUService.GetAccessTokenAsync();

            if (string.IsNullOrEmpty(token))
            {
                return BadRequest(new
                {
                    message = "Nie udało się pobrać tokenu PayU."
                });
            }

            return Ok(new
            {
                accessToken = token
            });
        }

        [HttpPost("payu/create-order")]
        public async Task<IActionResult> CreatePayUOrder([FromBody] CreatePaymentDto dto)
        {
            var order = await _payUService.CreateOrderAsync(dto.Amount);

            return Ok(order);
        }

        [HttpGet("payu/return")]
        public IActionResult PayUReturn()
        {
            return Redirect("exoticcare://payu/success");
        }

        [HttpPost("create-order")]
        public async Task<IActionResult> CreateOrder(
        [FromBody] CreatePaymentDto dto)
        {
            var payment = await _payPalService.CreateOrderAsync(dto.Amount);

            return Ok(payment);
        }

        [HttpPost("capture-order")]
        public async Task<IActionResult> CaptureOrder(
        [FromBody] CapturePaymentDto dto)
        {
            var success =
                await _payPalService.CaptureOrderAsync(dto.OrderId);

            if (!success)
            {
                return BadRequest(new
                {
                    message = "Płatność nie została zakończona."
                });
            }

            return Ok(new
            {
                message = "Płatność zakończona pomyślnie."
            });
        }
    }
}