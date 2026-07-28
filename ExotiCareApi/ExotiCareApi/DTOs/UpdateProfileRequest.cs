namespace ExotiCareApi.DTOs
{
    public class UpdateProfileRequest
    {
        public string? FirstName { get; set; }

        public string? LastName { get; set; }

        public string? PhoneNumber { get; set; }

        public string? AddressLine { get; set; }

        public string? PostalCode { get; set; }

        public string? City { get; set; }
    }
}
