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

        [HttpPost("{id}/profile-image")]
        public async Task<IActionResult> UploadProfileImage(
    int id,
    IFormFile image)
        {
            if (image == null || image.Length == 0)
            {
                return BadRequest("Nie wybrano zdjęcia.");
            }

            // Maksymalnie 5 MB
            if (image.Length > 5 * 1024 * 1024)
            {
                return BadRequest("Zdjęcie może mieć maksymalnie 5 MB.");
            }

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Id == id);

            if (user == null)
            {
                return NotFound("Użytkownik nie istnieje.");
            }

            // Sprawdzamy rozszerzenie
            var extension = Path.GetExtension(image.FileName)
                .ToLowerInvariant();

            var allowedExtensions = new[]
            {
        ".jpg",
        ".jpeg",
        ".png",
        ".webp"
    };

            if (!allowedExtensions.Contains(extension))
            {
                return BadRequest(
                    "Dozwolone są tylko zdjęcia JPG, JPEG, PNG oraz WEBP."
                );
            }

            // Folder:
            // wwwroot/uploads/profile
            var uploadsFolder = Path.Combine(
                Directory.GetCurrentDirectory(),
                "wwwroot",
                "uploads",
                "profile"
            );

            Directory.CreateDirectory(uploadsFolder);

            // Usuwamy poprzednie zdjęcie użytkownika
            if (!string.IsNullOrEmpty(user.ProfileImageUrl))
            {
                var oldFileName =
                    Path.GetFileName(user.ProfileImageUrl);

                var oldFilePath = Path.Combine(
                    uploadsFolder,
                    oldFileName
                );

                if (System.IO.File.Exists(oldFilePath))
                {
                    System.IO.File.Delete(oldFilePath);
                }
            }

            // Nazwa pliku = ID użytkownika
            var fileName =
                $"{user.Id}{extension}";

            var filePath = Path.Combine(
                uploadsFolder,
                fileName
            );

            using (var stream = new FileStream(
                filePath,
                FileMode.Create))
            {
                await image.CopyToAsync(stream);
            }

            user.ProfileImageUrl =
                $"/uploads/profile/{fileName}";

            await _context.SaveChangesAsync();

            return Ok(new
            {
                profileImageUrl =
                    user.ProfileImageUrl
            });
        }
    }
}
