import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/feedback/feedback_controller.dart';
import 'package:wealthnx/controller/profile/profile_controller.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';

class FeedbackScreenDialog extends StatelessWidget {
  FeedbackScreenDialog({super.key, this.onPressed});

  final VoidCallback? onPressed;
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());
    final FocusNode focusNode = FocusNode();

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 26),
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: context.gc(AppColor.grey), width: 0.25),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: onPressed ?? () => Get.back(),
                  child: Icon(Icons.close, color: context.gc(AppColor.grey)),
                ),
              ),
              Row(
                children: [
                  Obx(() {
                    return textWidget(context,
                        title: "Hi ${profileController.fullNameProfile}".tr,
                        fontSize: 12,
                        fontWeight: FontWeight.w400);
                  }),
                  addWidth(6),
                  Text(
                    '👋',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              addHeight(5),
              textWidget(context,
                  title: "We'd love your feedback!".tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              addHeight(16),
              Obx(() => Column(
                    children:
                        controller.feedbackOptions.asMap().entries.map((entry) {
                      int index = entry.key;
                      String option = entry.value;
                      bool isSelected =
                          controller.selectedOption.value == index;

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => controller.toggleOption(index),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  // Circular checkbox
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? context.gc(AppColor.white)
                                            : context.gc(AppColor.grey),
                                        width: 0.5,
                                      ),
                                      color: isSelected
                                          ? context.gc(AppColor.white)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            size: 10,
                                            color: Colors.black,
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: textWidget(context,
                                        title: option.tr,
                                        fontSize: 14,
                                        color: Color(0xFFCCCCCC),
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          controller.selectedOption.value == index &&
                                  option == "Other"
                              ? Column(
                                children: [
                                  addHeight(12),
                                  TextFormField(
                                      onChanged: (value) {},
                                      minLines: 3,
                                      maxLines: 3,
                                      focusNode: focusNode,
                                      controller: controller.descriptionController,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          color: context.gc(AppColor.white)),
                                      decoration: inputDecoration(
                                          context, 'e.g I like the clean design'),
                                    ),
                                ],
                              )
                              : SizedBox.shrink(),
                        ],
                      );
                    }).toList(),
                  )),
              addHeight(12),
              Obx(() => buildAddButton(
                    title: 'Submit Feedback',
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.only(top: 10),
                    onPressed: controller.isButtonEnabled
                        ? () async {
                             await controller.submitFeedback();
                            // Get.back();
                          }
                        : null,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
