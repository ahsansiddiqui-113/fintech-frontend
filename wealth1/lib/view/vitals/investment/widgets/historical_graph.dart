import 'package:flutter/material.dart';
import 'package:wealthnx/view/vitals/image_path.dart';

class HistoricalGarph extends StatelessWidget {
  const HistoricalGarph({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Text(
            //   'Investment Stats',
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.white,
            //   ),
            // ),
            // _buildFilterOptions(),
          ],
        ),
        SizedBox(height: 16),

        Image.asset(
          width: MediaQuery.of(context).size.width,
          ImagePaths.spend,
        ),
        SizedBox(height: 16),

        // SizedBox(
        //   height: 200,
        //   child: _buildInvestmentGraph(),
        // ),
      ],
    );
    ;
  }
}
