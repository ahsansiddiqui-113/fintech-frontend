import 'package:flutter/material.dart';
import 'package:wealthnx/view/vitals/investment/widgets/historical_graph.dart';
import 'package:wealthnx/view/vitals/investment/widgets/open_close.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';

class OtherDetailList extends StatefulWidget {
  OtherDetailList({super.key, this.title, this.icon, this.sym});
  String? title;
  String? icon;
  String? sym;

  @override
  State<OtherDetailList> createState() => _OtherDetailListState();
}

class _OtherDetailListState extends State<OtherDetailList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${widget.title}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            )),
        elevation: 0,
        leading: IconButton(
          // alignment: Alignment.centerLeft,
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [Container(), Container()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //------ Stock Section ------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Investment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '+21%(24h)',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            //------ Graph Section ------

            HistoricalGarph(),
            SizedBox(height: 20),

            //------ Today List Section ------

            SectionName(
              title: '${widget.title} Details',
              titleOnTap: '',
              onTap: () {},
            ),

            //----------- Lower Section -------
            OpenClose(
              title: 'House Rent',
              titlefontSize: 14,
              childWidget: Row(
                children: [
                  Text(
                    '\$3,26.31',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
            Divider(
              thickness: 0.25,
              height: 2,
            ),
            OpenClose(
              title: 'Farming Return',
              titlefontSize: 14,
              childWidget: Row(
                children: [
                  Text(
                    '\$3,26.31',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
            Divider(
              thickness: 0.25,
              height: 2,
            ),
            OpenClose(
              title: 'Today Property Rate',
              titlefontSize: 14,
              childWidget: Row(
                children: [
                  Text(
                    '\$3,26.31',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
            Divider(
              thickness: 0.25,
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}
