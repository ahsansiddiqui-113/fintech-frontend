import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/expenses/add_expence_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class AddExpenses extends StatelessWidget {
  final controller = Get.put(AddExpensesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Add Expense'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'If you want to budget using only expenses, then go ahead and skip this step.',
                style: TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              const SizedBox(height: 24.0),
              _buildFieldHeading('Expense Name'),
              _buildTextField(controller.incomeNameController,
                  hint: "Expense Name"),
              const SizedBox(height: 16.0),
              _buildFieldHeading('Expense Type'),
              _buildDropdownField(),
              const SizedBox(height: 16.0),
              _buildFieldHeading('Expense Amount'),
              _buildTextField(controller.incomeAmountController,
                  hint: "Expense Amount", isNumber: true),
              const SizedBox(height: 16.0),
              _buildFieldHeading('Expense Date'),
              _buildDateField(context, hint: "Expense Date"),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildAddButton(
        title: 'Save',
        onPressed: () {
          controller.postAddExpense();
        },
      ),
    );
  }

  Widget _buildDateField(BuildContext context, {String? hint}) {
    return TextField(
      controller: controller.paymentDateController,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint == null ? '' : hint,
        filled: true,
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
          borderSide: const BorderSide(color: Color.fromRGBO(46, 173, 165, 1)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          onPressed: () => controller.selectDate(context),
        ),
      ),
    );
  }

  Widget _buildFieldHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
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
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(46, 173, 165, 1)),
        ),
        filled: true,
        fillColor: Colors.black,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedIncomeType.value,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
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
          items: controller.incomeTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            controller.selectedIncomeType.value = newValue!;
          },
        ));
  }
}
