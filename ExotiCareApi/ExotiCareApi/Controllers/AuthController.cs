using ExotiCareAPI.Data;
using ExotiCareAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ExotiCareApi.DTOs;

namespace ExotiCareApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
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
    }
}
