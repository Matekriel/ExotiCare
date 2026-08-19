using ExotiCareAPI.Data;
using ExotiCareAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ExotiCareApi.DTOs;
using ExotiCareApi.Services;
using ExotiCareApi.Models;

namespace ExotiCareApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly EmailService _emailService;

        public AuthController(AppDbContext context, IConfiguration configuration, EmailService emailService)
        {
            _context = context;
            _configuration = configuration;
            _emailService = emailService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(User user)
        {
            try
            {
                var existingUser = await _context.Users
                    .FirstOrDefaultAsync(x => x.Email == user.Email);

                if (existingUser != null)
                {
                    return BadRequest("Email already exists");
                }

                user.PasswordHash =
                    BCrypt.Net.BCrypt.HashPassword(user.PasswordHash);

                _context.Users.Add(user);

                await _context.SaveChangesAsync();

                return Ok("User created");
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginRequest loginUser)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x =>
                    x.Email == loginUser.Email);

            if (user == null)
            {
                return BadRequest("Invalid email");
            }

            bool passwordValid =
                BCrypt.Net.BCrypt.Verify(
                    loginUser.PasswordHash,
                    user.PasswordHash
                );

            if (!passwordValid)
            {
                return BadRequest("Invalid password");
            }

            var claims = new[]
            {
            new Claim(
                ClaimTypes.Name,
                user.Username
            ),

            new Claim(
                ClaimTypes.Email,
                user.Email
            ),
            new Claim(
                ClaimTypes.Role,
                user.Role
            ),
            new Claim(
                ClaimTypes.NameIdentifier,
                user.Id.ToString()
            )
        };

            var key =
                new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(
                        _configuration["Jwt:Key"]!
                    )
                );

            var creds =
                new SigningCredentials(
                    key,
                    SecurityAlgorithms.HmacSha256
                );

            var token =
                new JwtSecurityToken(
                    issuer:
                        _configuration["Jwt:Issuer"],

                    audience:
                        _configuration["Jwt:Audience"],

                    claims: claims,

                    expires:
                        DateTime.Now.AddDays(7),

                    signingCredentials: creds
                );

            var jwt =
                new JwtSecurityTokenHandler()
                    .WriteToken(token);

            return Ok(new
            {
                token = jwt,
                username = user.Username,
                id = user.Id,
                role = user.Role,
            });
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(
    ForgotPasswordRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x =>
                    x.Email == request.Email);

            // Celowo nie informujemy, czy email istnieje.
            if (user == null)
            {
                return Ok(
                    "Jeżeli konto istnieje, kod został wysłany."
                );
            }

            // Unieważnienie poprzednich kodów
            var previousTokens =
                await _context.PasswordResetTokens
                    .Where(x =>
                        x.UserId == user.Id &&
                        !x.IsUsed)
                    .ToListAsync();

            foreach (var token in previousTokens)
            {
                token.IsUsed = true;
            }

            // Generowanie kodu 6-cyfrowego
            var random = new Random();

            var code =
                random.Next(100000, 1000000)
                    .ToString();

            var codeHash =
                BCrypt.Net.BCrypt.HashPassword(code);

            var resetToken = new PasswordResetToken
            {
                UserId = user.Id,

                CodeHash = codeHash,

                ExpiresAt =
                    DateTime.UtcNow.AddMinutes(10),

                IsUsed = false,

                CreatedAt = DateTime.UtcNow
            };

            _context.PasswordResetTokens.Add(
                resetToken
            );

            await _context.SaveChangesAsync();

            await _emailService.SendResetCode(
                user.Email,
                code
            );

            return Ok(
                "Jeżeli konto istnieje, kod został wysłany."
            );
        }

        [HttpPost("verify-reset-code")]
        public async Task<IActionResult> VerifyResetCode(
    VerifyResetCodeRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x =>
                    x.Email == request.Email);

            if (user == null)
            {
                return BadRequest(
                    "Nieprawidłowy kod."
                );
            }

            var resetToken =
                await _context.PasswordResetTokens
                    .Where(x =>
                        x.UserId == user.Id &&
                        !x.IsUsed)
                    .OrderByDescending(x => x.CreatedAt)
                    .FirstOrDefaultAsync();

            if (resetToken == null)
            {
                return BadRequest(
                    "Nieprawidłowy lub wygasły kod."
                );
            }

            if (resetToken.ExpiresAt < DateTime.UtcNow)
            {
                return BadRequest(
                    "Kod wygasł. Poproś o nowy kod."
                );
            }

            // Sprawdzenie limitu prób
            if (resetToken.Attempts >= 5)
            {
                resetToken.IsUsed = true;

                await _context.SaveChangesAsync();

                return BadRequest(
                    "Przekroczono limit 5 prób. " +        
                    "Poproś o nowy kod."
                );
            }

            // Zwiększamy liczbę prób
            resetToken.Attempts++;

            bool codeValid =
                BCrypt.Net.BCrypt.Verify(
                    request.Code,
                    resetToken.CodeHash
                );

            if (!codeValid)
            {
                // Jeżeli była to piąta próba
                if (resetToken.Attempts >= 5)
                {
                    resetToken.IsUsed = true;

                    await _context.SaveChangesAsync();

                    return BadRequest(
                        "Nieprawidłowy kod. " +        
                        "Przekroczono limit 5 prób. " +        
                        "Poproś o nowy kod."
                    );
                }

                await _context.SaveChangesAsync();

                int remaining =
                    5 - resetToken.Attempts;

                return BadRequest(
                    $"Nieprawidłowy kod. " +        
                    $"Pozostało prób: {remaining}."
                );
            }

            await _context.SaveChangesAsync();

            return Ok(
                "Kod poprawny."
            );
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword(
    ResetPasswordRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x =>
                    x.Email == request.Email);

            if (user == null)
            {
                return BadRequest(
                    "Nieprawidłowe dane."
                );
            }

            var resetToken =
                await _context.PasswordResetTokens
                    .Where(x =>
                        x.UserId == user.Id &&
                        !x.IsUsed)
                    .OrderByDescending(x => x.CreatedAt)
                    .FirstOrDefaultAsync();

            if (resetToken == null)
            {
                return BadRequest(
                    "Nieprawidłowy kod."
                );
            }

            if (resetToken.ExpiresAt < DateTime.UtcNow)
            {
                return BadRequest(
                    "Kod wygasł."
                );
            }

            bool codeValid =
                BCrypt.Net.BCrypt.Verify(
                    request.Code,
                    resetToken.CodeHash
                );

            if (!codeValid)
            {
                return BadRequest(
                    "Nieprawidłowy kod."
                );
            }

            // Haszowanie nowego hasła
            user.PasswordHash =
                BCrypt.Net.BCrypt.HashPassword(
                    request.NewPassword
                );

            // Kod wykorzystany
            resetToken.IsUsed = true;

            await _context.SaveChangesAsync();

            return Ok(
                "Hasło zostało zmienione."
            );
        }
    }
}
