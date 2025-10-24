class BankTotalsResponse {
  final bool status;
  final String message;
  final List<BankInstitution> body;

  BankTotalsResponse({
    required this.status,
    required this.message,
    required this.body,
  });

  factory BankTotalsResponse.fromJson(Map<String, dynamic> json) {
    return BankTotalsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      body: (json['body'] as List<dynamic>?)
              ?.map((e) => BankInstitution.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'body': body.map((e) => e.toJson()).toList(),
      };
}

class BankInstitution {
  final String institutionId;
  final String? logo;
  final String name;
  final double total;
  final String accountNumber;
  final int accountsCount;
  final String itemId;

  BankInstitution({
    required this.institutionId,
    this.logo,
    required this.name,
    required this.total,
    required this.accountNumber,
    required this.accountsCount,
    required this.itemId,
  });

  factory BankInstitution.fromJson(Map<String, dynamic> json) {
    return BankInstitution(
      institutionId: json['institution_id'] as String? ?? '',
      logo: json['logo'] as String?,
      name: json['name'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      accountNumber: json['account_number'] as String? ?? '',
      accountsCount: json['accounts_count'] as int? ?? 0,
      itemId: json['item_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'institution_id': institutionId,
        'logo': logo,
        'name': name,
        'total': total,
        'account_number': accountNumber,
        'accounts_count': accountsCount,
        'item_id': itemId,
      };
}
