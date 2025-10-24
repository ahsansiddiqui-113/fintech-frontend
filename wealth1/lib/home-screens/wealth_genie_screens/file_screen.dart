import 'package:flutter/material.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/custom_app_bar.dart';

class FileScreen extends StatelessWidget {
  FileScreen({super.key});

  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: 'Files',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: marginSide(), vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF000000),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(46, 173, 165, 1)),
                    ),
                    prefixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ),
                  onChanged: (value) => {},
                ),
              ),

              addHeight(30),
              textWidget(context,
                  title: 'Today',
                  fontSize: 14,
                  color: context.gc(AppColor.grey),
                  fontWeight: FontWeight.w400),
              addHeight(14),
              buildFeatureCard(context, 'Technical Analysis of Nvidia'),
              addHeight(14),
              buildFeatureCard(context, 'Portfolio Dashboard'),
              addHeight(14),
              textWidget(context,
                  title: 'Yesterday',
                  fontSize: 14,
                  color: context.gc(AppColor.grey),
                  fontWeight: FontWeight.w400),
              addHeight(14),
              buildFeatureCard(context, 'USA Economy Update'),
              addHeight(14),
              buildFeatureCard(context, 'Crypto Market Analysis'),
              addHeight(14),
              buildFeatureCard(context, 'Personal Finance Analysis'),
              addHeight(14),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFeatureCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        _messageController.text = title;
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.teal.shade700.withOpacity(0.4)),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 5, 13, 12),
              Color.fromARGB(255, 5, 13, 12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textWidget(context,
                title: title, fontSize: 14, fontWeight: FontWeight.w500),
            Icon(
              Icons.more_vert,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
