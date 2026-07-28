using ExotiCareAPI.Data;
using ExotiCareApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;

namespace ExotiCareApi.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ProductsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetProducts()
        {
            var products =
                await _context.Products
                    .Select(p => new
                    {
                        p.Id,
                        p.Name,
                        p.Description,
                        p.Price,
                        p.Category,
                        p.Stock,

                        ImageUrl =
                            p.ImageUrl == null
                            ? null
                            : $"http://10.0.2.2:5138/{p.ImageUrl}"
                    })
                    .ToListAsync();

            return Ok(products);
        }

        [HttpPost]
        public async Task<IActionResult> AddProduct([FromForm] ProductCreateDto dto)
        {
            string? imagePath = null;

            if (dto.Image != null)
            {
                var uploadsFolder =
                    Path.Combine(
                        Directory.GetCurrentDirectory(),
                        "wwwroot",
                        "uploads");

                if (!Directory.Exists(
                    uploadsFolder))
                {
                    Directory.CreateDirectory(
                        uploadsFolder);
                }

                var fileName =
                    Guid.NewGuid() +
                    Path.GetExtension(
                        dto.Image.FileName);

                var filePath =
                    Path.Combine(
                        uploadsFolder,
                        fileName);

                using (var stream =
                       new FileStream(
                           filePath,
                           FileMode.Create))
                {
                    await dto.Image.CopyToAsync(
                        stream);
                }

                imagePath =
                    $"uploads/{fileName}";
            }

            var product = new Product
            {
                Name = dto.Name,
                Description = dto.Description,
                Price = dto.Price,
                Category = dto.Category,
                Stock = dto.Stock,
                ImageUrl = imagePath
            };

            _context.Products.Add(product);

            await _context.SaveChangesAsync();

            return Ok(product);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProduct(int id, [FromForm] ProductCreateDto dto)
        {
            var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == id);

            if (product == null)
            {
                return NotFound();
            }

            product.Name = dto.Name;
            product.Description = dto.Description;
            product.Price = dto.Price;
            product.Category = dto.Category;
            product.Stock = dto.Stock;

            if (dto.Image != null)
            {
                var uploadFolder =
                    Path.Combine(
                        Directory.GetCurrentDirectory(),
                        "wwwroot",
                        "uploads");

                var fileName =
                    Guid.NewGuid() +
                    Path.GetExtension(
                        dto.Image.FileName);

                var filePath =
                    Path.Combine(
                        uploadFolder,
                        fileName);

                using (var stream =
                       new FileStream(
                           filePath,
                           FileMode.Create))
                {
                    await dto.Image.CopyToAsync(
                        stream);
                }

                product.ImageUrl =
                    $"uploads/{fileName}";
            }

            await _context.SaveChangesAsync();

            return Ok(product);

        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            var product =
                await _context.Products
                    .FirstOrDefaultAsync(
                        p => p.Id == id);

            if (product == null)
            {
                return NotFound();
            }

            if (!string.IsNullOrEmpty(
                product.ImageUrl))
            {
                var imagePath =
                    Path.Combine(
                        Directory.GetCurrentDirectory(),
                        "wwwroot",
                        product.ImageUrl);

                if (System.IO.File.Exists(
                    imagePath))
                {
                    System.IO.File.Delete(
                        imagePath);
                }
            }

            _context.Products.Remove(product);

            await _context.SaveChangesAsync();

            return Ok();
        }
    }
}
