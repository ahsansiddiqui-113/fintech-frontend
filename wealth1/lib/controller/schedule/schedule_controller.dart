import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealthnx/base_client/base_client.dart';
import 'package:wealthnx/models/schedule/schedule_model.dart';
import 'package:wealthnx/models/schedule/upcoming_schedule_model.dart';
import 'package:wealthnx/utils/app_urls.dart';


class ScheduleController extends GetxController {
  final selectedIndex = 0.obs;
  final monthDays = <Map<String, dynamic>>[].obs;
  final isSwitchingMonth = false.obs;
  final scrollController = ScrollController();

  // Data state
  final isLoadingExpense = false.obs;
  final expenseRecurring = Rxn<RecurringExpensesResponse>();
  final upcomingExpenseResponse = Rxn<UpcomingExpensesResponse>();
  final upcomingSchedules = <RecurringItem>[].obs;
  final currentDate = DateTime.now().obs;
  final showMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    // _rebuildFor(currentDate.value);
    fetchSchedules(currentDate.value);
    fetchTodaySchedules();
  }

  /// Fetch schedules for the provided [date] (day precision).
  Future<void> fetchSchedules(DateTime date) async {
    try {
      isLoadingExpense(true);
      final endpointDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await BaseClient()
          .get('${AppEndpoints.expenseSchedule}?date=$endpointDate');
      if (response != null) {
        expenseRecurring.value = RecurringExpensesResponse.fromJson(response);
        // _rebuildFor(currentDate.value);
      }
    } catch (e) {
      debugPrint('Exception while fetching expense: $e');
    } finally {
      isLoadingExpense(false);
    }
  }

  /// Always fetch today’s recurring expenses only
  Future<void> fetchTodaySchedules() async {
    try {
      isLoadingExpense(true);
      final response = await BaseClient().get('${AppEndpoints.upcomingRecurringExpenses}');

      if (response != null) {
        upcomingExpenseResponse.value = UpcomingExpensesResponse.fromJson(response);
        upcomingSchedules.assignAll(
            upcomingExpenseResponse.value?.body.upcomingSchedules ?? []);
      }
    } catch (e) {
      debugPrint('Exception while fetching today’s expense: $e');
    } finally {
      isLoadingExpense(false);
    }
  }

  /// Select a day in the strip and fetch its schedules.
  // Future<void> selectDay(int index) async {
  //   log("indexx ${  index}");
  //   if (index < 0 || index >= monthDays.length) return;
  //   if (selectedIndex.value == index) return;
  //
  //   selectedIndex.value = index;
  //   final selectedDay = monthDays[index]['fullDate'] as DateTime;
  //   _pendingCenterIndex = index;
  //   _centerIfReady(animated: true);
  //
  //   // shimmer is handled in fetchSchedules
  //   await fetchSchedules(selectedDay);
  // }
  Future<void> selectDay(int index) async {
    if (index < 0 || index >= monthDays.length) return;
    if (selectedIndex.value == index) return;

    selectedIndex.value = index;
    final selectedDay = monthDays[index]['fullDate'] as DateTime?;
    if (selectedDay == null) return;

    _pendingCenterIndex = index;
    _centerIfReady(animated: true);

    await fetchSchedules(selectedDay);
  }



  /// Rebuilds monthDays and scroll target for [anchor] month.
  void rebuildFor(DateTime anchor) {
    final firstDay = DateTime(anchor.year, anchor.month, 1);
    final lastDay = DateTime(anchor.year, anchor.month + 1, 0);
    final firstWeekday = firstDay.weekday;

    final days = <Map<String, dynamic>>[];

    // Add padding for full calendar view
    for (int i = 0; i < (firstWeekday - 1); i++) {
      days.add({
        'day': '',
        'date': '',
        'price': '',
        'dots': 0,
        'fullDate': null,
      });
    }

    // Add actual days
    for (int i = 0; i < lastDay.day; i++) {
      final day = firstDay.add(Duration(days: i));
      days.add({
        'day': DateFormat('E').format(day),
        'date': DateFormat('dd').format(day),
        'price': i % 3 == 0 ? '\$${(i + 1) * 50}' : '',
        'dots': (i % 4),
        'fullDate': day,
      });
    }

    monthDays.assignAll(days);

    // ✅ Find the real index of today (skip blanks)
    final today = DateTime(anchor.year, anchor.month, anchor.day);
    final anchorIndex =
    days.indexWhere((d) => d['fullDate'] != null && d['fullDate'] == today);

    selectedIndex.value = anchorIndex >= 0 ? anchorIndex : 0;
    log(" start indexx ${  selectedIndex.value}");
    _pendingCenterIndex = selectedIndex.value;
  }

  // void _rebuildFor(DateTime anchor) {
  //   final firstDay = DateTime(anchor.year, anchor.month, 1);
  //   final lastDay = DateTime(anchor.year, anchor.month + 1, 0);
  //   final firstWeekday = firstDay.weekday;
  //
  //   final days = <Map<String, dynamic>>[];
  //   for (int i = 0; i < (firstWeekday - 1); i++) {
  //     days.add({
  //       'day': '',
  //       'date': '',
  //       'price': '',
  //       'dots': 0,
  //       'fullDate': null,
  //     });
  //   }
  //   for (int i = 0; i < lastDay.day; i++) {
  //     final day = firstDay.add(Duration(days: i));
  //     days.add({
  //       'day': DateFormat('E').format(day),
  //       'date': DateFormat('dd').format(day),
  //       'price': i % 3 == 0 ? '\$${(i + 1) * 50}' : '',
  //       'dots': (i % 4),
  //       'fullDate': day,
  //     });
  //   }
  //
  //   monthDays.assignAll(days);
  //   final anchorIndex = (firstWeekday - 1) + (anchor.day - 1);
  //   selectedIndex.value = anchorIndex;
  //   _pendingCenterIndex = anchorIndex;
  // }


  /// Move month by [step] and fetch the schedules for the new month (day=1).
  Future<void> changeMonth(int step) async {
    if (isSwitchingMonth.value) return;
    isSwitchingMonth(true);
    try {
      final newMonth = DateTime(
        currentDate.value.year,
        currentDate.value.month + step,
        1,
      );
      currentDate.value = newMonth;
      rebuildFor(newMonth);
      await fetchSchedules(newMonth);
    } finally {
      isSwitchingMonth(false);
    }
  }

  /// Set month & year explicitly and fetch that month (day=1).
  Future<void> goToMonthYear(int year, int month) async {
    if (isSwitchingMonth.value) return;
    isSwitchingMonth(true);
    try {
      final date = DateTime(year, month, 1);
      currentDate.value = date;
      rebuildFor(date);
      await fetchSchedules(date);
    } finally {
      isSwitchingMonth(false);
    }
  }

  List<RecurringItem> get todaySchedules {
    return expenseRecurring.value?.body.recurringList ?? [];
  }
  double _viewportWidth = 0;
  double _itemExtent = 0;
  double _edge = 0;
  int _itemCount = 0;
  double _gap = 0;

  int? _pendingCenterIndex;

  /// Call this from the widget's LayoutBuilder whenever layout changes.
  void updateViewport({
    required double viewportWidth,
    required double itemExtent,
    required double edge,
    required double gap,
    required int itemCount,
  }) {
    _viewportWidth = viewportWidth;
    _itemExtent = itemExtent;
    _edge = edge;
    _itemCount = itemCount;
    _gap = gap;
    _centerIfReady(animated: true);
  }

  /// Public: center to current selection (e.g., after external state change)
  void centerToSelected({bool animated = false}) {
    _pendingCenterIndex = selectedIndex.value;
    _centerIfReady(animated: animated);
  }

  void _centerIfReady({required bool animated}) {
    if (!scrollController.hasClients) return;
    if (_viewportWidth <= 0 || _itemExtent <= 0 || _itemCount <= 0) return;

    final idx = (_pendingCenterIndex ?? selectedIndex.value)
        .clamp(0, (_itemCount - 1));
    final itemCenterX = _edge + (idx * _itemExtent) + (_itemExtent / 1);
    double target = itemCenterX - (_viewportWidth / 1);

    final contentWidth = _edge * 2 + _itemExtent * _itemCount;
    final maxScroll = (contentWidth - _viewportWidth).clamp(0, double.infinity);

    if (target < 0) target = 0;
    if (target > maxScroll) target = maxScroll.toDouble();

    _pendingCenterIndex = null;

    if (animated) {
      scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      scrollController.jumpTo(target);
    }
  }


  void changeCalender() {
    showMore.value = !showMore.value;
  }
}
