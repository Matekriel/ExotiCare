namespace ExotiCareApi.DTOs
{
    public class VerifyResetCodeRequest
    {
        public string Email { get; set; } = "";
        public string Code { get; set; } = "";
    }
}
