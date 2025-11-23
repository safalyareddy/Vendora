class Product {
  String id;
  String name;
  String category;
  String description;
  double price;
  int moq;
  int stock;
  bool negotiable;
  List<String> images;
  String? sellerId;

  /// slab pricing: list of [minQty, maxQty, pricePerUnit]
  List<Map<String, dynamic>> slabPricing;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.moq,
    required this.stock,
    this.sellerId,
    this.negotiable = true,
    List<String>? images,
    List<Map<String, dynamic>>? slabPricing,
  }) : images = images ?? [],
       slabPricing = slabPricing ?? [];

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? price,
    int? moq,
    int? stock,
    String? sellerId,
    bool? negotiable,
    List<String>? images,
    List<Map<String, dynamic>>? slabPricing,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      moq: moq ?? this.moq,
      stock: stock ?? this.stock,
      sellerId: sellerId ?? this.sellerId,
      negotiable: negotiable ?? this.negotiable,
      images: images ?? List.from(this.images),
      slabPricing: slabPricing ?? List.from(this.slabPricing),
    );
  }
}
