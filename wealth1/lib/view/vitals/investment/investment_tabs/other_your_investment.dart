import 'package:flutter/material.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/other_detail_list.dart';

class OtherYourInvestment extends StatefulWidget {
  const OtherYourInvestment({super.key});

  @override
  State<OtherYourInvestment> createState() => _OtherYourInvestmentState();
}

class _OtherYourInvestmentState extends State<OtherYourInvestment> {
  final List<Map<String, dynamic>> _otherItems = [
    {
      "title": "Property",
      "sym": "House Rent, Farming",
      "icon": ImagePaths.home,
      "percentage": "+3.48%",
      "amount": "\$3200",
      "isPositive": true,
    },
    {
      "title": "Transport",
      "sym": "Car, Trucks on daily rent",
      "icon": ImagePaths.bus,
      "percentage": "+3.48%",
      "amount": "\$3200",
      "isPositive": true,
    },
    {
      "title": "Tech Shop",
      "sym": "Mobile sale purchase",
      "icon": ImagePaths.shopping,
      "percentage": "+3.48%",
      "amount": "\$3200",
      "isPositive": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: otherType(),
        ),
      ],
    );
  }

  Widget otherType() {
    return Column(
      children: _otherItems.map((transaction) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OtherDetailList(
                        title: transaction["title"],
                        icon: transaction["icon"],
                        sym: transaction["sym"],
                      )),
            );
          },
          child: Column(
            children: [
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      clipBehavior: Clip.hardEdge,
                      decoration: const ShapeDecoration(
                        shape: CircleBorder(),
                      ),
                      child: Image.asset(
                        transaction["icon"],
                        width: 34,
                        height: 34,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction["title"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "${transaction["sym"]}",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          transaction["amount"],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          "${transaction["percentage"]}",
                          style: TextStyle(
                            color: transaction["isPositive"]
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 0.25,
                height: 2,
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}
