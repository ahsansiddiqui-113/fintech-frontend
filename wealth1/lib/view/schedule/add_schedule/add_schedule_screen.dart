import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/schedule/add_schedule/add_schedule_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class AddScheduleScreen extends StatelessWidget {
  const AddScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddScheduleController());

    return Scaffold(
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            customAppBar(title: "Add Schedule"),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Title
                    const Text("Title", style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: controller.titleController,
                      hint: "Enter title",
                      validator: (v) =>
                      v == null || v.isEmpty
                          ? "Please enter title"
                          : null,
                    ),
                    const SizedBox(height: 21),

                    /// Amount
                    const Text("Amount"),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: controller.amountController,
                      hint: "\$1234",
                      keyboardType: TextInputType.number,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 21),

                    /// Date
                    const Text("Date", style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: controller.dateController,
                      hint: "Select Date",
                      readOnly: true,
                      showCalendarIcon: true,
                      onCalendarTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          controller.setDate(picked);
                        }
                      },
                      validator: (v) =>
                      v == null || v.isEmpty
                          ? "Please select date"
                          : null,
                    ),
                    addHeight(21),

                    /// Frequency
                    const Text("Frequency", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 12),
                    Obx(() {
                      return _PickerFormField<RecurrenceInterval>(
                        value: controller.recurrence.value,
                        items: RecurrenceInterval.values,
                        labelOf: (e) => e.label,
                        onChanged: (v) => controller.setRecurrence(v),
                        validator: (v) =>  null,
                        decoration: _inputDecoration(),
                        placeholder: 'Select frequency',
                      );
                    }),
                    const SizedBox(height: 21),

                    /// Category
                    const Text("Category", style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 12),
                    Obx(() {
                      return _PickerFormField<Category>(
                        value: controller.selectedCategory.value,
                        items: Category.values,
                        labelOf: (c) => c.label,
                        onChanged: (v) => controller.setCategory(v),
                        validator: (v) =>  null,
                        decoration: _inputDecoration(),
                        placeholder: 'Select category',
                      );
                    }),

                    const SizedBox(height: 21),
                    /// Description
                    const Text("Description", style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: controller.descriptionController,
                      hint: "Add details for this schedule…",
                      keyboardType: TextInputType.multiline,
                      validator: (v) => null,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 21),

                    /// Actions
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildAddButton(
        title: 'Save',
        onPressed: () async{
          final ok = await controller.saveSchedule();
          if (ok) {
            // Pop this Add screen
            Get.back();
            // Show success on the previous screen (stable context)
            Get.snackbar(
              'Success',
              'Schedule added successfully',
              backgroundColor: Get.context!.gc(AppColor.primary),
              colorText: Get.context!.gc(AppColor.white),
              duration: const Duration(seconds: 2),
            );
          }

        },
      ),
    );
  }


  /// Reusable TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    bool showCalendarIcon = false,
    VoidCallback? onCalendarTap,
    int maxLines = 1,
  }) {
    // If it's a date field, use onCalendarTap (fallback to onTap) for the WHOLE field
    final effectiveOnTap = showCalendarIcon ? (onCalendarTap ?? onTap) : onTap;
    final isPickerField = showCalendarIcon && effectiveOnTap != null;

    return TextFormField(
      controller: controller,
      readOnly: readOnly || isPickerField,
      // prevent keyboard for picker fields
      showCursor: !isPickerField,
      // optional: hide cursor
      enableInteractiveSelection: !isPickerField,
      // optional: disable selection
      keyboardType: keyboardType,
      validator: validator,
      onTap: effectiveOnTap,
      maxLines: maxLines,
      decoration: _inputDecoration(
        hint: hint,
        showCalendarIcon: showCalendarIcon,
        // no onCalendarTap here anymore
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    bool showCalendarIcon = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      // Passive icon (no IconButton) — tap is handled by the TextFormField itself
      suffixIcon: showCalendarIcon
          ? const Icon(Icons.calendar_today, color: Colors.grey)
          : null,
    );
  }
}

/// Existing helper for buttons
Widget buildButton(String text, Color color, {required VoidCallback onPressed}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    ),
  );
}


class _PickerFormField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final FormFieldValidator<T?>? validator;
  final InputDecoration decoration;
  final String? placeholder; // optional

  const _PickerFormField({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    required this.decoration,
    this.validator,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        final bool isEmpty = state.value == null;
        final String text = isEmpty
            ? (placeholder ?? 'Select')
            : labelOf(state.value as T);

        return InkWell(
          onTap: () async {
            final picked = await _showPicker<T>(
              context: context,
              items: items,
              current: state.value,
              labelOf: labelOf,
            );
            if (picked != null) {
              state.didChange(picked);
              onChanged(picked);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            decoration: decoration.copyWith(
              errorText: state.errorText,
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: isEmpty ? Colors.grey : null,
              ),
            ),
          ),
        );
      },
    );
  }

// @override
  // Widget build(BuildContext context) {
  //   return FormField<T>(
  //     initialValue: value,
  //     validator: validator,
  //     builder: (state) {
  //       final text = (state.value != null)
  //           ? labelOf(state.value as T)
  //           : (placeholder ?? 'Select');
  //       return InkWell(
  //         onTap: () async {
  //           final picked = await _showPicker<T>(
  //             context: context,
  //             items: items,
  //             current: state.value,
  //             labelOf: labelOf,
  //           );
  //           if (picked != null) {
  //             state.didChange(picked);
  //             onChanged(picked);
  //           }
  //         },
  //         borderRadius: BorderRadius.circular(10),
  //         child: InputDecorator(
  //           decoration: decoration.copyWith(
  //             errorText: state.errorText,
  //             suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
  //           ),
  //           child: Text(
  //             text,
  //             style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w300),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}

Future<T?> _showPicker<T>({
  required BuildContext context,
  required List<T> items,
  required T? current,
  required String Function(T) labelOf,
}) async {
  const itemExtent = 56.0;
  const visibleCount = 10;
  final maxHeight = (itemExtent * visibleCount) + 16; // + a bit of padding
  final sheetMax = MediaQuery.of(context).size.height * 0.6;

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SizedBox(
        height: maxHeight.clamp(0, sheetMax),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
          itemBuilder: (ctx, i) {
            final item = items[i];
            final selected = current != null && item == current;
            return ListTile(
              dense: false,
              title: Text(labelOf(item)),
              trailing: selected
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop(item),
            );
          },
        ),
      );
    },
  );
}
