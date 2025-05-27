class MarketProduct {
  final String title;
  final String location;
  final String price;
  final String unit;
  final String imageUrl;

  MarketProduct({
    required this.title,
    required this.location,
    required this.price,
    required this.unit,
    required this.imageUrl,
  });

factory MarketProduct.fromJson(Map<String, dynamic> json) {
    return MarketProduct(
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      price: json['price'] ?? '',
      unit: json['unit'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  // factory MarketProduct.fromJson(Map<String, dynamic> json) {
  //   return MarketProduct(
  //     title: json['title'],
  //     location: json['location'],
  //     price: json['price'],
  //     unit: json['unit'],
  //     imageUrl: json['imageUrl'],
  //   );
  // }
}
