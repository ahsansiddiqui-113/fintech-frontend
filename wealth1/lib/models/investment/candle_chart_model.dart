class CryptoCoins {
  final MetaData? metaData;
  final Map<String, TimeSeries5Min>? timeSeries5Min;

  CryptoCoins({
    this.metaData,
    this.timeSeries5Min,
  });

  factory CryptoCoins.fromJson(Map<String, dynamic> json) => CryptoCoins(
        metaData: json["Meta Data"] == null
            ? null
            : MetaData.fromJson(json["Meta Data"]),
        timeSeries5Min: Map.from(json["Time Series (5min)"]!).map((k, v) =>
            MapEntry<String, TimeSeries5Min>(k, TimeSeries5Min.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "Meta Data": metaData?.toJson(),
        "Time Series (5min)": Map.from(timeSeries5Min!)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class MetaData {
  final String? the1Information;
  final String? the2Symbol;
  final DateTime? the3LastRefreshed;
  final String? the4Interval;
  final String? the5OutputSize;
  final String? the6TimeZone;

  MetaData({
    this.the1Information,
    this.the2Symbol,
    this.the3LastRefreshed,
    this.the4Interval,
    this.the5OutputSize,
    this.the6TimeZone,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) => MetaData(
        the1Information: json["1. Information"],
        the2Symbol: json["2. Symbol"],
        the3LastRefreshed: json["3. Last Refreshed"] == null
            ? null
            : DateTime.parse(json["3. Last Refreshed"]),
        the4Interval: json["4. Interval"],
        the5OutputSize: json["5. Output Size"],
        the6TimeZone: json["6. Time Zone"],
      );

  Map<String, dynamic> toJson() => {
        "1. Information": the1Information,
        "2. Symbol": the2Symbol,
        "3. Last Refreshed": the3LastRefreshed?.toIso8601String(),
        "4. Interval": the4Interval,
        "5. Output Size": the5OutputSize,
        "6. Time Zone": the6TimeZone,
      };
}

class TimeSeries5Min {
  final String? the1Open;
  final String? the2High;
  final String? the3Low;
  final String? the4Close;
  final String? the5Volume;

  TimeSeries5Min({
    this.the1Open,
    this.the2High,
    this.the3Low,
    this.the4Close,
    this.the5Volume,
  });

  factory TimeSeries5Min.fromJson(Map<String, dynamic> json) => TimeSeries5Min(
        the1Open: json["1. open"],
        the2High: json["2. high"],
        the3Low: json["3. low"],
        the4Close: json["4. close"],
        the5Volume: json["5. volume"],
      );

  Map<String, dynamic> toJson() => {
        "1. open": the1Open,
        "2. high": the2High,
        "3. low": the3Low,
        "4. close": the4Close,
        "5. volume": the5Volume,
      };
}
