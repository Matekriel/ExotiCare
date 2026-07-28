class Review {

  final int id;

  final int productId;

  final int rating;

  final String userName;

  final String comment;

  Review({

    required this.id,

    required this.productId,

    required this.rating,

    required this.userName,

    required this.comment,
  });

  factory Review.fromJson(
    Map<String, dynamic> json,
  ) {

    return Review(

      id: json["id"],

      productId:
          json["productId"],

      rating: json["rating"],

      userName:
          json["userName"],

      comment:
          json["comment"],
    );
  }
}