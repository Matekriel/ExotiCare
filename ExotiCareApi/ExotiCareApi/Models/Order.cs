using ExotiCareAPI.Models;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ExotiCareApi.Models
{
    public class Order
    {
        [Key]
        public int Id { get; set; }

        public int UserId { get; set; }

        public decimal TotalPrice { get; set; }

        public string PaymentMethod { get; set; }

        public string DeliveryMethod { get; set; }

        public decimal DeliveryPrice { get; set; }

        public string Status { get; set; } = "Nowe";

        public DateTime CreatedAt { get; set; }

        [ForeignKey("UserId")]
        public User User { get; set; }

        public List<OrderItem> OrderItems { get; set; }
    }
}
