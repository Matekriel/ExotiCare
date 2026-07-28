namespace ExotiCareAPI.Models
{
    public class User
    {
        public int Id { get; set; }

        public string Username { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }

        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? PhoneNumber { get; set; }
        public string? AddressLine { get; set; }
        public string? PostalCode { get; set; }
        public string? City { get; set; }
        public string Role { get; set; } = "User";
    }
}