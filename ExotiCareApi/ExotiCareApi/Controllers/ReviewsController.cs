using ExotiCareAPI.Data;
using ExotiCareApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;

namespace ExotiCareApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReviewsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ReviewsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("{productId}")]
        public async Task<IActionResult> GetReviews(
            int productId)
        {
            var reviews =
                await _context.Reviews
                    .Where(r =>
                        r.ProductId == productId)
                    .OrderByDescending(r =>
                        r.CreatedAt)
                    .ToListAsync();

            return Ok(reviews);
        }

        [HttpGet]
        public async Task<IActionResult> GetAllReviews()
        {
            var reviews = await _context.Reviews

                .Join(
                    _context.Products,

                    review => review.ProductId,
                    product => product.Id,

                    (review, product) => new
                    {
                        review.Id,
                        review.UserName,
                        review.Rating,
                        review.Comment,
                        review.CreatedAt,
                        review.ProductId,

                        ProductName =
                            product.Name
                    })

                .OrderByDescending(r => r.CreatedAt)

                .ToListAsync();

            return Ok(reviews);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReview(int id)
        {
            var review =
                await _context.Reviews
                    .FirstOrDefaultAsync(
                        r => r.Id == id);

            if (review == null)
            {
                return NotFound();
            }

            _context.Reviews.Remove(review);

            await _context.SaveChangesAsync();

            return Ok();
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> AddReview(
            Review review)
        {
            review.CreatedAt = DateTime.Now;

            _context.Reviews.Add(review);

            await _context.SaveChangesAsync();

            return Ok(review);
        }
    }
}
