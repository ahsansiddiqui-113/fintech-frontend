class PriceEntry {
  final DateTime? timestamp;
  final double? open;
  final double? high;
  final double? low;
  final double? close;

  PriceEntry({this.timestamp, this.open, this.high, this.low, this.close});

  factory PriceEntry.fromJson(List<dynamic> json) {
    return PriceEntry(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json[0]),
      open: (json[1] as num).toDouble(),
      high: (json[2] as num).toDouble(),
      low: (json[3] as num).toDouble(),
      close: (json[4] as num).toDouble(),
    );
  }
}

// class PriceEntry {
//   final DateTime? timestamp;
//   final double? open;
//   final double? high;
//   final double? low;
//   final double? close;

//   PriceEntry({
//     this.timestamp,
//     this.open,
//     this.high,
//     this.low,
//     this.close,
//   });

//   factory PriceEntry.fromJson(List<dynamic> json) {
//     return PriceEntry(
//       timestamp: DateTime.fromMillisecondsSinceEpoch(json[0]),
//       open: (json[1] as num).toDouble(),
//       high: (json[2] as num).toDouble(),
//       low: (json[3] as num).toDouble(),
//       close: (json[4] as num).toDouble(),
//     );
//   }

//   List<dynamic> toJson() {
//     return [
//       timestamp?.millisecondsSinceEpoch,
//       open,
//       high,
//       low,
//       close,
//     ];
//   }
// }
