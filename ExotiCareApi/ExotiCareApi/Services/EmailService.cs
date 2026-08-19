using MailKit.Net.Smtp;
using MimeKit;

namespace ExotiCareApi.Services
{
    public class EmailService
    {
        private readonly IConfiguration _configuration;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendResetCode(
            string email,
            string code)
        {
            var host =
                _configuration["EmailSettings:Host"];

            var port =
                int.Parse(
                    _configuration["EmailSettings:Port"]!
                );

            var username =
                _configuration["EmailSettings:Username"];

            var password =
                _configuration["EmailSettings:Password"];

            Console.WriteLine($"SMTP HOST: {host}");
            Console.WriteLine($"SMTP PORT: {port}");
            Console.WriteLine($"SMTP USERNAME: {username}");
            Console.WriteLine($"SMTP PASSWORD LENGTH: {password?.Length}");

            var message = new MimeMessage();

            message.From.Add(
                new MailboxAddress(
                    "ExotiCare",
                    username
                )
            );

            message.To.Add(
                MailboxAddress.Parse(email)
            );

            message.Subject =
                "Kod resetowania hasła - ExotiCare";

            message.Body =
                new TextPart("plain")
                {
                    Text =
                        $"Twój kod resetowania hasła to: {code}\n\n" +
                        "Kod jest ważny przez 10 minut.\n\n" +
                        "Jeżeli nie prosiłeś o zmianę hasła, zignoruj tę wiadomość."
                };

            using var smtp =
                new SmtpClient();

            await smtp.ConnectAsync(
                host,
                port,
                MailKit.Security.SecureSocketOptions.StartTls
            );

            await smtp.AuthenticateAsync(
                username,
                password
            );

            await smtp.SendAsync(message);

            await smtp.DisconnectAsync(true);
        }
    }
}
