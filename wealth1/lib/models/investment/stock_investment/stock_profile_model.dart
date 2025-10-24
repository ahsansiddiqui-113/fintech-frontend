class CompanyProfileModel {
  final String? symbol;
  final double? price;
  final double? marketCap;
  final dynamic beta;
  final double? lastDividend;
  final String? range;
  final double? change;
  final double? changePercentage;
  final double? volume;
  final double? averageVolume;
  final String? companyName;
  final String? currency;
  final String? cik;
  final String? isin;
  final String? cusip;
  final String? exchangeFullName;
  final String? exchange;
  final String? industry;
  final String? website;
  final String? description;
  final String? ceo;
  final String? sector;
  final String? country;
  final String? fullTimeEmployees;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String? image;
  final DateTime? ipoDate;
  final bool? defaultImage;
  final bool? isEtf;
  final bool? isActivelyTrading;
  final bool? isAdr;
  final bool? isFund;

  CompanyProfileModel({
    this.symbol,
    this.price,
    this.marketCap,
    this.beta,
    this.lastDividend,
    this.range,
    this.change,
    this.changePercentage,
    this.volume,
    this.averageVolume,
    this.companyName,
    this.currency,
    this.cik,
    this.isin,
    this.cusip,
    this.exchangeFullName,
    this.exchange,
    this.industry,
    this.website,
    this.description,
    this.ceo,
    this.sector,
    this.country,
    this.fullTimeEmployees,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.image,
    this.ipoDate,
    this.defaultImage,
    this.isEtf,
    this.isActivelyTrading,
    this.isAdr,
    this.isFund,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) =>
      CompanyProfileModel(
        symbol: json["symbol"],
        price: json["price"] ?? 0.0,
        marketCap: json["marketCap"] ?? 0.0,
        beta: json["beta"],
        lastDividend: json["lastDividend"] ?? 0.0,
        range: json["range"] ?? '0.0-0.0',
        change: json["change"] ?? 0.0,
        changePercentage: json["changePercentage"] ?? 0.0,
        volume: json["volume"] ?? 0.0,
        averageVolume: json["averageVolume"] ?? 0.0,
        companyName: json["companyName"],
        currency: json["currency"],
        cik: json["cik"],
        isin: json["isin"],
        cusip: json["cusip"],
        exchangeFullName: json["exchangeFullName"],
        exchange: json["exchange"],
        industry: json["industry"],
        website: json["website"],
        description: json["description"],
        ceo: json["ceo"],
        sector: json["sector"],
        country: json["country"],
        fullTimeEmployees: json["fullTimeEmployees"],
        phone: json["phone"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
        zip: json["zip"],
        image: json["image"],
        ipoDate:
            json["ipoDate"] == null ? null : DateTime.parse(json["ipoDate"]),
        defaultImage: json["defaultImage"],
        isEtf: json["isEtf"],
        isActivelyTrading: json["isActivelyTrading"],
        isAdr: json["isAdr"],
        isFund: json["isFund"],
      );

  Map<String, dynamic> toJson() => {
        "symbol": symbol,
        "price": price,
        "marketCap": marketCap,
        "beta": beta,
        "lastDividend": lastDividend,
        "range": range,
        "change": change,
        "changePercentage": changePercentage,
        "volume": volume,
        "averageVolume": averageVolume,
        "companyName": companyName,
        "currency": currency,
        "cik": cik,
        "isin": isin,
        "cusip": cusip,
        "exchangeFullName": exchangeFullName,
        "exchange": exchange,
        "industry": industry,
        "website": website,
        "description": description,
        "ceo": ceo,
        "sector": sector,
        "country": country,
        "fullTimeEmployees": fullTimeEmployees,
        "phone": phone,
        "address": address,
        "city": city,
        "state": state,
        "zip": zip,
        "image": image,
        "ipoDate":
            "${ipoDate!.year.toString().padLeft(4, '0')}-${ipoDate!.month.toString().padLeft(2, '0')}-${ipoDate!.day.toString().padLeft(2, '0')}",
        "defaultImage": defaultImage,
        "isEtf": isEtf,
        "isActivelyTrading": isActivelyTrading,
        "isAdr": isAdr,
        "isFund": isFund,
      };
}
