class FavoritesData {

  static List<Map<String, dynamic>>
      favoriteItems = [];

  static void addFavorite(
    Map<String, dynamic> product,
  ) {

    bool exists = favoriteItems.any(
      (item) =>
          item["productId"] ==
          product["productId"],
    );

    if (!exists) {

      favoriteItems.add(product);
    }
  }

  static void removeFavorite(
    int productId,
  ) {

    favoriteItems.removeWhere(
      (item) =>
          item["productId"] ==
          productId,
    );
  }

  static bool isFavorite(
    int productId,
  ) {

    return favoriteItems.any(
      (item) =>
          item["productId"] ==
          productId,
    );

  }
  static void setFavorites(
    List<Map<String, dynamic>> items,
  ) {
    favoriteItems = items;
  }
}