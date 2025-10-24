import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:get_secure_storage/get_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealthnx/home-screens/wealth_genie_screens/explore_agents.dart';
import 'package:wealthnx/controller/wealth_genie/wealth_genie_controller.dart';
import 'package:wealthnx/home-screens/wealth_genie_screens/file_screen.dart';
import 'package:wealthnx/view/vitals/image_path.dart';
import 'package:wealthnx/theme/app_color.dart';
import 'package:wealthnx/utils/app_helper.dart';
import 'package:wealthnx/view/vitals/investment/widgets/section_name.dart';
import 'package:wealthnx/widgets/streaming_analysis_text.dart';
import 'package:wealthnx/widgets/webview.dart';

class WealthGenieView extends StatefulWidget {
  WealthGenieView({super.key});

  @override
  State<WealthGenieView> createState() => _WealthGenieViewState();
}

class _WealthGenieViewState extends State<WealthGenieView> {
  final WealthGenieController wealthGenieController =
      Get.put(WealthGenieController());

  final FocusNode _focusNode = FocusNode();
  // final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (wealthGenieController.focusNodeDashboard.text == 'focusNodeDashboard') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
      wealthGenieController.focusNodeDashboard.text = '';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(WealthGenieController(), permanent: true);

    return GetBuilder<WealthGenieController>(
      init: WealthGenieController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
          body: WillPopScope(
            onWillPop: () async {
              if (controller.isWebViewVisible) {
                controller.hideWebView();
                return false;
              }
              if (controller.hasMessages) {
                controller.clearHistory();
                return false;
              }
              return true;
            },
            child: Column(
              children: [
                Expanded(
                  child: Obx(() => controller.hasMessages
                      ? _buildChatView(controller)
                      : _buildHomeView(context, controller)),
                ),
                Obx(() {
                  if (controller.hasMessages) {
                    return _buildInputField(controller);
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeView(BuildContext ctx, WealthGenieController controller) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      drawer: _buildLeftDrawer(controller),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImagePaths.grad),
              fit: BoxFit.contain,
              alignment: Alignment.topLeft),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: marginSide()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 45),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Builder(builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Image.asset(
                          ImagePaths.menu,
                          fit: BoxFit.contain,
                          height: responTextHeight(14),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              addHeight(50),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(ImagePaths.wealthgenpng),
                      fit: BoxFit.contain,
                      alignment: Alignment.topLeft),
                ),
                child: Column(
                  children: [
                    addHeight(140),
                    const Text(
                      'Hi I\'m Wealth Genie',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'How Can I help you today?',
                      style: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildFeatOption(
                          onTap: () {
                            Get.to(() => ExploreAgents());
                          },
                          wealthController: controller,
                          title: 'View All',
                          icon: ImagePaths.wg9),
                      addWidth(11),
                      buildFeatOption(
                          wealthController: controller,
                          title: 'Accountant',
                          icon: ImagePaths.wg7),
                      addWidth(11),
                      buildFeatOption(
                          wealthController: controller,
                          title: 'Crypto',
                          icon: ImagePaths.wg6),
                    ],
                  ),
                  addHeight(11),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildFeatOption(
                          wealthController: controller,
                          title: 'Stock',
                          icon: ImagePaths.wg3),
                      addWidth(11),
                      buildFeatOption(
                          onTap: () {
                            setState(() {});
                            controller.setSelectedIncomeType('Html');
                            controller.agentType.text = '@Build Mode ';
                            controller.messageController.text = "@Build Mode ";
                            controller.selectMsgType.value =
                                controller.messageController.text;
                          },
                          wealthController: controller,
                          title: 'Build Mode',
                          icon: ImagePaths.wg8),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (controller.agentType.text == '@Accountant ') ...[
                      buildQuickOption(controller, 'Monthly\nExpenses',
                          Icons.arrow_circle_right_outlined),
                      buildQuickOption(controller, 'Budget\nCategories',
                          Icons.arrow_circle_right_outlined),
                      buildQuickOption(controller, 'Transaction\nAnalysis ',
                          Icons.arrow_circle_right_outlined),
                    ],
                    if (controller.agentType.text == '@Crypto ') ...[
                      buildQuickOption(controller, 'Top\nCrypto',
                          Icons.arrow_circle_right_outlined),
                      buildQuickOption(controller, 'Market\nSentiment',
                          Icons.arrow_circle_right_outlined),
                      buildQuickOption(controller, 'Overall\nAnalysis ',
                          Icons.arrow_circle_right_outlined),
                    ],
                    if (controller.agentType.text == '@Stock ') ...[
                      buildQuickOption(controller, 'Stock',
                          Icons.arrow_circle_right_outlined),
                      buildQuickOption(controller, 'Market\nSentiment',
                          Icons.arrow_circle_right_outlined),
                      buildQuickOption(controller, 'Overall\nAnalysis ',
                          Icons.arrow_circle_right_outlined),
                    ],
                    if (controller.agentType.text == '@Build Mode ') ...[
                      buildQuickOption(controller, 'Create\nDashboard',
                          Icons.arrow_circle_right_outlined),
                      buildQuickOption(controller, 'Create\nMind Map',
                          Icons.arrow_circle_right_outlined),
                      buildQuickOption(controller, 'Create\nSheets',
                          Icons.arrow_circle_right_outlined),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(horizontal: marginSide()),
          child: buildV3PromptInput(controller)),
    );
  }

  Widget _buildLeftDrawer(WealthGenieController controller) {
    return Drawer(
      width: 250,
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 50),
          buildDrawerTile(ImagePaths.addgenie, 'New Chat', onTap: () async {
            Get.back();
            controller.clearHistory();
            controller.sessionMsgId.value = controller.generateSessionId();

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                'newSessionId', controller.sessionMsgId.value);
          }),
          buildDrawerTile(ImagePaths.filegenie, 'Files', onTap: () {
            Get.to(() => FileScreen());
          }),
          buildDrawerTile(ImagePaths.agentgenie, 'Explore Agents', onTap: () {
            Get.to(() => ExploreAgents());
          }),
          Obx(() => buildExpandableTile(
                controller: controller,
                icon: ImagePaths.historygenie,
                title: 'History',
                expanded: controller.isHistoryExpanded,
                onTap: controller.toggleHistoryExpanded,
              )),
        ],
      ),
    );
  }

  Widget buildDrawerTile(String icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Image.asset(
        icon.toString(),
        color: Colors.white,
        fit: BoxFit.contain,
        width: 24,
        height: 24,
      ),
      // leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget buildExpandableTile({
    required WealthGenieController controller,
    required String icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    if (expanded && controller.sessions.isEmpty) {
      controller.fetchSessions();
    } else {
      controller.isLoadSession.value = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Image.asset(
            icon.toString(),
            color: Colors.white,
            fit: BoxFit.contain,
            width: 24,
            height: 24,
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white,
            size: 20,
          ),
          onTap: onTap,
        ),
        if (expanded)
          Obx(() {
            if (controller.isLoadHistory) {
              return SizedBox(
                height: 400,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[600]!,
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(7, (index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Container(
                            width: 200,
                            height: 30,
                            color: Colors.grey[900],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            } else {
              if (controller.sessions.isNotEmpty) {
                return SizedBox(
                  height: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      children: controller.sessions.map(
                        (session) {
                          final text = "${session.title}";
                          return ListTile(
                            dense: true,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                            title: Text(
                              text,
                              style: TextStyle(
                                  color: context.gc(AppColor.white),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () async {
                              Get.back();
                              print("Session Id Message: ${session.sessionId}");
                              controller
                                  .fetchSessionMessages(session.sessionId);
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No sessions found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            }
          }),
      ],
    );
  }

  Widget buildChatOptions({
    required int messageIndex, // NEW: Added message index parameter
    required Message message,
    required WealthGenieController wealthController,
    GestureTapCallback? onTap,
    required String title,
    required String icon,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            // NEW: Update tab selection for this specific message
            wealthController.setTabForMessage(messageIndex, title);
            wealthController.selectOptionType.value = title;
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: wealthController.getTabForMessage(messageIndex) == title
              ? Colors.teal.shade700.withOpacity(0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.teal.shade700.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title == 'Sources') ...[
              (message.resources != null && message.resources!.isNotEmpty)
                  ? SizedBox(
                      width: marginSide(90),
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.passthrough,
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.transparent,
                          ),
                          ...message.resources!.map((r) {
                            double i = 0;
                            if (i == 0) {
                              i = 1;
                            } else {
                              i += 10;
                            }

                            return Positioned(
                              left: i,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.transparent,
                                backgroundImage: (message.resources != null &&
                                        message.resources!.isNotEmpty)
                                    ? NetworkImage(r.webfavicons)
                                    : AssetImage('assets/images/exp_1.png'),
                              ),
                            );
                          }),
                          Positioned(
                            left: 45,
                            bottom: 0,
                            child: textWidget(context,
                                title: "Source",
                                fontSize: responTextWidth(12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                fontWeight: wealthController
                                            .getTabForMessage(messageIndex) ==
                                        title
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                color: context.gc(AppColor.white)),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ] else ...[
              Image.asset(
                icon,
                fit: BoxFit.contain,
                width: 17,
              ),
              addHeight(2),
              textWidget(context,
                  title: "  " + title,
                  fontSize: responTextWidth(12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  fontWeight:
                      wealthController.getTabForMessage(messageIndex) == title
                          ? FontWeight.w500
                          : FontWeight.w400,
                  color: context.gc(AppColor.white)),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildFeedbackOption(
      {required WealthGenieController wealthController,
      GestureTapCallback? onTap,
      required String title}) {
    return Obx(
      () => GestureDetector(
        onTap: onTap ??
            () async {
              setState(() {});

              wealthController.selectedFeedback.value = title;
            },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: wealthController.selectedFeedback.value == title
                ? Colors.teal.shade700.withOpacity(0.4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.teal.shade700.withOpacity(0.4)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFeatOption(
      {required WealthGenieController wealthController,
      GestureTapCallback? onTap,
      required String title,
      required String icon}) {
    return GestureDetector(
      onTap: onTap ??
          () async {
            setState(() {});

            wealthController.setSelectedIncomeType('Text');
            wealthController.agentType.text = "@" + title + " ";
            wealthController.messageController.text = "@" + title + " ";
            wealthController.selectMsgType.value =
                wealthController.messageController.text;
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: wealthController.selectMsgType.value == "@" + title + ' '
              ? Colors.teal.shade700.withOpacity(0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.teal.shade700.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              color: Colors.white,
              fit: BoxFit.contain,
              width: 18,
              height: 18,
            ),
            const SizedBox(height: 2),
            Text(
              "  " + title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuickOption(
      WealthGenieController wealthController, String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        wealthController.messageController.text = label;
        wealthController.handleMessageSubmit();
      },
      child: Container(
        width: 140,
        height: 80,
        padding: EdgeInsets.all(marginSide(8)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 0.5),
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.centerRight,
            colors: [
              Color.fromRGBO(8, 39, 37, 0.6),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              size: 21,
              color: Colors.grey,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: textWidget(context,
                  title: label,
                  overflow: TextOverflow.ellipsis,
                  fontSize: responTextWidth(14),
                  maxLines: 2,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildV3PromptInput(WealthGenieController controller) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            onChanged: (value) {
              controller.agentType.text = value;
              controller.selectMsgType.value = value;
            },
            minLines: 1,
            maxLines: 3,
            focusNode: _focusNode,
            controller: controller.messageController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Get.context!.gc(AppColor.white)),
            decoration: inputDecoration(Get.context!, 'Ask Wealth Genie....'),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            // if (controller.selectedIncomeType == 'Text') {
            controller.handleMessageSubmit();
            // } else {
            //   controller.handleHtmlCheck();
            // }
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(46, 173, 165, 1),
                  Color.fromRGBO(48, 107, 103, 1),
                ],
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        )
      ],
    );
  }

  Widget _buildChatView(WealthGenieController wealthController) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      drawer: _buildLeftDrawer(wealthController),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: marginSide()),
        child: Column(
          children: [
            const SizedBox(height: 45),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Image.asset(
                      ImagePaths.menu,
                      fit: BoxFit.contain,
                      height: responTextHeight(14),
                    ),
                  );
                }),
                addWidth(20),
                Text('Wealth Genie',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
              ],
            ),
            addHeight(10),
            Expanded(
              child: Obx(() {
                if (wealthController.currentSession == null) {
                  return const Center(child: Text("Hello World"));
                }

                final assistantMessages = wealthController
                    .currentSession!.messages
                    .where((msg) => msg.userRole == 'assistant')
                    .toList();

                //  final assistantMessages = wealthController
                // .currentSession!.messages
                // .where((msg) =>
                //     msg.userRole == 'assistant' && msg.followUps.isNotEmpty)
                // .toList();

                // Fallback → if no follow-ups
                if (assistantMessages.isEmpty) {
                  return ListView.builder(
                    controller: wealthController.scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount:
                        wealthController.currentSession!.messages.length +
                            (wealthController.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index <
                          wealthController.currentSession!.messages.length) {
                        return _buildMessage(
                            wealthController.currentSession!.messages[index],
                            context,
                            index); // NEW: Pass index
                      } else {
                        return _buildLoadingIndicator();
                      }
                    },
                  );
                }

                // ✅ If follow-ups exist → show messages + follow-up section
                final lastAssistantMessage = assistantMessages.last;
                final followUps = lastAssistantMessage.followUps;

                return ListView(
                  controller: wealthController.scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    // All messages
                    ...wealthController.currentSession!.messages
                        .asMap()
                        .entries
                        .map((entry) => _buildMessage(entry.value, context,
                            entry.key)), // NEW: Pass index

                    if (wealthController.isLoading) ...[
                      _buildLoadingIndicator()
                    ] else ...[
                      if (wealthController.selectOptionType.value ==
                          'Answer') ...[
                        addHeight(12),
                        // Follow-up Section

                        if (followUps.isNotEmpty) ...[
                          SectionName(
                            title: 'Discover More Insights',
                            titleOnTap: '',
                            onTap: () {},
                          ),
                          addHeight(8)
                        ],
                        ...followUps.map(
                          (f) => GestureDetector(
                            onTap: () {
                              wealthController.messageController.text = f;
                              wealthController.handleMessageSubmit();
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(f)),
                                      addWidth(4),
                                      Icon(
                                        Icons.edit_square,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(thickness: 0.5, height: 2),
                              ],
                            ),
                          ),
                        )
                      ],
                    ]
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Message message, BuildContext context, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: message.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: message.isUser
                            ? EdgeInsets.all(marginSide(10))
                            : EdgeInsets.symmetric(
                                vertical: marginVertical(10), horizontal: 0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                              color: message.isUser
                                  ? Get.context!.gc(AppColor.primary)
                                  : Get.context!.gc(AppColor.transparent),
                              width: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: message.isUser
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  textWidget(
                                    context,
                                    title: "${message.text}",
                                    fontSize: responTextWidth(14),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: textWidget(context,
                                        title: "3:30",
                                        fontSize: responTextWidth(11),
                                        fontWeight: FontWeight.w300,
                                        color: context.gc(AppColor.grey)),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  if (wealthGenieController.isLoading) ...[
                                    buildAnalyze(message, context),
                                  ] else ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        buildChatOptions(
                                            messageIndex:
                                                index, // NEW: Pass index
                                            message: message,
                                            wealthController:
                                                wealthGenieController,
                                            title: 'Steps',
                                            icon: ImagePaths.steps),
                                        if (message.resources != null &&
                                            message.resources!.isNotEmpty) ...[
                                          addWidth(),
                                          buildChatOptions(
                                              messageIndex:
                                                  index, // NEW: Pass index
                                              message: message,
                                              wealthController:
                                                  wealthGenieController,
                                              title: 'Sources',
                                              icon: ImagePaths.wg2)
                                        ],
                                        addWidth(),
                                        buildChatOptions(
                                            messageIndex:
                                                index, // NEW: Pass index
                                            message: message,
                                            wealthController:
                                                wealthGenieController,
                                            title: 'Answer',
                                            icon: ImagePaths.wealthgenpng),
                                      ],
                                    ),
                                    addHeight(20),
                                  ],
                                  // NEW: Use per-message tab selection
                                  (wealthGenieController
                                              .getTabForMessage(index) ==
                                          'Steps')
                                      ? buildStepsTab(message, context)
                                      : (wealthGenieController
                                                  .getTabForMessage(index) ==
                                              'Sources')
                                          ? buildSourcesTab(message, context)
                                          : _buildMessageText(message, context),
                                ],
                              )),
                    if (message.isUser) ...[
                      addHeight(15),
                      _buildActionRow(message, message.text,
                          isUser: message.isUser),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStepsTab(Message message, BuildContext context) {
    String text = message.text.replaceAll('\\', '').trim();
    debugPrint('Debug print (before cleanup): $text');
    return AnalyzingCard();
  }

  Widget buildAnalyze(Message message, BuildContext context) {
    String text = message.text.replaceAll('\\', '').trim();
    debugPrint('Debug print (before cleanup): $text');
    if (text.startsWith('Finding best Answer')) {
      return AnalyzingStreamCard();
    }
    return Container();
  }

  Widget buildSourcesTab(Message message, BuildContext context) {
    return (message.resources != null && message.resources!.isNotEmpty)
        ? Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    textWidget(context,
                        title: "We have",
                        fontSize: responTextWidth(14),
                        fontWeight: FontWeight.w500,
                        color: context.gc(AppColor.white)),
                    textWidget(context,
                        title: " 2 Premium",
                        fontSize: responTextWidth(14),
                        fontWeight: FontWeight.w500,
                        color: Colors.amber),
                    textWidget(context,
                        title: " Sources related query",
                        fontSize: responTextWidth(14),
                        fontWeight: FontWeight.w500,
                        color: context.gc(AppColor.white)),
                    addWidth(8),
                    SizedBox(
                        height: 14,
                        width: 14,
                        child: Tooltip(
                          message: "We have 2 Premium Sources related query",
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                            size: 16,
                          ),
                        )),
                  ],
                ),
                (message.resources != null && message.resources!.isNotEmpty)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          addHeight(21),
                          ...message.resources!.map((r) => Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      print("Open: ${r.url}");
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image:
                                              AssetImage(ImagePaths.permcard),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      child: Container(
                                        height: 120,
                                        padding: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  EdgeInsets.only(right: 85),
                                              child: textWidget(
                                                context,
                                                title: "Source: ${r.title}",
                                                fontSize: responTextWidth(14),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            addHeight(6),
                                            textWidget(
                                              context,
                                              title: "No Description Availble.",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: responTextWidth(12),
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            addHeight(6),
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: context
                                                      .gc(AppColor.transparent),
                                                  backgroundImage: NetworkImage(
                                                      r.webfavicons),
                                                ),
                                                addWidth(4),
                                                textWidget(
                                                  context,
                                                  title: " ${r.extractDomain}",
                                                  fontSize: responTextWidth(11),
                                                  fontWeight: FontWeight.w300,
                                                ),
                                                Spacer(),
                                                textWidget(
                                                  context,
                                                  title:
                                                      "Source Credibility: High",
                                                  fontSize: responTextWidth(10),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  addHeight(12)
                                ],
                              )),
                        ],
                      )
                    : Container(),
              ],
            ),
          )
        : Container();
  }

  Widget _buildMessageText(Message message, BuildContext context) {
    String text = message.text.replaceAll('\\', '').trim();
    debugPrint('Debug print (before cleanup): $text');

    // ✅ Remove "Resources:" section if present
    if (text.contains("Resources:")) {
      text = text.split("Resources:").first.trim();
    }

    debugPrint('Debug print (after cleanup): $text');

    // 1️⃣ Detect analyzing
    if (text.startsWith('Finding best Answer')) {
      return Container();
    }

    // 6️⃣ Handle URLs (only if URLs are in main text, not Resources)
    final urlPattern = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );

    final urlMatches = urlPattern.allMatches(text);

    if (urlMatches.isNotEmpty) {
      debugPrint('Url ');
      return Column(
        children: [
          _buildUrlContent(text, urlMatches, context),
          addHeight(15),
          _buildActionRow(message, text),
        ],
      );
    }

    // 7️⃣ Default fallback: plain text
    print('Default');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
          data: extractVisibleText(text),
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: const TextStyle(color: Colors.white),
            strong: const TextStyle(color: Colors.white),
          ),
        ),
        addHeight(15),
        _buildActionRow(message, text),
      ],
    );
  }

  Widget _buildUrlContent(
      String text, Iterable<RegExpMatch> urlMatches, context) {
    List<Widget> widgets = [];
    int lastEnd = 0;

    for (var match in urlMatches) {
      final url = match.group(0)!;
      final matchStart = text.indexOf(url, lastEnd);
      final matchEnd = matchStart + url.length;

      if (matchStart >= lastEnd) {
        // Add preceding text
        if (matchStart > lastEnd) {
          debugPrint('Url chart ');

          widgets.add(MarkdownBody(
            data: extractVisibleText(text.substring(lastEnd, matchStart)),
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(
                    p: TextStyle(color: Colors.white),
                    strong: TextStyle(color: Colors.white)),
          ));
        }

        // Add clickable URL + preview
        if (url.startsWith('http://182') || url.startsWith('http://192')) {
          debugPrint('local Url chart ');
          widgets.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                addHeight(15),
                Obx(
                  () => Container(
                    height: wealthGenieController.webViewHeight.toDouble(),
                    child: WebViewScreen(
                      url: url,
                      onHeightChanged: (newHeight) {
                        // Update safely AFTER build
                        Future.microtask(() {
                          print('Chart Height: $newHeight');

                          wealthGenieController.webViewHeight.value = newHeight;
                          print(
                              'New Chart Height: ${wealthGenieController.webViewHeight.value}');
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          widgets.add(SelectableText(
            url,
            style: TextStyle(
                color: Colors.cyanAccent, decoration: TextDecoration.underline),
          ));
        }

        lastEnd = matchEnd;
      }
    }

    // Add trailing text after last URL
    if (lastEnd < text.length) {
      widgets.add(MarkdownBody(
        data: extractVisibleText(text.substring(lastEnd)),
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: TextStyle(color: Colors.white),
            strong: TextStyle(color: Colors.white)),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildActionRow(Message message, String text, {isUser = false}) {
    final controller = WealthGenieController.to;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(Get.context!).showSnackBar(
                  SnackBar(content: Text('Copied to clipboard')),
                );
              },
              child: Icon(Icons.copy, size: 16, color: Colors.grey),
            ),
            if (isUser) ...[
              addWidth(10),
              GestureDetector(
                onTap: () {
                  controller.messageController.text = text;
                  controller.handleMessageSubmit();
                },
                child:
                    Icon(Icons.replay_outlined, size: 16, color: Colors.grey),
              )
            ],
            if (!isUser) ...[
              addWidth(10),
              GestureDetector(
                onTap: () {
                  buildLike(controller);
                },
                child: Icon(Icons.thumb_up_alt_outlined,
                    size: 16, color: Colors.grey),
              ),
              addWidth(10),
              GestureDetector(
                onTap: () {
                  buildDislike(controller);
                },
                child: Icon(Icons.thumb_down_alt_outlined,
                    size: 16, color: Colors.grey),
              ),
            ],
          ],
        ),
      ],
    );
  }

  //For Like Bottom Sheet
  buildLike(WealthGenieController controller) {
    return showModalBottomSheet(
      backgroundColor: const Color(0xFF151515),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: marginSide(130),
                  child: Divider(
                    color: context.gc(AppColor.grey),
                    thickness: 3,
                  ),
                ),
              ),
              addHeight(12),
              Center(
                child: textWidget(context,
                    title: "Submit Feedback",
                    fontSize: responTextWidth(16),
                    fontWeight: FontWeight.w400,
                    color: context.gc(AppColor.white)),
              ),
              textWidget(context,
                  title: "Type",
                  fontSize: responTextWidth(14),
                  fontWeight: FontWeight.w400,
                  color: context.gc(AppColor.grey)),
              addHeight(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildFeedbackOption(
                      wealthController: controller, title: 'Average'),
                  addWidth(),
                  buildFeedbackOption(
                      wealthController: controller, title: 'Good'),
                  addWidth(),
                  buildFeedbackOption(
                      wealthController: controller, title: 'Excellent'),
                ],
              ),
              addHeight(12),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showToast('Feedback Submit Successfully!');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: context.gc(AppColor.primary),
                        borderRadius: BorderRadius.circular(8)),
                    child: textWidget(context,
                        title: "Submit",
                        fontSize: responTextWidth(12),
                        fontWeight: FontWeight.w500,
                        color: context.gc(AppColor.white)),
                  ),
                ),
              ),
              Spacer()
            ],
          ),
        );
      },
    );
  }

//For Dislike Bottom Sheet
  buildDislike(WealthGenieController controller) {
    return showModalBottomSheet(
      backgroundColor: const Color(0xFF151515),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(
          () => Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            height: (controller.selectedFeedback.value == 'Other') ? 400 : 270,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: marginSide(130),
                    child: Divider(
                      color: context.gc(AppColor.grey),
                      thickness: 3,
                    ),
                  ),
                ),
                addHeight(12),
                Center(
                  child: textWidget(context,
                      title: "Submit Feedback",
                      fontSize: responTextWidth(16),
                      fontWeight: FontWeight.w400,
                      color: context.gc(AppColor.white)),
                ),
                textWidget(context,
                    title: "Type",
                    fontSize: responTextWidth(14),
                    fontWeight: FontWeight.w400,
                    color: context.gc(AppColor.grey)),
                addHeight(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildFeedbackOption(
                        wealthController: controller,
                        title: 'Incomplete Response'),
                    addWidth(),
                    buildFeedbackOption(
                        wealthController: controller, title: 'Visualization'),
                    addWidth(),
                    buildFeedbackOption(
                        wealthController: controller, title: 'Not Correct'),
                  ],
                ),
                addHeight(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildFeedbackOption(
                        wealthController: controller,
                        title: 'Did not follow request'),
                    addWidth(),
                    buildFeedbackOption(
                        wealthController: controller, title: 'Other'),
                  ],
                ),
                if (controller.selectedFeedback.value == 'Other') ...[
                  addHeight(),
                  textWidget(context,
                      title: "Provide feedback detail",
                      fontSize: responTextWidth(14),
                      fontWeight: FontWeight.w400,
                      color: context.gc(AppColor.grey)),
                  addHeight(),
                  TextFormField(
                    maxLines: 3,
                    controller: controller.feedbackdescription,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Get.context!.gc(AppColor.white)),
                    decoration: inputDecoration(
                        Get.context!, 'Enter the detail regarding feedback'),
                  ),
                ],
                addHeight(12),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showToast('Feedback Submit Successfully!');
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: context.gc(AppColor.primary),
                          borderRadius: BorderRadius.circular(8)),
                      child: textWidget(context,
                          title: "Submit",
                          fontSize: responTextWidth(12),
                          fontWeight: FontWeight.w500,
                          color: context.gc(AppColor.white)),
                    ),
                  ),
                ),
                Spacer()
              ],
            ),
          ),
        );
      },
    );
  }

  //For Like Bottom Sheet
  buildSelectAgent(WealthGenieController controller) {
    return showModalBottomSheet(
      backgroundColor: const Color(0xFF151515),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(
          () => Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            height: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: textWidget(context,
                      title: "Select Agent",
                      fontSize: responTextWidth(16),
                      fontWeight: FontWeight.w500,
                      color: context.gc(AppColor.white)),
                ),
                addHeight(21),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: buildFeatOption(
                          wealthController: controller,
                          title: 'Accountant',
                          icon: ImagePaths.wg7),
                    ),
                    addWidth(11),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: buildFeatOption(
                          wealthController: controller,
                          title: 'Crypto',
                          icon: ImagePaths.wg6),
                    ),
                    addWidth(11),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: buildFeatOption(
                          wealthController: controller,
                          title: 'Stock',
                          icon: ImagePaths.wg3),
                    ),
                  ],
                ),
                addHeight(11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildFeatOption(
                        onTap: () {
                          setState(() {});
                          controller.setSelectedIncomeType('Html');
                          controller.messageController.text = "@Build Mode ";
                          controller.selectMsgType.value =
                              controller.messageController.text;

                          Get.back();
                        },
                        wealthController: controller,
                        title: 'Build Mode',
                        icon: ImagePaths.wg8),
                  ],
                ),
                Spacer()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(WealthGenieController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(children: [
        Expanded(
          child: TextFormField(
            minLines: 1,
            maxLines: 3,
            controller: controller.messageController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Get.context!.gc(AppColor.white)),
            decoration: inputDecoration(
              Get.context!,
              'Ask Wealth Genie....',
              suffixIcon: GestureDetector(
                onTap: () {
                  // print('Dilog');
                  buildSelectAgent(controller);
                },
                child: Icon(
                  Icons.tune, // You can use any icon
                  color: Colors.white, // Change color if needed
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            if (!controller.isLoading) {
              // if (controller.selectedIncomeType == 'Text') {
              controller.handleMessageSubmit();
              // } else {
              //   controller.handleHtmlCheck();
              // }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: (!controller.isLoading)
                    ? [
                        Color.fromRGBO(46, 173, 165, 1),
                        Color.fromRGBO(48, 107, 103, 1),
                      ]
                    : [Color(0xFF3d3d3d), Color(0xFF3d3d3d)],
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: !controller.isLoading
                ? Icon(Icons.send, color: Colors.white, size: 20)
                : Icon(Icons.stop, color: Colors.white, size: 20),
          ),
        )
      ]),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D796D)),
        ),
      ),
    );
  }
}
