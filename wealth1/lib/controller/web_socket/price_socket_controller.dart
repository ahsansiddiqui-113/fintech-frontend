import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wealthnx/controller/web_socket/web_socket.dart';
import 'package:wealthnx/models/socket_model/preserved_socket_data_model.dart';
import 'package:wealthnx/models/socket_model/socket_company_response_model.dart';

class PriceSocketController extends GetxController {
  String tag = "PriceSocketController";
  // String sendMsg = "";
  RxString? socketMessage = ''.obs;

  RxList<PreservedSocketDataModel> preservedData =
      <PreservedSocketDataModel>[].obs;

  RxBool gettingSocketMessage = false.obs;
  RxBool connectingWithSocket = false.obs;

  var socketCompanyData = SocketCompanyResponseModel().obs;

  final WebSocketController priceWebSocket = Get.put(WebSocketController());

  @override
  void onInit() {
    Future.delayed(Duration.zero, () {
      startPriceWebSocket();
    });
    super.onInit();
  }

  // getSocketMessage() async {
  //   gettingSocketMessage.value = true;
  //   update();

  //   var response =
  //       await '{"status": 200,"message": "Request responded successfully","data": {"socketMessage”:”33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"BTFH\”}\n34{\”80\”:\”7\”,\”E\”:\”CASE\”,\”S\”:\”EGX30\”}\n33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"CICH\”}\n33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"BINV\”}\n33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"CCAP\”}\n33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"HRHO\”} \"”,"symbols": [“BTFH”,”EGX30”,”CICH”,”BINV”,”CCAP”,”HRHO”] }}';

  //   log('Response: $response');

  //   if (response != null || response == '') {
  //     SocketMessageDataModel res = SocketMessageDataModel.fromJson(response);
  //     preservedData.clear();
  //     res.data?.symbols?.forEach((element) {
  //       preservedData.add(PreservedSocketDataModel(symbol: element));
  //     });
  //     socketMessage?.value = res.data?.socketMessage ?? '';
  //     gettingSocketMessage.value = false;
  //     update();

  //     return socketMessage?.value;
  //   }

  //   gettingSocketMessage.value = false;
  //   update();
  // }

  void startPriceWebSocket() async {
    connectingWithSocket.value = true;
    update();

    // if (socketMessage?.value == null || socketMessage?.value == '') {
    //   socketMessage?.value = getSocketMessage() as String;
    //   if (socketMessage?.value == null) {
    //     showToast("c_socket_message_invalid".tr);
    //     connectingWithSocket.value = false;
    //     return;
    //   }
    // }

    print("listen Line");

    priceWebSocket.onListenStream(onDataReceived: (message) {
      print("Response Entered");
      handleSocketMessage(message);
    }, onConnectionSuccess: () async {
      log("$tag onMessage   ---- Connected");
      // Trigger Auth Message and Socket Message

      print("----Send Message Connection----");

      await priceWebSocket.sendMessage(
          "125{\"AUTHVER\":\"10\",\"LOGINIP\":\"192.168.0.1\",\"CLVER\":\"1.0.0\",\"PDM\":\"40\",\"LAN\":\"EN\",\"METAVER\":\"\",\"UNM\":\"AMILA.UNI\",\"PWD\":\"123456\"} \"");

      await priceWebSocket
          .sendMessage("33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"BTFH\"} \"");
      await priceWebSocket
          .sendMessage("34{\"80\":\"7\",\"E\":\"CASE\",\"S\":\"EGX30\"} \"");
      await priceWebSocket
          .sendMessage("33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"HRHO\"} \"");
      await priceWebSocket
          .sendMessage("33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"CICH\"} \"");
      await priceWebSocket
          .sendMessage("33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"CCAP\"} \"");
      await priceWebSocket
          .sendMessage("33{\"80\":\"0\",\"E\":\"CASE\",\"S\":\"BINV\"} \"");
    });

    priceWebSocket.startWebSocket(
      url: "wss://ir.directfn.com/ws",
      pingMessage: "8{\"0\":0} \"",
      isCustomPingMessage: true,
      activatePing: true,
    );

    connectingWithSocket.value = false;
    update();
  }

  void handleSocketMessage(String message) {
    String jsonString = message.substring(message.indexOf('{'));
    log("$tag onMessage 1  ---- $jsonString");
    try {
      SocketCompanyResponseModel res =
          SocketCompanyResponseModel.fromJson(jsonString);

      log("$tag onMessage 2  ---- $jsonString");
      log("Response Data  ---- ${res.sym}");

      if (res.sym != null) {
        log("$tag onMessage 3  ---- ");

        var preservedItem = preservedData
            .firstWhereOrNull((element) => element.symbol == res.sym);

        if (preservedItem != null) {
          log("$tag onMessage 4  ---- ");

          if (preservedItem.companyResponse?.sym == null) {
            log("sym is Item is not in Company Res Not Present Adding Now");
            preservedItem.companyResponse = res;
          } else {
            log("Company Already Present ${preservedItem.companyResponse?.sym}");
            updateCompanyResponse(preservedItem, res);
          }
        } else {
          log("sym is Item is not in SocketMessageCompanies List");
          preservedData.add(PreservedSocketDataModel(
              symbol: res.sym ?? "", companyResponse: res));
        }
      }

      update();
    } catch (e, s) {
      log(s.toString());
    }
  }

  void updateCompanyResponse(
      PreservedSocketDataModel preservedItem, SocketCompanyResponseModel res) {
    log("Update Company Enter ");

    if (res.ltp != null && res.ltp!.isNotEmpty) {
      double? value = double.tryParse(res.ltp!);
      if (value != null && value != 0) {
        preservedItem.companyResponse?.ltp = res.ltp;
        log("Company Already Present Update Now -- LTP Value ${res.ltp}");
      }
    }
    if (res.chg != null && res.chg!.isNotEmpty) {
      double? value = double.tryParse(res.chg!);
      if (value != null && value != 0) {
        preservedItem.companyResponse?.chg = res.chg;
        log("Company Already Present Update Now -- chg Value ${res.chg}");
      }
    }
    if (res.pctChg != null && res.pctChg!.isNotEmpty) {
      double? value = double.tryParse(res.pctChg!);
      if (value != null && value != 0) {
        preservedItem.companyResponse?.pctChg = res.pctChg;
        log("Company Already Present Update Now -- PCTCHG Value ${res.pctChg}");
      }
    }
    if (res.lutt != null && res.lutt!.isNotEmpty) {
      double? value = double.tryParse(res.lutt!);
      if (value != null && value != 0) {
        preservedItem.companyResponse?.lutt = res.lutt;
        log("Company Already Present Update Now -- lutt Value ${res.lutt}");
      }
    }
    if (res.vol != null && res.vol!.isNotEmpty) {
      double? value = double.tryParse(res.vol!);
      if (value != null && value != 0) {
        preservedItem.companyResponse?.vol = res.vol;
        log("Company Already Present Update Now -- vol Value ${res.vol}");
      }
    }
    if (res.trades != null && res.trades!.isNotEmpty) {
      double? value = double.tryParse(res.trades!);
      if (value != null && value != 0) {
        preservedItem.companyResponse?.trades = res.trades;
        log("Company Already Present Update Now -- trades Value ${res.trades}");
      }
    }
    if (res.cls != null && res.cls!.isNotEmpty) {
      double? value = double.tryParse(res.cls!);
      if (value != null && value != 0) {
        preservedItem.companyResponse?.cls = res.cls;
        log("Company Already Present Update Now -- cls Value ${res.cls}");
      }
    }
    if (res.open != null && res.open!.isNotEmpty) {
      double? value = double.tryParse(res.open!);
      if (value != null && value != 0) {
        preservedItem.companyResponse?.open = res.open;
        log("Company Already Present Update Now -- open Value ${res.open}");
      }
    }

    if (res.tovr != null && res.tovr!.isNotEmpty) {
      double? value = double.tryParse(res.tovr!);
      if (value != null && value != 0) {
        preservedItem.companyResponse?.tovr = res.tovr;
        log("Company Already Present Update Now -- tovr Value ${res.tovr}");
      }
    }

    update();
  }

  Future<void> clearAndFetchLatestData(BuildContext context) async {
    await priceWebSocket.disconnectWebSocket();
    socketMessage?.value = "";
    preservedData.clear();
    startPriceWebSocket();
  }
}
