class Product {

  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? category;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.category,
    required this.stock,
  });

  factory Product.fromJson(
    Map<String, dynamic> json,
  ) {

    return Product(
      id: json["id"],
      name: json["name"],
      description: json["description"],

      price:
          (json["price"] as num)
              .toDouble(),

      imageUrl: json["imageUrl"],
      category: json["category"],
      stock: json["stock"],
    );
  }
}