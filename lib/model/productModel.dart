class ProductModel {
  int id;
  String name;
  String description;
  String imgUrl;
  int supermarketId;
  String feedback;

  ProductModel({
    this.id,
    this.name,
    this.description,
    this.imgUrl,
    this.supermarketId,
    this.feedback
  });

  factory ProductModel.fromJson(Map<String, dynamic> json){
    return ProductModel(
        id: json['product_id'],
        name: json['product_name'],
        description: json['product_description'],
        imgUrl: json['product_image_url'],
        supermarketId: json['supermarket_id'],
        feedback: json['availability']
    );
  }
}