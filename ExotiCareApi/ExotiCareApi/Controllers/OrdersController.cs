using Microsoft.AspNetCore.Mvc;
using ExotiCareApi.Models;
using ExotiCareApi.DTOs;
using ExotiCareAPI.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;

namespace ExotiCareApi.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public OrdersController(
            AppDbContext context
        )
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllOrders()
        {
            var orders = await _context.Orders

                .Include(o => o.User)

                .OrderByDescending(o => o.Id)

                .Select(o => new
                {
                    o.Id,
                    o.TotalPrice,
                    o.Status,
                    o.CreatedAt,

                    UserName =
                        o.User.Username,

                    CustomerName =
                        o.User.FirstName + " " +
                        o.User.LastName
                })

                .ToListAsync();

            return Ok(orders);
        }

        [HttpGet("user/{userId}")]

        public async Task<IActionResult> GetUserOrders(int userId)
        {
            var orders = await _context.Orders

                .Where(o => o.UserId == userId)

                .Include(o => o.User)

                .Include(o => o.OrderItems)

                .ThenInclude(oi => oi.Product)

                .OrderByDescending(o => o.Id)

                .Select(o => new
                {
                    o.Id,
                    o.TotalPrice,
                    o.PaymentMethod,
                    o.DeliveryMethod,
                    o.Status,

                    User = new
                    {
                        o.User.FirstName,
                        o.User.LastName,
                        o.User.PhoneNumber,
                        o.User.Email,
                        o.User.AddressLine,
                        o.User.PostalCode,
                        o.User.City
                    },

                    OrderItems =
                        o.OrderItems.Select(oi => new
                        {
                            productName =
                                oi.Product.Name,

                            oi.Quantity
                        })
                })

                .ToListAsync();

            return Ok(orders);
        }

        [HttpPost]
        public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
        {
            var order = new Order
            {
                UserId = dto.UserId,

                TotalPrice = dto.TotalPrice,

                PaymentMethod =
                    dto.PaymentMethod,

                DeliveryMethod =
                    dto.DeliveryMethod,

                DeliveryPrice =
                    dto.DeliveryPrice,

                Status = "Nowe",

                CreatedAt = DateTime.Now,

                OrderItems =
                    new List<OrderItem>()
            };

            foreach (var item in dto.Items)
            {
                var product = await _context.Products
                    .FindAsync(item.ProductId);

                if (product == null)
                {
                    return BadRequest(
                        $"Produkt o ID {item.ProductId} nie istnieje"
                    );
                }

                if (product.Stock < item.Quantity)
                {
                    return BadRequest(
                        $"Brak wystarczającej ilości produktu: {product.Name}"
                    );
                }

                product.Stock -= item.Quantity;

                var orderItem = new OrderItem
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    Price = item.Price,
                };

                order.OrderItems.Add(orderItem);
            }

            _context.Orders.Add(order);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message =
                    "Zamówienie zapisane",
                order.Id
            });
        }

        [HttpPut("cancel/{id}")]
        public async Task<IActionResult> CancelOrder(int id)
        {
            var order = await _context.Orders

                .Include(o => o.OrderItems)

                .ThenInclude(oi => oi.Product)

                .FirstOrDefaultAsync(o => o.Id == id);

            if (order == null)
            {
                return NotFound();
            }

            if (order.Status != "Nowe")
            {
                return BadRequest(
                    "Nie można anulować tego zamówienia"
                );
            }

            order.Status = "Anulowane";

            foreach (var item in order.OrderItems)
            {
                item.Product.Stock += item.Quantity;
            }

            await _context.SaveChangesAsync();

            return Ok(
                "Zamówienie anulowane"
            );
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetOrderDetails(int id)
        {
            var order = await _context.Orders

                .Include(o => o.User)

                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)

                .FirstOrDefaultAsync(o => o.Id == id);

            if (order == null)
            {
                return NotFound();
            }

            return Ok(new
            {
                order.Id,
                order.TotalPrice,
                order.PaymentMethod,
                order.DeliveryMethod,
                order.DeliveryPrice,
                order.Status,
                order.CreatedAt,

                User = new
                {
                    order.User.FirstName,
                    order.User.LastName,
                    order.User.Email,
                    order.User.PhoneNumber,
                    order.User.AddressLine,
                    order.User.PostalCode,
                    order.User.City
                },

                Items = order.OrderItems.Select(i => new
                {
                    i.ProductId,
                    ProductName = i.Product.Name,
                    i.Quantity,
                    i.Price
                })
            });
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, UpdateOrderStatusDto dto)
        {
            var order =
                await _context.Orders
                .FirstOrDefaultAsync(o => o.Id == id);

            if (order == null)
            {
                return NotFound();
            }

            order.Status = dto.Status;

            await _context.SaveChangesAsync();

            return Ok();
        }
    }
}
