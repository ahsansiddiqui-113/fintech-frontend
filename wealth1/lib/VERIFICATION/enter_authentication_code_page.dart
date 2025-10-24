import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:wealthnx/controller/authentication/forgot_password_controller.dart';
import '../controller/signup/signup_controller.dart';
import 'face_id.dart';

class EnterAuthenticationCodePage extends StatefulWidget {
  final String phoneNumber;
  final bool isNewUser;

  const EnterAuthenticationCodePage({
    super.key,
    required this.phoneNumber, required this.isNewUser,
  });

  @override
  State<EnterAuthenticationCodePage> createState() =>
      _EnterAuthenticationCodePageState();
}

class _EnterAuthenticationCodePageState
    extends State<EnterAuthenticationCodePage> {
 
  final controller = Get.put(ForgotPasswordController());
   final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Enter authentication code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text:
                      'Enter the 4-digit that we have sent via the\n Email ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: "" + widget.phoneNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PinCodeTextField(
                          onChanged: (value) {
                            setState(() {});
                          },
                          appContext: context,
                          controller: controller.otpController,
                          keyboardType: TextInputType.number,
                          textStyle: TextStyle(color: Colors.white),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the OTP';
                            }
                            if (value.length < 4) {
                              return 'OTP must be 4 digits';
                            }
                            return null;
                          },
                          length: 4,
                          pinTheme: PinTheme(
                            fieldHeight: 60,
                            fieldWidth: 60,
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            selectedColor: Colors.white,
                            inactiveColor: Colors.grey,
                            activeColor: Color.fromRGBO(46, 173, 165, 1),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: (){
                    if (formKey.currentState!.validate()) {
                      if(widget.isNewUser==true){
                        Get.find<SignupController>().signupVerifyOtp();
                      } else{
                        controller.forgotVerifyOtp();
                      }
                      // Proceed to the next page

                    } else {
                      showToast("Please enter a valid OTP", isError: true);
                    }
                    // Navigate to the next page
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => FaceIdPage(),
                    //   ),
                    // );
          // controller.forgotVerifyOtp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(46, 173, 165, 1),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        // Handle resend code
                        if(widget.isNewUser == true){
                          Get.put(SignupController()).signupSendOtp();
                        } else{
                          controller.forgotPassSendOtp();
                        }

                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(
                          color: Color.fromRGBO(46, 173, 165, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

showToast(String message, {bool isError = true}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.red : Colors.grey,
      textColor: Colors.white,
      fontSize: 16);
}
