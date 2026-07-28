using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ExotiCareApi.Models;
using ExotiCareAPI.Data;

namespace ExotiCareApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FavoritesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FavoritesController(
            AppDbContext context
        )
        {
            _context = context;
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult>
            GetFavorites(int userId)
        {
            var favorites =
                await _context.Favorites

                .Include(f => f.Product)

                .Where(f =>
                    f.UserId == userId
                )

                .ToListAsync();

            return Ok(favorites);
        }

        [HttpPost]
        public async Task<IActionResult>
            AddFavorite(
                Favorite favorite
            )
        {
            bool exists =
                await _context.Favorites
                .AnyAsync(f =>

                    f.UserId ==
                        favorite.UserId

                    &&

                    f.ProductId ==
                        favorite.ProductId
                );

            if (exists)
            {
                return BadRequest(
                    "Już dodano"
                );
            }

            _context.Favorites.Add(
                favorite
            );

            await _context.SaveChangesAsync();

            return Ok(favorite);
        }

        [HttpDelete]
        public async Task<IActionResult>
            RemoveFavorite(
                int userId,
                int productId
            )
        {
            var favorite =
                await _context.Favorites
                .FirstOrDefaultAsync(f =>

                    f.UserId == userId

                    &&

                    f.ProductId == productId
                );

            if (favorite == null)
            {
                return NotFound();
            }

            _context.Favorites.Remove(
                favorite
            );

            await _context.SaveChangesAsync();

            return Ok();
        }
    }
}
