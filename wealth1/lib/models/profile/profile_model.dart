class ProfileModel {
  final bool? status;
  final String? message;
  final Body? body;

  ProfileModel({
    this.status,
    this.message,
    this.body,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
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
  final String? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNo;
  final String? dob;
  final String? adress;
  final String? gender;
  final String? martialState;
  final String? profilePic;
  final String? socialLink;

  Body({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNo,
    this.dob,
    this.adress,
    this.gender,
    this.martialState,
    this.profilePic,
    this.socialLink,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        id: json["_id"],
        fullName: json["fullName"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        phoneNo: json["phoneNo"],
        dob: json["dob"],
        adress: json["address"],
        gender: json["gender"],
        martialState: json["maritalState"],
        profilePic: json["profilePic"],
        socialLink: json["socialLink"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "fullName": fullName,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phoneNo": phoneNo,
        "dob": dob,
        "address": adress,
        "gender": gender,
        "martialState": martialState,
        "profilePic": profilePic,
        "socialLink": socialLink,
      };
}
