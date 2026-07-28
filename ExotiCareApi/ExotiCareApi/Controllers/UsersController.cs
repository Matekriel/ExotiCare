using ExotiCareAPI.Data;
using ExotiCareAPI.Models;
using ExotiCareApi.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;

namespace ExotiCareApi.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetUser(int id)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Id == id);

            if (user == null)
            {
                return NotFound();
            }

            return Ok(user);
        }

        [HttpPut("update-profile/{id}")]
        public async Task<IActionResult> UpdateProfile(
    int id,
    UpdateProfileRequest updatedUser
)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Id == id);

            if (user == null)
            {
                return NotFound();
            }

            user.FirstName =
                updatedUser.FirstName;

            user.LastName =
                updatedUser.LastName;

            user.PhoneNumber =
                updatedUser.PhoneNumber;

            user.AddressLine =
                updatedUser.AddressLine;

            user.PostalCode =
                updatedUser.PostalCode;

            user.City =
                updatedUser.City;

            await _context.SaveChangesAsync();

            return Ok("Profil zaktualizowany");
        }
    }
}
