import 'package:flutter/material.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class EmailAuthPage extends StatefulWidget {
  const EmailAuthPage({super.key});

  @override
  State<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends State<EmailAuthPage> {
  bool bothEnabled = false;
  bool emailEnabled = true;
  bool passwordEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: customAppBar(title: 'Email & Password Authentication'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildToggleRow(
            title: 'Both Email & Password Authentication',
            value: bothEnabled,
            onChanged: (val) => setState(() => bothEnabled = val),
          ),
          const SizedBox(height: 24),
          _buildToggleRow(
            title: 'Email Authentication',
            value: emailEnabled,
            onChanged: (val) => setState(() => emailEnabled = val),
          ),
          const SizedBox(height: 8),
          _authDescription([
            'To enhance security and protect your account, we require email verification before enabling this feature.',
            'Ensures only you can access your account.',
            'Helps in password recovery and important notifications.',
            'Prevents fraud and unauthorized access.',
          ]),
          const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'After enable this the authentication will only happen through',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: const TextSpan(
                      text: '*********@example.com.',
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w300),
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 24),
          _buildToggleRow(
            title: 'Password Authentication',
            value: passwordEnabled,
            onChanged: (val) => setState(() => passwordEnabled = val),
          ),
          const SizedBox(height: 8),
          _authDescription([
            'To protect your financial data, we require a strong password for authentication.',
            'Prevents unauthorized access to your account.',
            'Enhances security for financial transactions.',
            'Required for logging in, making withdrawals, and changing account details.',
          ]),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'After enable this the authentication will only happen through',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 6),
              RichText(
                text: const TextSpan(
                  text: 'Password',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w300),
                  children: [
                    TextSpan(
                      text: ' ************',
                      style: TextStyle(color: Colors.teal, fontSize: 10, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ],
          )

        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.w400),
          ),
        ),
        // Switch(
        //   value: value,
        //   onChanged: onChanged,
        //   activeColor: Colors.teal,
        //   inactiveTrackColor: Colors.white30,
        // ),
        Transform.scale(
          scale: 0.7,
          child: Switch(
            value: value,
            activeColor: Colors.white,
            inactiveThumbColor: Colors.white,
            activeTrackColor: CustomAppTheme.primaryColor,
            inactiveTrackColor: Colors.grey.withOpacity(0.4),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _authDescription(List<String> bullets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bullets
          .map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ",
                        style: TextStyle(color: Colors.white54, fontSize: 10,fontWeight: FontWeight.w300)),
                    Expanded(
                      child: Text(text,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10,fontWeight: FontWeight.w300)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
