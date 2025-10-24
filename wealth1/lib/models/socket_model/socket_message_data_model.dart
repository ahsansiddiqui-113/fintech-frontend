import 'dart:convert';

class SocketMessageDataModel {
  int? status;
  String? message;
  Data? data;

  SocketMessageDataModel({
    this.status,
    this.message,
    this.data,
  });

  factory SocketMessageDataModel.fromJson(String str) =>
      SocketMessageDataModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SocketMessageDataModel.fromMap(Map<String, dynamic> json) =>
      SocketMessageDataModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": data?.toMap(),
      };
}

class Data {
  String? socketMessage;
  List<String>? symbols;

  Data({
    this.socketMessage,
    this.symbols,
  });

  factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        socketMessage: json["socketMessage"],
        symbols: json["symbols"] == null
            ? []
            : List<String>.from(json["symbols"]!.map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "socketMessage": socketMessage,
        "symbols":
            symbols == null ? [] : List<dynamic>.from(symbols!.map((x) => x)),
      };
}
