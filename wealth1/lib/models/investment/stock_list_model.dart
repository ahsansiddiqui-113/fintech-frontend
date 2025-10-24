class StockMarketListModel {
  final bool? status;
  final String? message;
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;
  final int? nextPage;
  final int? previousPage;
  final bool? hasNextPage;
  final bool? hasPreviousPage;
  final Body? body;

  StockMarketListModel({
    this.status,
    this.message,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
    this.nextPage,
    this.previousPage,
    this.hasNextPage,
    this.hasPreviousPage,
    this.body,
  });

  factory StockMarketListModel.fromJson(Map<String, dynamic> json) =>
      StockMarketListModel(
        status: json["status"],
        message: json["message"],
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
        totalPages: json["totalPages"],
        nextPage: json["nextPage"],
        previousPage: json["previousPage"],
        hasNextPage: json["hasNextPage"],
        hasPreviousPage: json["hasPreviousPage"],
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "total": total,
        "page": page,
        "limit": limit,
        "totalPages": totalPages,
        "nextPage": nextPage,
        "previousPage": previousPage,
        "hasNextPage": hasNextPage,
        "hasPreviousPage": hasPreviousPage,
        "body": body?.toJson(),
      };
}

class Body {
  final List<All>? all;
  final List<All>? trending;
  final List<All>? gainers;
  final List<All>? losers;

  Body({
    this.all,
    this.trending,
    this.gainers,
    this.losers,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        all: json["All"] == null
            ? []
            : List<All>.from(json["All"]!.map((x) => All.fromJson(x))),
        trending: json["Trending"] == null
            ? []
            : List<All>.from(json["Trending"]!.map((x) => All.fromJson(x))),
        gainers: json["Gainers"] == null
            ? []
            : List<All>.from(json["Gainers"]!.map((x) => All.fromJson(x))),
        losers: json["Losers"] == null
            ? []
            : List<All>.from(json["Losers"]!.map((x) => All.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "All":
            all == null ? [] : List<dynamic>.from(all!.map((x) => x.toJson())),
        "Trending": trending == null
            ? []
            : List<dynamic>.from(trending!.map((x) => x.toJson())),
        "Gainers": gainers == null
            ? []
            : List<dynamic>.from(gainers!.map((x) => x.toJson())),
        "Losers": losers == null
            ? []
            : List<dynamic>.from(losers!.map((x) => x.toJson())),
      };
}

class All {
  final String? symbol;
  final String? name;
  final String? icon;
  final double? currentPrice;
  final double? change;
  final String? id;

  All({
    this.symbol,
    this.name,
    this.icon,
    this.currentPrice,
    this.change,
    this.id,
  });

  factory All.fromJson(Map<String, dynamic> json) => All(
        symbol: json["symbol"],
        name: json["name"],
        icon: json["icon"],
        currentPrice: json["current_price"]?.toDouble(),
        change: json["change"]?.toDouble(),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "symbol": symbol,
        "name": name,
        "icon": icon,
        "current_price": currentPrice,
        "change": change,
        "_id": id,
      };
}
