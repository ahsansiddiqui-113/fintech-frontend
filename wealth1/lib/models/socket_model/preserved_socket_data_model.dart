import 'package:wealthnx/models/socket_model/socket_company_response_model.dart';

class PreservedSocketDataModel {
  String symbol;
  SocketCompanyResponseModel? companyResponse;

  PreservedSocketDataModel({required this.symbol, this.companyResponse});
}
