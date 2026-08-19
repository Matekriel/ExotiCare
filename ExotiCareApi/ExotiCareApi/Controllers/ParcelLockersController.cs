using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ExotiCareAPI.Data;
using ExotiCareAPI.Models;
using ExotiCareApi.Models;
using ExotiCareAPI.Data;

namespace ExoticCareAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ParcelLockersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ParcelLockersController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ParcelLocker>>> GetParcelLockers()
        {
            return await _context.ParcelLockers.ToListAsync();
        }
    }
}