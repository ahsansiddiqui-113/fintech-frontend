import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wealthnx/controller/api_errors_hundle_pro/api_errors_hundle_pro.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/profile/profile_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/utils/app_urls.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController controller = Get.find<ProfileController>();
  final CommonController _commonController = Get.put(CommonController());

  @override
  Widget build(BuildContext context) {
    // controller.fetchProfileData();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Profile',
      onBackPressed: (){
        Get.delete<ProfileController>();
        Get.back();
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(""),
                  _buildProfilePicture(context),
                  const SizedBox(height: 10),
                  _buildUserName(),
                  const SizedBox(height: 10),
                  _buildFormFields(context),
                ],
              ),
            ),
          );
        }
      }),
      bottomNavigationBar: _buildUpdateButton(context),
    );
  }

  Widget _buildProfilePicture(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Obx(() => CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60,
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.black,
            backgroundImage: controller.profileImageFile.value != null
                ? FileImage(controller.profileImageFile.value!)
                : controller.profilePicController.text.isNotEmpty
                ? NetworkImage(
              AppEndpoints.profileBaseUrl +
                  controller.profilePicController.text,
            )
                : AssetImage(ImagePaths.person) as ImageProvider,
          ),
        )),
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: () => _showImagePickerDialog(context),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.teal,
              child: Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image',
            style: TextStyle(color: context.gc(AppColor.white), fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                controller.pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                controller.pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserName() {
    return Obx(
          () => _commonController.textWidget(
        Get.context!,
        title: controller.fullNameProfile.value,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        _buildInputField(
          context,
          label: 'First Name',
          controller: controller.firstNameController,
          validator: (value) => value?.isEmpty ?? true ? 'First Name is required' : null,
          hintText: 'John',
          isRequired: true,
        ),
        _buildInputField(
          context,
          label: 'Last Name',
          controller: controller.lastNameController,
          // validator: (value) => value?.isEmpty ?? true ? 'Last Name is required' : null,
          hintText: 'Doe',
          isRequired: true,
        ),
        _buildInputField(
          context,
          label: 'Email',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!GetUtils.isEmail(value ?? '')) return 'Invalid email';
            return null;
          },
          hintText: 'xxx@gmail.com',
          isRequired: true,
        ),
        _buildInputField(
          context,
          label: 'Phone Number',
          controller: controller.phoneNoController,
          keyboardType: TextInputType.phone,
          // validator: (value) => value?.isEmpty ?? true ? 'Phone Number is required' : null,
          hintText: '+1234567890',
          isRequired: false,
        ),
        _buildDatePickerField(
          context,
          label: 'Date of birth',
          controller: controller.dobController,
          hintText: 'DD/MM/YYYY',
          isRequired: false,
        ),
        _buildInputField(
          context,
          label: 'Address',
          controller: controller.addressController,
          hintText: '123 Main St, City, Country',
          isRequired: false,
        ),
        buildDropDownField(
          context,
          label: 'Gender',
        ),
        buildMartialStatusDropDownField(
          context,
          label: 'Martial Status',
        ),
        _buildInputField(
          context,
          label: 'Social Media Profile Link',
          controller: controller.socialLinkController,
          keyboardType: TextInputType.url,
          hintText: '',
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildInputField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required String hintText,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        bool isRequired = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: context.gc(AppColor.white),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          addHeight(6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.text,
            validator: validator,
            style: TextStyle(color: context.gc(AppColor.white)),
            decoration: inputDecoration(context, hintText),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom + 10,
        top: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(46, 173, 165, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => controller.updateProfile(),
        child: const Text(
          'Update Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required String hintText,
        bool isRequired = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: context.gc(AppColor.white),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            readOnly: true,
            style: TextStyle(color: context.gc(AppColor.white)),
            decoration: inputDecoration(context, hintText).copyWith(
              suffixIcon: Icon(
                Icons.calendar_today,
                color: Colors.grey,
                size: 20,
              ), focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color.fromRGBO(46, 173, 165, 1)),
            )
            ),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: const Color.fromRGBO(46, 173, 165, 1),
                        onPrimary: Colors.white,
                        surface: Colors.grey[900]!,
                        onSurface: Colors.white,
                      ),
                      dialogBackgroundColor: Colors.grey[900],
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                this.controller.setDateOfBirth(pickedDate);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildDropDownField(
      BuildContext context, {
        required String label,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _commonController.textWidget(
            context,
            title: label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          buildDropdown(),
        ],
      ),
    );
  }

  Widget buildDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedIncomeType.value == 'Select'
          ? null
          : controller.selectedIncomeType.value,
      hint: Text(
        'Select Gender',
        style: TextStyle(color: Colors.grey[600]),
      ),
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
      items: ProfileController.categories
          .where((value) => value != 'Select')
          .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(value),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          controller.selectedIncomeType.value = newValue;
          controller.genderController.text = newValue;
        }
      },
    ));
  }

  Widget buildMartialStatusDropDownField(
      BuildContext context, {
        required String label,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _commonController.textWidget(
            context,
            title: label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          buildMartialStatusDropdown(),
        ],
      ),
    );
  }

  Widget buildMartialStatusDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.martialStatusController.value.text.isEmpty
          ? null
          : controller.martialStatusController.value.text,
      hint: Text(
        'Select Martial Status',
        style: TextStyle(color: Colors.grey[600]),
      ),
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
      items: ProfileController.martialStatus.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(value),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          controller.martialStatusController.value.text = newValue;
        }
      },
    ));
  }
}
// class ProfilePage extends StatelessWidget {
//   ProfilePage({super.key});
//
//   final ProfileController controller = Get.put(ProfileController());
//   final CommonController _commonController = Get.put(CommonController());
//
//   @override
//   Widget build(BuildContext context) {
//     // controller.fetchProfileData();
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: customAppBar(title: 'Profile'),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 16),
//         child: Form(
//           key: controller.formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(""),
//               _buildProfilePicture(context),
//               const SizedBox(height: 12),
//               _buildUserName(),
//               const SizedBox(height: 21),
//               _buildFormFields(context),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildUpdateButton(context),
//     );
//   }
//
//   Widget _buildProfilePicture(BuildContext context) {
//     return Stack(
//       alignment: Alignment.bottomRight,
//       children: [
//         Obx(() => CircleAvatar(
//               radius: 60,
//               child: CircleAvatar(
//                 radius: 55,
//                 backgroundColor: Colors.black,
//                 backgroundImage: controller.profileImageFile.value != null
//                     ? FileImage(controller.profileImageFile.value!)
//                     : controller.profilePicController.text.isNotEmpty
//                         ? NetworkImage(
//                             AppEndpoints.profileBaseUrl +
//                                 controller.profilePicController.text,
//                           )
//                         : AssetImage(ImagePaths.person) as ImageProvider,
//               ),
//             )),
//         Positioned(
//           bottom: 0,
//           right: 4,
//           child: GestureDetector(
//             onTap: () => _showImagePickerDialog(context),
//             child: CircleAvatar(
//               radius: 14,
//               backgroundColor: Colors.teal,
//               child: Icon(Icons.edit, size: 14, color: Colors.white),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showImagePickerDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Select Image',
//             style: TextStyle(color: context.gc(AppColor.white), fontSize: 20)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.camera_alt),
//               title: Text('Camera'),
//               onTap: () {
//                 controller.pickImage(ImageSource.camera);
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.photo_library),
//               title: Text('Gallery'),
//               onTap: () {
//                 controller.pickImage(ImageSource.gallery);
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserName() {
//     return Obx(
//       () => _commonController.textWidget(
//         Get.context!,
//         title: controller.fullNameProfile.value,
//         fontSize: 20,
//         fontWeight: FontWeight.w500,
//       ),
//     );
//   }
//
//   Widget _buildFormFields(BuildContext context) {
//     return Column(
//       children: [
//         _buildInputField(
//           context,
//           label: 'First Name',
//           controller: controller.firstNameController,
//           validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//           hintText: 'John',
//         ),
//         _buildInputField(
//           context,
//           label: 'Last Name',
//           controller: controller.lastNameController,
//           validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//           hintText: 'Doe',
//         ),
//         _buildInputField(
//           context,
//           label: 'Email',
//           controller: controller.emailController,
//           keyboardType: TextInputType.emailAddress,
//           validator: (value) =>
//               GetUtils.isEmail(value ?? '') ? null : 'Invalid email',
//           hintText: 'xxx@gmail.com',
//         ),
//         _buildInputField(
//           context,
//           label: 'Phone Number',
//           controller: controller.phoneNoController,
//           keyboardType: TextInputType.phone,
//           hintText: '+1234567890',
//         ),
//         _buildInputField(
//           context,
//           label: 'Date of birth',
//           controller: controller.dobController,
//           hintText: 'DD/MM/YYYY',
//         ),
//         _buildInputField(
//           context,
//           label: 'Address',
//           controller: controller.addressController,
//           hintText: '123 Main St, City, Country',
//         ),
//         buildDropDownField(
//           context,
//           label: 'Gender',
//         ),
//         buildMartialStatusDropDownField(
//           context,
//           label: 'Martial Status',
//         ),
//         // _buildInputField(
//         //   context,
//         //   label: 'Martial Status',
//         //   controller: controller.martialStatusController,
//         // ),
//         _buildInputField(
//           context,
//           label: 'Social Media Profile Link',
//           controller: controller.socialLinkController,
//           keyboardType: TextInputType.url,
//           hintText: '',
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInputField(
//     BuildContext context, {
//     required String label,
//     required TextEditingController controller,
//     required String hintText,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _commonController.textWidget(
//             context,
//             title: label,
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//           TextFormField(
//             controller: controller,
//             keyboardType: keyboardType ?? TextInputType.text,
//             validator: validator,
//             style: TextStyle(color: context.gc(AppColor.white)),
//             decoration: inputDecoration(context, hintText),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUpdateButton(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewPadding.bottom + 10,
//         top: 10,
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       height: 45,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color.fromRGBO(46, 173, 165, 1),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         onPressed: () => controller.updateProfile(),
//         child: const Text(
//           'Update Profile',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildDropDownField(
//     BuildContext context, {
//     required String label,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _commonController.textWidget(
//             context,
//             title: label,
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//           buildDropdown(),
//         ],
//       ),
//     );
//   }
//
//   Widget buildDropdown() {
//     return Obx(() => DropdownButtonFormField<String>(
//           value: controller.selectedIncomeType.value,
//           dropdownColor: Colors.grey[900],
//           style: const TextStyle(color: Colors.white),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.black,
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(width: 0.5)),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.grey, width: 0.5),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide:
//                   const BorderSide(color: Color.fromRGBO(46, 173, 165, 1)),
//             ),
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           ),
//           items: ProfileController.categories.map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (newValue) {
//             if (newValue != null) {
//               controller.selectedIncomeType.value = newValue;
//               controller.genderController.text = newValue;
//             }
//           },
//         ));
//   }
//
//   // widget martial status
//   Widget buildMartialStatusDropDownField(
//     BuildContext context, {
//     required String label,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _commonController.textWidget(
//             context,
//             title: label,
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//           buildMartialStatusDropdown(),
//         ],
//       ),
//     );
//   }
//
//   Widget buildMartialStatusDropdown() {
//     return Obx(() => DropdownButtonFormField<String>(
//           value: controller.martialStatusController.value.text.isEmpty
//               ? null
//               : controller.martialStatusController.value.text,
//           dropdownColor: Colors.grey[900],
//           style: const TextStyle(color: Colors.white),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.black,
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(width: 0.5)),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.grey, width: 0.5),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide:
//                   const BorderSide(color: Color.fromRGBO(46, 173, 165, 1)),
//             ),
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           ),
//           items: ProfileController.martialStatus.map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (newValue) {
//             if (newValue != null) {
//               controller.martialStatusController.value.text = newValue;
//               controller.martialStatusController.value.text = newValue;
//             }
//           },
//         ));
//   }
// }
