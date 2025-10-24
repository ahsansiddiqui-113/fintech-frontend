class CryptoNewsModel {
  String? symbol;
  String? publishedDate;
  String? publisher;
  String? title;
  String? image;
  String? site;
  String? text;
  String? url;

  CryptoNewsModel(
      {this.symbol,
      this.publishedDate,
      this.publisher,
      this.title,
      this.image,
      this.site,
      this.text,
      this.url});

  CryptoNewsModel.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'];
    publishedDate = json['publishedDate'];
    publisher = json['publisher'];
    title = json['title'];
    image = json['image'];
    site = json['site'];
    text = json['text'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['symbol'] = this.symbol;
    data['publishedDate'] = this.publishedDate;
    data['publisher'] = this.publisher;
    data['title'] = this.title;
    data['image'] = this.image;
    data['site'] = this.site;
    data['text'] = this.text;
    data['url'] = this.url;
    return data;
  }
}
