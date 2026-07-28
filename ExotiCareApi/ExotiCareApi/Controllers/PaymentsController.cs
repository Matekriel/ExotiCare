using ExotiCareApi.Services;
using Microsoft.AspNetCore.Mvc;
using ExotiCareApi.DTOs;

namespace ExotiCareApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController : ControllerBase
    {
        private readonly PayPalService _payPalService;

        public PaymentsController(PayPalService payPalService)
        {
            _payPalService = payPalService;
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