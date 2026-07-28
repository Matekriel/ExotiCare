class CartData {

  static List<Map<String, dynamic>>
      cartItems = [];

  static void addProduct(
    Map<String, dynamic> product,
  ) {

    int existingIndex =
        cartItems.indexWhere(

      (item) =>

          item["productId"] ==
          product["productId"],
    );

    if (existingIndex != -1) {

      cartItems[existingIndex]
          ["quantity"]++;

    } else {

      cartItems.add(product);
    }
  }

  static void increaseQuantity(
    int index,
  ) {

    cartItems[index]["quantity"]++;
  }

  static void decreaseQuantity(
    int index,
  ) {

    if (cartItems[index]["quantity"] > 1) {

      cartItems[index]["quantity"]--;

    } else {

      cartItems.removeAt(index);
    }
  }

  static void removeProduct(
    int index,
  ) {

    cartItems.removeAt(index);
  }

  static void clearCart() {

    cartItems.clear();
  }
}