// To parse this JSON data, do
//
//     final signInModel = signInModelFromJson(jsonString);

import 'dart:convert';

SignInModel signInModelFromJson(String str) =>
    SignInModel.fromJson(json.decode(str));

String signInModelToJson(SignInModel data) => json.encode(data.toJson());

class SignInModel {
  final bool? status;
  final String? message;
  final Body? body;

  SignInModel({
    this.status,
    this.message,
    this.body,
  });

  factory SignInModel.fromJson(Map<String, dynamic> json) => SignInModel(
        status: json["status"],
        message: json["message"],
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "body": body?.toJson(),
      };
}

class Body {
  final String? userId;
  final String? name;
  final String? email;
  final String? token;

  Body({
    this.userId,
    this.name,
    this.email,
    this.token,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        userId: json["user_id"],
        name: json["name"],
        email: json["email"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "email": email,
        "token": token,
      };
}
