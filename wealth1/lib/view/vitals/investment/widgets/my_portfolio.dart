import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealthnx/controller/comman_controller.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_detail_info_controller.dart';
import 'package:wealthnx/controller/investment/crypto/crypto_live_chart/crypto_live_chart_controller.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/crypto/crypto_detail_info.dart';
import 'package:wealthnx/view/vitals/investment/investment_tabs/stock_coin_detail_screen.dart';
import 'package:wealthnx/models/investment/investment_overview_model.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/theme/custom_app_theme.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/widgets/chart_painter.dart';
import 'package:wealthnx/widgets/empty.dart';

class MyPortfolio extends StatelessWidget {
  MyPortfolio({
    super.key,
    this.investType,
    this.portfolio,
    this.selectedT,
  });

  final String? investType;
  final List<OverviewBody>? portfolio;
  final String? selectedT;
  final RxString selectedTab = 'Crypto'.obs;

  bool get _hasData => (portfolio != null && portfolio!.isNotEmpty);

  OverviewBody? get _first =>
      _hasData ? portfolio!.first : null; // safe first element

  @override
  Widget build(BuildContext context) {
    final selT = (selectedT ?? 'Crypto'); // default to Crypto if null

    return Column(
      children: [
        if (investType != 'Home') ...[
          SizedBox(
            width: double.infinity,
            child: Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTab('Crypto'),
                  _buildTab('Stocks'),
                  _buildTab('Funds'),
                  _buildTab('Other'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (selT == 'Stock') ...[
          _buildPortfolioSection(
            title: 'Stock',
            items: _first?.stocks ?? const <CryptoModel>[],
          ),
        ] else ...[
          _buildPortfolioSection(
            title: 'Crypto',
            items: _first?.crypto ?? const <CryptoModel>[],
          ),
        ],
      ],
    );
  }

  Widget _buildPortfolioSection({
    required String title,
    required List<CryptoModel> items,
  }) {
    return items.isEmpty
        ? Empty(title: title, height: 70)
        : PortfolioList(
      items: items,
      title: title,
    );
  }

  Widget _buildTab(String title) {
    return Obx(() {
      final isSelected = selectedTab.value == title;
      return GestureDetector(
        onTap: () => selectedTab.value = title,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(46, 173, 165, 1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isSelected
                  ? const Color.fromRGBO(46, 173, 165, 1)
                  : Colors.grey,
              width: 0.25,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }
}

class PortfolioList extends StatelessWidget {
  final List<CryptoModel> items;
  final String title;

  const PortfolioList({
    super.key,
    required this.items,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).viewPadding.bottom + 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final item = items[index];
          return CoinItem(
            icon: item.image,
            symbol: item.name,
            sym: item.tickerSymbol,
            change: item.updatedAmount, // can be null
            value: item.amount,         // can be null
            title: title,
          );
        },
      ),
    );
  }
}

class CoinItem extends StatelessWidget {
  final String? icon;
  final String? symbol;
  final String? title; // 'Crypto' or 'Stock'
  final String? sym;
  final double? change;
  final double? value;

  CoinItem({
    super.key,
    this.icon,
    this.symbol,
    this.sym,
    this.change,
    this.value,
    this.title,
  });

  final CommonController _commonController = Get.put(CommonController());

  // Use Get.isRegistered to avoid exceptions when the controller isn't in memory.
  CryptoDetailInfoController? get _cryptoCtrl =>
      Get.isRegistered<CryptoDetailInfoController>()
          ? Get.find<CryptoDetailInfoController>()
          : null;

  final ChartController _chartController =
  Get.put(ChartController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    final double safeChange = change ?? 0.0;
    final double safeValue = value ?? 0.0;
    final bool isPositive = safeChange > 0;
    final changeColor = isPositive
        ? context.gc(AppColor.greenColor)
        : context.gc(AppColor.redColor);

    final String safeSymbol = (symbol?.trim().isNotEmpty ?? false)
        ? symbol!.trim()
        : '—';
    final String safeSym = (sym?.trim().isNotEmpty ?? false) ? sym!.trim() : '';

    return GestureDetector(
      onTap: () {
        // If we don't have symbols, don't navigate.
        if (title == 'Crypto') {
          final String coinId =
          (safeSymbol != '—') ? safeSymbol.toLowerCase() : 'bitcoin';

          // Skip calls if controller not registered
          _cryptoCtrl?.fetchCoinDetails('bitcoin');
          _chartController.updateCoinId(newCoinId: 'bitcoin');

          _cryptoCtrl?.fetchGainerLoserDetailsCoins(coinId);
          _chartController.updateCoinId(newCoinId: coinId);
          _cryptoCtrl?.fetchCoinDetails(coinId);

          Get.put(ChartController()).newsList.clear();
          final String coinParams =
          (safeSym.isNotEmpty ? '${safeSym.toUpperCase()}USD' : 'BTCUSD');

          Get.put(ChartController())
              .fetchNews(newsId: coinParams, cryptoNews: true);

          Get.to(
                () => CryptoDetailInfo(
              typePortfolio: 'portfolio',
              title: safeSymbol,
              icon: icon,
              sym: safeSym,
              change: safeChange,
              value: safeValue,
            ),
          );
        } else {
          Get.put(ChartController()).newsList.clear();
          final String coinParams =
          (safeSym.isNotEmpty ? '${safeSym.toUpperCase()}USD' : 'AAPLUSD');

          Get.put(ChartController())
              .fetchNews(newsId: coinParams, cryptoNews: true);
          Get.to(
                () => StockCoinDetailScreen(
              typePortfolio: 'portfolio',
              title: safeSymbol,
              icon: icon,
              sym: safeSym,
              change: safeChange,
              value: safeValue,
            ),
          );
        }
      },
      child: Container(
        width: responTextWidth(190),
        margin: EdgeInsets.only(right: responTextWidth(12)),
        padding: EdgeInsets.all(responTextWidth(8)),
        decoration: BoxDecoration(
          border: Border.all(color: context.gc(AppColor.greyDialog)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: responTextWidth(36),
                  height: responTextHeight(36),
                  clipBehavior: Clip.hardEdge,
                  decoration: const ShapeDecoration(shape: CircleBorder()),
                  child: (icon != null && icon!.isNotEmpty)
                      ? Image.network(
                    icon!,
                    width: responTextWidth(36),
                    height: responTextHeight(36),
                    fit: BoxFit.contain,
                    errorBuilder: (context, url, error) =>
                    const Icon(Icons.error),
                  )
                      : const Icon(Icons.token_outlined),
                ),
                addWidth(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _commonController.textWidget(
                        context,
                        title: safeSymbol,
                        fontSize: responTextWidth(14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        fontWeight: FontWeight.w500,
                      ),
                      _commonController.textWidget(
                        context,
                        title: safeSym,
                        fontSize: responTextWidth(10),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // change with arrow
                    Row(
                      children: [
                        _commonController.textWidget(
                          context,
                          title: safeChange.toStringAsFixed(2),
                          fontSize: responTextWidth(13),
                          color: changeColor,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          fontWeight: FontWeight.w500,
                        ),
                        Icon(
                          isPositive
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: changeColor,
                          size: responTextWidth(25),
                        ),
                      ],
                    ),
                    // value
                    _commonController.textWidget(
                      context,
                      title: safeValue.toStringAsFixed(2),
                      fontSize: responTextWidth(15),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
                addWidth(46),
                Expanded(
                  child: SizedBox(
                    height: responTextHeight(20),
                    child: CustomPaint(
                      // ensure finite, positive size
                      size: Size(
                        math.max(1, safeValue),
                        math.max(1, safeChange.abs()),
                      ),
                      painter: ChartPainter(
                        borderColor: CustomAppTheme.green,
                        gradientColors: [
                          context.gc(AppColor.primary).withOpacity(0.5),
                          context.gc(AppColor.primary).withOpacity(0.1),
                        ],
                        isDown: !isPositive,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// AI Agent card — same null-safety patterns
class AIAgentCardHome extends StatelessWidget {
  final String? icon;
  final String? symbol;
  final String? title;
  final String? sym;
  final double? change;
  final double? value;

  AIAgentCardHome({
    super.key,
    this.icon,
    this.symbol,
    this.sym,
    this.change,
    this.value,
    this.title,
  });

  final CommonController _commonController = Get.put(CommonController());
  CryptoDetailInfoController? get _cryptoCtrl =>
      Get.isRegistered<CryptoDetailInfoController>()
          ? Get.find<CryptoDetailInfoController>()
          : null;

  final ChartController _chartController =
  Get.put(ChartController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    final double safeChange = change ?? 0.0;
    final double safeValue = value ?? 0.0;
    final bool isPositive = safeChange > 0;

    final changeColor = isPositive
        ? context.gc(AppColor.greenColor)
        : context.gc(AppColor.redColor);

    final String safeSymbol = (symbol?.trim().isNotEmpty ?? false)
        ? symbol!.trim()
        : '—';
    final String safeSym = (sym?.trim().isNotEmpty ?? false) ? sym!.trim() : '';

    return GestureDetector(
      onTap: () {
        if (title == 'Crypto') {
          final String coinId =
          (safeSymbol != '—') ? safeSymbol.toLowerCase() : 'bitcoin';

          _cryptoCtrl?.fetchCoinDetails('bitcoin');
          _chartController.updateCoinId(newCoinId: 'bitcoin');

          _cryptoCtrl?.fetchGainerLoserDetailsCoins(coinId);
          _chartController.updateCoinId(newCoinId: coinId);
          _cryptoCtrl?.fetchCoinDetails(coinId);

          Get.put(ChartController()).newsList.clear();
          final String coinParams =
          (safeSym.isNotEmpty ? '${safeSym.toUpperCase()}USD' : 'BTCUSD');

          Get.put(ChartController())
              .fetchNews(newsId: coinParams, cryptoNews: true);

          Get.to(
                () => CryptoDetailInfo(
              typePortfolio: 'portfolio',
              title: safeSymbol,
              icon: icon,
              sym: safeSym,
              change: safeChange,
              value: safeValue,
            ),
          );
        } else {
          Get.put(ChartController()).newsList.clear();
          final String coinParams =
          (safeSym.isNotEmpty ? '${safeSym.toUpperCase()}USD' : 'AAPLUSD');

          Get.put(ChartController())
              .fetchNews(newsId: coinParams, cryptoNews: true);
          Get.to(
                () => StockCoinDetailScreen(
              typePortfolio: 'portfolio',
              title: safeSymbol,
              icon: icon,
              sym: safeSym,
              change: safeChange,
              value: safeValue,
            ),
          );
        }
      },
      child: Container(
        width: responTextWidth(208),
        margin: EdgeInsets.only(right: responTextWidth(12)),
        padding: EdgeInsets.all(responTextWidth(8)),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePaths.aiagent),
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: responTextWidth(36),
                  height: responTextHeight(36),
                  clipBehavior: Clip.hardEdge,
                  decoration: const ShapeDecoration(shape: CircleBorder()),
                  child: (icon != null && icon!.isNotEmpty)
                      ? Image.network(
                    icon!,
                    width: responTextWidth(36),
                    height: responTextHeight(36),
                    fit: BoxFit.contain,
                    errorBuilder: (context, url, error) =>
                    const Icon(Icons.error),
                  )
                      : const Icon(Icons.token_outlined),
                ),
                addWidth(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _commonController.textWidget(
                        context,
                        title: safeSymbol,
                        fontSize: responTextWidth(14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        fontWeight: FontWeight.w500,
                      ),
                      _commonController.textWidget(
                        context,
                        title: safeSym,
                        fontSize: responTextWidth(10),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Value (formatted safely)
                _commonController.textWidget(
                  context,
                  title: '\$${safeValue.toStringAsFixed(2)}',
                  fontSize: responTextWidth(15),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  fontWeight: FontWeight.w400,
                ),
                addWidth(20),
                Expanded(
                  child: SizedBox(
                    height: responTextHeight(20),
                    child: CustomPaint(
                      size: Size(
                        math.max(1, safeValue),
                        math.max(1, safeChange.abs()),
                      ),
                      painter: ChartPainter(
                        borderColor: CustomAppTheme.green,
                        gradientColors: [
                          context.gc(AppColor.primary).withOpacity(0.5),
                          context.gc(AppColor.primary).withOpacity(0.1),
                        ],
                        isDown: !isPositive,
                      ),
                    ),
                  ),
                ),
                addWidth(20),
                Row(
                  children: [
                    _commonController.textWidget(
                      context,
                      title: safeChange.toStringAsFixed(2),
                      fontSize: responTextWidth(13),
                      color: changeColor,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      fontWeight: FontWeight.w500,
                    ),
                    Icon(
                      isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: changeColor,
                      size: responTextWidth(25),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}