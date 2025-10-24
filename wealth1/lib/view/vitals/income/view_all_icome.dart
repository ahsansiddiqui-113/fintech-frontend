import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthnx/controller/income/income_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:http/http.dart' as http;
import 'package:wealthnx/models/income/income_model.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class ViewAllIncome extends StatefulWidget {
  ViewAllIncome({super.key, required this.title});

  String? title;

  @override
  State<ViewAllIncome> createState() => _ExpenseTransactionsState();
}

class _ExpenseTransactionsState extends State<ViewAllIncome> {
  final IncomeController controller = Get.put(IncomeController());

  @override
  Widget build(BuildContext context) {
    controller.fetchIncome();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: '${widget.title}'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          ));
        } else {
          final income = controller.income.value?.body;
          final incomeLength = ((income?.incomes?.length ?? 0) > 4)
              ? income?.incomes?.sublist(0, 4).length
              : income?.incomes?.length;

          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    // height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF000000),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                        controller: controller.searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          fillColor: Colors.amber,
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0.5)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(46, 173, 165, 1)),
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search, color: Colors.grey),
                            onPressed: () {},
                          ),
                        ),
                        onChanged: (value) {
                          controller.filterTransactions();
                        }),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0),
                    // height: 200,
                    height: (60 *
                        controller.filteredTransactions.length.toDouble()),
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final incomeasset =
                              controller.filteredTransactions[index];

                          return GestureDetector(
                              onTap: () {
                                Get.to(() => TransationReceipt(
                                      id: incomeasset.id,
                                      name: incomeasset.name,
                                      amount: incomeasset.amount.toString(),
                                      date: incomeasset.createdAt.toString(),
                                      category: incomeasset.type,
                                    ));
                              },
                              child: buildIncomeDetailItem(
                                context,
                                index: index,
                                listtype: 'Income',
                                title: '${incomeasset.name}',
                                amount: '\$${incomeasset.amount?.toInt()}',
                                length: controller.filteredTransactions.length,
                                subtitle: formatDate(
                                    incomeasset.createdAt.toString()),
                                persentage: '',
                                icon: incomeasset.logo ??
                                    ImagePaths.expensewallet,
                              ));
                        }),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildIncomeDetailItem(String title, String amount,
      {String? subtitle, String? persentage, IconData? icon}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon(icon, color: Color.fromRGBO(46, 173, 165, 1)),
              Container(
                width: 32,
                height: 32,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 0.25)),
                child: Image.asset(
                  ImagePaths.dollercur,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 240,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (persentage != null)
                    Text(
                      persentage,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          height: 2,
          thickness: 0.25,
        ),
      ],
    );
  }
}
