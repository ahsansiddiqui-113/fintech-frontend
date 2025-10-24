import 'package:flutter/material.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Terms & Conditions'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: marginSide()),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // textWidget(context,
              //     title: 'Terms & Conditions',
              //     fontSize: 30,
              //     fontWeight: FontWeight.bold),
              buildSection(context,
                  title: '',
                  description:
                      'Please carefully read the terms and conditions before using this app. By using the app, you agree to these terms. We recommend that you keep a copy of these terms for your reference.'),
              addHeight(21),
              buildSection(context,
                  title: '1. Agreement to Terms',
                  description:
                      'By accessing or using the app, you agree to comply with and be bound by these terms. If you do not agree with any part of the terms, you should immediately discontinue using the app.'),
              addHeight(21),
              buildSection(context,
                  title: '2. Financial Disclaimer',
                  description:
                      'This app provides financial guidance based on input provided by the user.'),
              addHeight(21),
              buildSection(context,
                  title: '3. User Responsibility',
                  description:
                      'You are responsible for the accuracy of the information you provide to the app. The app will not be held responsible for any errors or misinterpretations arising from incorrect or incomplete user input.'),
              addHeight(21),
              buildSection(context,
                  title: '4. Privacy Policy',
                  description:
                      'We are committed to protecting your privacy. All data provided by you will be handled according to our privacy policy. We will never share your personal information without your consent.'),
              addHeight(21),
              buildSection(context,
                  title: '5. Modification of Terms',
                  description:
                      'We may update or modify these terms from time to time. Any changes will be posted here with the updated date. Continued use of the app after such changes implies your acceptance of the modified terms.'),
              addHeight(21),
              buildSection(context,
                  title: '6. Effectiveness and Expertise',
                  description:
                      'Our app is designed to provide expert solutions for a wide range of financial problems. We utilize advanced algorithms and expert financial knowledge to offer accurate, reliable, and timely financial advice. However, please note that while the app is built to be highly effective, its results may vary based on the quality and accuracy of the information you provide.'),
              buildSection(context,
                  title: '',
                  description:
                      'Our team of financial experts continually updates the app’s algorithms and resources to ensure that the solutions we provide remain up-to-date and relevant. We are committed to helping you solve your financial problems by offering a trustworthy, user-friendly experience.'),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildSection(BuildContext context, {title, description}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      textWidget(context,
          title: title, fontSize: 18, fontWeight: FontWeight.w600),
      addHeight(8),
      textWidget(context, title: description, fontSize: 16),
    ],
  );
}
