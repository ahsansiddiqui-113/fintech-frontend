import 'package:flutter/material.dart';

class FundsTab extends StatefulWidget {
  const FundsTab({super.key});

  @override
  State<FundsTab> createState() => _FundsTabState();
}

class _FundsTabState extends State<FundsTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text("Coming Soon"),
        ));
  }
}
