import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/controller/budget/add_budget_controller.dart';
import 'package:wealthnx/controller/budget/budget_controller.dart';
import 'package:wealthnx/controller/check_plaid_connection/check_plaid_connection_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/transations/transation_receipt.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class AddBudget extends StatelessWidget {
  AddBudget(
      {super.key,
      this.title,
      this.id,
      this.amount,
      this.category,
      this.iconData,
      this.IconColors});

  String? title;
  String? id;
  String? amount;
  String? category;
  IconData? iconData;
  Color? IconColors;

  final AddBudgetController _controller = Get.put(AddBudgetController());

  @override
  Widget build(BuildContext context) {
    final budgetCtrl = Get.find<BudgetController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (amount != null &&
          amount!.isNotEmpty &&
          _controller.budgetAmountController.text.isEmpty) {
        _controller.budgetAmountController.text = amount!;
      }
      if (category != null && category!.isNotEmpty) {
        _controller.selectedIncomeType.value = category!;
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: title),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: buildElevatedButton(),
      ),
      body: SafeArea(
        child: Obx(() {
          final grouped =
              budgetCtrl.getCategoryTransactionsGrouped(category ?? '');

          return ListView(
            padding:
                EdgeInsets.symmetric(horizontal: marginSide(), ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller.budgetAmountController,
                    builder: (context, value, _) {
                      final raw = value.text.trim();
                      final shown = raw.isEmpty ? '0' : raw; // or format it
                      return Text(
                        "Apply \$$shown to all future months",
                        style: const TextStyle(
                          color: Color(0xFF767676),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                  ),
                  Transform.scale(
                    scale: 20 / 28,
                    child: Switch(
                      value: false,
                      onChanged: (bool value) {},
                      activeColor: Colors.grey.shade300,
                      activeTrackColor: Colors.green,
                      inactiveThumbColor: Colors.grey.shade300,
                      inactiveTrackColor: Colors.grey.shade500,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              if (title == 'Add Budget') ...[
                const SizedBox(height: 15),
                _buildFieldHeading('Budget Categories'),
                const SizedBox(height: 4),
                _buildDropdownField(hintText: "Budget Categories"),
              ],
              const SizedBox(height: 15),
              _buildFieldHeading('Budget Amount'),
              const SizedBox(height: 4),
              _buildTextField(_controller.budgetAmountController,
                  isNumber: true, hint: "Budget Amount"),
              const SizedBox(height: 15),
              _buildFieldHeading('Budget Date', color: Color(0xFF868686)),
              const SizedBox(height: 4),
              DateField(
                controller: _controller.budgetDateController,
                onPick: () async {},
              ),
              const SizedBox(height: 15),
              _buildFieldHeading('Budget Category', color: Color(0xFF868686)),
              const SizedBox(height: 4),
              InputCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      ClipOval(
                        child: Container(
                          width: 31,
                          height: 31,
                          decoration: BoxDecoration(
                              color: IconColors, shape: BoxShape.circle),
                          child: Icon(
                              iconData ?? getCategoryIcon(category ?? ''),
                              size: 16,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${category ?? '-'}",
                        style: const TextStyle(
                            color: Color(0xFF9AA0A6),
                            fontSize: 16,
                            fontWeight: FontWeight.w300),
                      ),
                    ]),
                    const Icon(
                      Icons.chevron_right,
                      size: 25,
                      color: Color(0xFF767676),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              _buildFieldHeading('Transaction'),
              const SizedBox(height: 8),
              if (grouped.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0x22FFFFFF), width: 0.5),
                  ),
                  child: const Text(
                    'No transactions in this category.',
                    style: TextStyle(color: Color(0xFF9AA0A6)),
                  ),
                ),
              ] else ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0x22FFFFFF), width: 0.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        for (final entry in grouped.entries) ...[
                          // Loop through each transaction in that group
                          for (int i = 0; i < entry.value.length; i++) ...[
                            if (i > 0)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Divider(
                                  height: 0.5,
                                  thickness: 0.5,
                                  color: Color(0x1FFFFFFF),
                                ),
                              ),
                            Builder(
                              builder: (_) {
                                final txn = entry.value[i];
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => TransationReceipt(
                                          id: txn.id,
                                          name: txn.description,
                                          amount: txn.amount.toString(),
                                          date: txn.date.toString(),
                                          category: txn.category,
                                        ));
                                  },
                                  child: TransactionTile(
                                    title: txn.description ?? '—',
                                    subtitle:formatDateAndTime(txn.date.toString()),
                                        // budgetCtrl.formatDateMdY(txn.date),
                                    amount:
                                        '\$${txn.amount?.toInt().toString() ?? ''}',
                                    leading: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: (txn.logo == null ||
                                                txn.logo!.isEmpty)
                                            ? Image.asset(
                                                'assets/images/defult_logo.png',
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.asset(
                                                        'assets/images/defult_logo.png'),
                                              )
                                            : Image.network(
                                                txn.logo!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.asset(
                                                        'assets/images/expensewallet.png'),
                                                loadingBuilder:
                                                    (context, child, lp) {
                                                  if (lp == null) return child;
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFieldHeading(String title, {Color? color = Colors.white}) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {bool isNumber = false, String? hint}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint == null ? '' : hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x22FFFFFF), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(46, 173, 165, 1)),
        ),
        filled: true,
        fillColor: Colors.black,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField({String? hintText}) {
    return Obx(() => DropdownButtonFormField<String>(
          value: _controller.selectedIncomeType.value,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            hintText: hintText == null ? '' : hintText,
            fillColor: Colors.black,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(width: 0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color.fromRGBO(46, 173, 165, 1)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: AddBudgetController.categories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              _controller.selectedIncomeType.value = newValue;
            }
          },
        ));
  }

  Widget buildElevatedButton() {
    final connectivityController = Get.find<CheckPlaidConnectionController>();
    return Obx(
      () => SizedBox(
        height: 45,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (connectivityController.isConnected.value == true)
              _controller.updateBudget(id, category,
                  int.parse(_controller.budgetAmountController.text));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: connectivityController.isConnected.value == false
                ? Get.context?.gc(AppColor.grey)
                : Get.context?.gc(AppColor.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _labelStyle(BuildContext c) =>
    Theme.of(c).textTheme.bodySmall!.copyWith(
        color: Color(0xFF9AA0A6), fontSize: 10, fontWeight: FontWeight.w300);

TextStyle _valueStyle(BuildContext c) => Theme.of(c)
    .textTheme
    .bodyMedium!
    .copyWith(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400);

class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final Widget? leading;

  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x1FFFFFFF), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          leading ??
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _valueStyle(context)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: _labelStyle(context), overflow: TextOverflow.fade),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(amount,
              style: _valueStyle(context)
                  .copyWith(fontWeight: FontWeight.w400, fontSize: 12)),
        ],
      ),
    );
  }
}

class InputCard extends StatelessWidget {
  final Widget child;

  const InputCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0x22FFFFFF), width: 0.5)),
      child: child,
    );
  }
}

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPick;

  const DateField({super.key, required this.controller, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return InputCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
                controller.text.isEmpty ? 'mm/dd/yyyy' : controller.text,
                style: const TextStyle(
                    color: Color(0xFF767676),
                    fontSize: 16,
                    fontWeight: FontWeight.w300)),
          ),
          const Icon(Icons.calendar_today_rounded,
              size: 16, color: Color(0xFF767676)),
        ],
      ),
    );
  }
}
