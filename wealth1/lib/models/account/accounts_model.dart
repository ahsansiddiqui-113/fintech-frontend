class AccountResponse {
  final bool status;
  final String message;
  final List<Account> body;

  AccountResponse({
    required this.status,
    required this.message,
    required this.body,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) {
    return AccountResponse(
      status: json['status'],
      message: json['message'],
      body: List<Account>.from(json['body'].map((x) => Account.fromJson(x))),
    );
  }
}

class Account {
  final String itemId;
  final String accountId;
  final String bankName;
  final String? bankLogo;
  final String accountNumber;
  final String name;
  final String type;
  final String subtype;
  final double total;

  Account({
    required this.itemId,
    required this.accountId,
    required this.bankName,
    this.bankLogo,
    required this.accountNumber,
    required this.name,
    required this.type,
    required this.subtype,
    required this.total,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      itemId: json['item_id'],
      accountId: json['account_id'],
      bankName: json['bankName'],
      bankLogo: json['bankLogo'],
      accountNumber: json['accountNumber'],
      name: json['name'],
      type: json['type'],
      subtype: json['subtype'],
      total: (json['total'] is int)
          ? (json['total'] as int).toDouble()
          : json['total'],
    );
  }
}
