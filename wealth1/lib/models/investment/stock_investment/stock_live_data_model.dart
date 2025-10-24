class CoinDetailModel {
  final String? symbol;
  final List<Historical>? historical;

  CoinDetailModel({
    this.symbol,
    this.historical,
  });

  factory CoinDetailModel.fromJson(Map<String, dynamic> json) =>
      CoinDetailModel(
        symbol: json["symbol"],
        historical: json["historical"] == null
            ? []
            : List<Historical>.from(
                json["historical"]!.map((x) => Historical.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "symbol": symbol,
        "historical": historical == null
            ? []
            : List<dynamic>.from(historical!.map((x) => x.toJson())),
      };
}

class Historical {
  final DateTime? date;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final double? adjClose;
  final int? volume;
  final int? unadjustedVolume;
  final double? change;
  final double? changePercent;
  final double? vwap;
  final String? label;
  final double? changeOverTime;

  Historical({
    this.date,
    this.open,
    this.high,
    this.low,
    this.close,
    this.adjClose,
    this.volume,
    this.unadjustedVolume,
    this.change,
    this.changePercent,
    this.vwap,
    this.label,
    this.changeOverTime,
  });

  factory Historical.fromJson(Map<String, dynamic> json) => Historical(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        open: json["open"]?.toDouble(),
        high: json["high"]?.toDouble(),
        low: json["low"]?.toDouble(),
        close: json["close"]?.toDouble(),
        adjClose: json["adjClose"]?.toDouble(),
        volume: json["volume"],
        unadjustedVolume: json["unadjustedVolume"],
        change: json["change"]?.toDouble(),
        changePercent: json["changePercent"]?.toDouble(),
        vwap: json["vwap"]?.toDouble(),
        label: json["label"],
        changeOverTime: json["changeOverTime"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "open": open,
        "high": high,
        "low": low,
        "close": close,
        "adjClose": adjClose,
        "volume": volume,
        "unadjustedVolume": unadjustedVolume,
        "change": change,
        "changePercent": changePercent,
        "vwap": vwap,
        "label": label,
        "changeOverTime": changeOverTime,
      };
}
