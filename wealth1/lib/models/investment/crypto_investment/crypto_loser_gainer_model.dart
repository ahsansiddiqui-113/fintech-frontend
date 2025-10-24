class CryptoLoserGainer {
  final List<Top>? topGainers;
  final List<Top>? topLosers;

  CryptoLoserGainer({
    this.topGainers,
    this.topLosers,
  });

  factory CryptoLoserGainer.fromJson(Map<String, dynamic> json) =>
      CryptoLoserGainer(
        topGainers: json["top_gainers"] == null
            ? []
            : List<Top>.from(json["top_gainers"]!.map((x) => Top.fromJson(x))),
        topLosers: json["top_losers"] == null
            ? []
            : List<Top>.from(json["top_losers"]!.map((x) => Top.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "top_gainers": topGainers == null
            ? []
            : List<dynamic>.from(topGainers!.map((x) => x.toJson())),
        "top_losers": topLosers == null
            ? []
            : List<dynamic>.from(topLosers!.map((x) => x.toJson())),
      };
}

class Top {
  final String? id;
  final String? symbol;
  final String? name;
  final String? image;
  final int? marketCapRank;
  final double? usd;
  final double? usd24HVol;
  final double? usd24HChange;

  Top({
    this.id,
    this.symbol,
    this.name,
    this.image,
    this.marketCapRank,
    this.usd,
    this.usd24HVol,
    this.usd24HChange,
  });

  factory Top.fromJson(Map<String, dynamic> json) => Top(
        id: json["id"],
        symbol: json["symbol"],
        name: json["name"],
        image: json["image"],
        marketCapRank: json["market_cap_rank"],
        usd: json["usd"]?.toDouble(),
        usd24HVol: json["usd_24h_vol"]?.toDouble(),
        usd24HChange: json["usd_24h_change"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "image": image,
        "market_cap_rank": marketCapRank,
        "usd": usd,
        "usd_24h_vol": usd24HVol,
        "usd_24h_change": usd24HChange,
      };
}
