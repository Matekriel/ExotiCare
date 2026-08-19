using Microsoft.EntityFrameworkCore;
using ExotiCareAPI.Models;
using ExotiCareApi.Models;

namespace ExotiCareAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(
            DbContextOptions<AppDbContext> options
        ) : base(options)
        {
        }

        public DbSet<User> Users => Set<User>();
        public DbSet<Product> Products => Set<Product>();
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<Favorite> Favorites { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<ParcelLocker> ParcelLockers { get; set; }
        public DbSet<PasswordResetToken> PasswordResetTokens { get; set; }
    }
}