import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/income/add_income_controller.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class IncomeAddedScreen extends StatelessWidget {
  IncomeAddedScreen({super.key});

  // final IncomeAddedController _controller = Get.put(IncomeAddedController());

  final IncomeAddedController _controller = Get.put(IncomeAddedController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Add Income'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If you want to budget using only expenses, then go ahead and skip this step.',
              style: TextStyle(color: Colors.grey, fontSize: 14.0),
            ),
            const SizedBox(height: 24.0),
            _buildFieldHeading('Income Name'),
            _buildTextField(_controller.incomeNameController,hint: "Income Name"),
            const SizedBox(height: 16.0),
            _buildFieldHeading('Income Type'),
            _buildDropdownField(context, ),
            const SizedBox(height: 16.0),
            _buildFieldHeading('Income Amount'),
            _buildTextField(_controller.incomeAmountController, isNumber: true, hint: "Income Amount"),
            const SizedBox(height: 16.0),
            _buildFieldHeading('Payment Date'),
            _buildDateField(context, hint: "Payment Date"),
            // const SizedBox(height: 16.0),
            // _buildFieldHeading('Description (Optional)'),
            // _buildTextArea(_controller.descriptionController),
            // const SizedBox(height: 24.0),
          ],
        ),
      ),
      bottomNavigationBar: buildAddButton(
        title: 'Save',
        onPressed: () {
          _controller.isLoading.value ? null : _controller.postAddIncome();
        },
        //   Container(
        //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        //   width: double.infinity,
        //   height: 45,
        //   child: Obx(() => ElevatedButton(
        //         onPressed:
        //             _controller.isLoading.value ? null : _controller.saveIncome,
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: const Color.fromRGBO(46, 173, 165, 1),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //         ),
        //         child: _controller.isLoading.value
        //             ? const CircularProgressIndicator(color: Colors.white)
        //             : const Text(
        //                 'Save',
        //                 style: TextStyle(fontSize: 18.0, color: Colors.white),
        //               ),
        //       )),
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
        hintText: hint== null ? '' : hint,
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

  Widget _buildDropdownField(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
          value: _controller.selectedIncomeType.value,
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
          items: ['Monthly', 'Weekly', 'Annually'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: _controller.updateIncomeType,
        ));
  }

  Widget _buildDateField(BuildContext context, {String? hint}) {
    return TextField(
      controller: _controller.paymentDateController,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        hintText: hint == null ? '' : hint,
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
          onPressed: () => _controller.selectDate(context),
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 4,
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
          borderSide: const BorderSide(color: Color.fromRGBO(46, 173, 165, 1)),
        ),
      ),
    );
  }
}
