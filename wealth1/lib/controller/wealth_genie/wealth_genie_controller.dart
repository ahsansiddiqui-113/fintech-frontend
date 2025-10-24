import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wealthnx/models/wealth_genie/chat_message_model.dart';
import 'package:wealthnx/models/wealth_genie/session_history_model.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

enum FeedbackOption {
  incompleteResponse,
  visualization,
  notCorrect,
  didNotFollowRequest,
  other,
}

class WealthGenieController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static WealthGenieController get to => Get.find();

  // State variables
  final RxInt _selectedIndex = 0.obs;
  final RxBool _hasMessages = false.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isWebViewVisible = false.obs;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController feedbackdescription = TextEditingController();
  final TextEditingController agentType = TextEditingController();
  final TextEditingController focusNodeDashboard = TextEditingController();
  final ScrollController scrollController = ScrollController();
  AnimationController? logoAnimationController;
  late WebViewController webViewController;

  final RxList<ChatSession> _chatSessions = <ChatSession>[].obs;
  final Rxn<ChatSession> _currentSession = Rxn<ChatSession>();

  final RxString _userId = ''.obs;
  final RxString selectMsgType = ''.obs;
  final RxString _selectedIncomeType = 'Text'.obs;
  final RxString selectOptionType = ''.obs;
  final RxString _selectedModel = 'qwen3:8b'.obs;
  final RxString uId = ''.obs;
  final RxString sessionMsgId = ''.obs;
  final RxBool _isHistoryExpanded = true.obs;
  final RxDouble webViewHeight = 1500.0.obs;
  RxList<SessionHistoryModel> sessions = <SessionHistoryModel>[].obs;
  final RxBool isLoadSession = false.obs;

  RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  RxBool isLoadChat = false.obs;

  // NEW: Track selected tab for each message by index
  final RxMap<int, String> selectedTabs = <int, String>{}.obs;

  // Getters
  int get selectedIndex => _selectedIndex.value;
  bool get hasMessages => _hasMessages.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadHistory => isLoadSession.value;
  bool get isWebViewVisible => _isWebViewVisible.value;
  List<ChatSession> get chatSessions => _chatSessions;
  ChatSession? get currentSession => _currentSession.value;
  String? get userId => _userId.value;
  String get selectedIncomeType => _selectedIncomeType.value;
  String get selectedModel => _selectedModel.value;
  bool get isHistoryExpanded => _isHistoryExpanded.value;

  final RxString selectedFeedback = ''.obs; // Feedback

  @override
  void onInit() {
    super.onInit();
    WakelockPlus.enable(); // ✅ Keeps the screen on as soon as controller starts
    _initializeController();
  }

  void _initializeController() async {
    messageController.text = "";
    _hasMessages.value = false;
    sessionMsgId.value = generateSessionId();

    print('Session Id Data: ${sessionMsgId.value}');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('newSessionId', sessionMsgId.value.toString());

    startNewSession();
    loadUserId();
    loadChatSessions();
    fetchUserId();
  }

  @override
  void onClose() {
    WakelockPlus.disable(); // ✅ Allow normal screen timeout when leaving
    logoAnimationController?.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void resetController() {
    _initializeController();
  }

  // NEW: Set tab for a specific message
  void setTabForMessage(int messageIndex, String tabName) {
    selectedTabs[messageIndex] = tabName;
    update();
  }

  // NEW: Get tab for a specific message
  String getTabForMessage(int messageIndex) {
    return selectedTabs[messageIndex] ?? 'Answer'; // Default to 'Answer'
  }

  // Wealth Genie History Session
  Future<void> fetchSessions() async {
    try {
      isLoadSession(true);
      final url = Uri.parse(
          "http://182.188.29.93:5000/api/sessions?user_id=${_userId}");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['sessions'];

        print('Session Data: ${data}');

        sessions.value =
            data.map((e) => SessionHistoryModel.fromJson(e)).toList();

        print('Session Chkk: ${sessions}');
      }
    } catch (e) {
      print('Fetch Error: $e');

      isLoadSession(false);
    } finally {
      isLoadSession(false);
    }
  }

  // Get Session Messages
  Future<void> fetchSessionMessages(String? sessionId) async {
    try {
      isLoadChat(true);
      _hasMessages.value = true;
      _isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('newSessionId', sessionId.toString());

      final url = Uri.parse(
          "http://182.188.29.93:5000/api/session/${sessionId}/messages");

      final response = await http.get(url);

      print('Fetch Messages Status: ${response.statusCode}');
      print('Fetch Messages Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            json.decode(response.body)['messages'] ?? [];

        messages.value =
            jsonList.map((e) => ChatMessageModel.fromJson(e)).toList();

        // Clear loading placeholder messages if any
        _isLoading.value = false;
        _currentSession.value?.messages
            .removeWhere((msg) => msg.text.startsWith('Finding best Answer'));
        _isLoading.value = false;

        // Remove all old assistant messages
        _currentSession.value?.messages
            .removeWhere((msg) => msg.userRole == 'assistant');
        _currentSession.value?.messages
            .removeWhere((msg) => msg.userRole == 'user');

        // Add each API message to current session message list
        for (var m in messages) {
          _currentSession.value?.messages.add(
            Message(
              text: m.content,
              isUser: m.role == "user",
              userRole: m.role,
              followUps: m.followUps.isNotEmpty ? m.followUps : [],
              resources: m.resources ?? [],
            ),
          );
        }

        scrollToBottom();
        saveChatSessions();

        //History refresh
        fetchSessions();
      } else {
        print('Error fetching messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching messages: $e');
    } finally {
      isLoadChat(false);
    }
  }

  //-----User id update
  Future<void> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final userId = prefs.getString('userId');

    print('Token $authToken');
    print('Token $userId');

    uId.value = userId ?? '';
    print('Check Token ${uId.value}');

    if (authToken == null || userId == null) {
      print(
          'ERROR: No auth token or userId available for fetching transactions');
      return;
    }
  }

  void startNewSession() {
    final newSession = ChatSession(
      DateTime.now().millisecondsSinceEpoch.toString(),
      [],
    );
    _chatSessions.add(newSession);
    _currentSession.value = newSession;
    _hasMessages.value = false;
    selectedTabs.clear(); // NEW: Clear tab selections for new session
  }

  Future<void> handleMessageSubmit() async {
    final userMessageText = messageController.text.trim();
    if (userMessageText.isEmpty) return;

    _hasMessages.value = true;
    _isLoading.value = true;

    // Add user message
    _currentSession.value?.messages
        .add(Message(text: userMessageText, isUser: true, userRole: 'write'));

    // Add assistant placeholder message
    _currentSession.value?.messages.add(Message(
        text:
            'Finding best Answer...\n• Checking the real information align with query\n• Real Time Data\n• Review real time data for ada\n• Finding Sources & Citations for investment related to ada\n• Hallucination Checking',
        isUser: false,
        userRole: 'assistant'));

    // NEW: Set default tab for the new assistant message
    final assistantMessageIndex = _currentSession.value!.messages.length - 1;
    selectedTabs[assistantMessageIndex] = 'Answer';

    messageController.clear();
    scrollToBottom();

    final effectiveUserId = _userId.value ?? "anonymous";

    try {
      fetchApiResponse(
        userMessageText,
        effectiveUserId,
        _selectedModel.value,
      );
    } catch (e) {
      _isLoading.value = false;
      _currentSession.value?.messages
          .removeWhere((msg) => msg.text.startsWith('Finding best Answer'));
      _currentSession.value?.messages.add(Message(
          text: 'Error: Failed to get response. $e',
          isUser: false,
          userRole: 'assistant'));
      scrollToBottom();
      saveChatSessions();
    }
  }

  Future<void> saveChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      _chatSessions.map((session) => session.toJson()).toList(),
    );
    await prefs.setString('chat_sessions', jsonString);
  }

  Future<void> loadChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('chat_sessions');

    if (jsonString != null) {
      final List<dynamic> data = jsonDecode(jsonString);
      final loadedSessions = data
          .map((json) => ChatSession.fromJson(json as Map<String, dynamic>))
          .toList();

      _chatSessions.assignAll(loadedSessions);
      if (_chatSessions.isNotEmpty) {
        _currentSession.value = _chatSessions.last;
        _hasMessages.value = _currentSession.value!.messages.isNotEmpty;

        // NEW: Initialize tab selections for all loaded messages
        for (int i = 0; i < _currentSession.value!.messages.length; i++) {
          if (!_currentSession.value!.messages[i].isUser) {
            selectedTabs[i] = 'Answer'; // Default tab for assistant messages
          }
        }
      }
    }
  }

  Future<void> fetchApiResponse(
      String message, String userId, String model) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      sessionMsgId.value = prefs.getString('newSessionId').toString();

      if (sessionMsgId.value == null || sessionMsgId.value == '') {
        print('Session Id is not available!');
        return;
      }

      final response = await http.post(
        Uri.parse('http://182.188.29.93:5000/api/chat'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          "query": message,
          "user_id": userId,
          "session_id": '$sessionMsgId'
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _currentSession.value?.messages
            .removeWhere((msg) => msg.text.startsWith(message));

        fetchSessionMessages(sessionMsgId.value);
      } else {
        print('Error: Server responded with status ${response.statusCode}.');
      }
    } catch (e) {
      print('Error in fetchApiResponse: $e');
    }
  }

  Future<void> handleHtmlCheck() async {
    final query = messageController.text.trim();

    if (query.isEmpty) return;

    _hasMessages.value = true;
    _isLoading.value = true;
    _currentSession.value?.messages.add(
      Message(text: "$query", isUser: true, userRole: 'user'),
    );

    scrollToBottom();
    messageController.clear();

    _currentSession.value?.messages.add(Message(
        text:
            'Finding best Answer...\n• Checking the real information align with query\n• Real Time Data\n• Review real time data for ada\n• Finding Sources & Citations for investment related to ada\n• Hallucination Checking',
        isUser: false,
        userRole: 'assistant'));

    // NEW: Set default tab for the new assistant message
    final assistantMessageIndex = _currentSession.value!.messages.length - 1;
    selectedTabs[assistantMessageIndex] = 'Answer';

    try {
      print('Sending HTML check request to: http://182.191.94.19:5005/chat');
      print(
          'Request body: {"query": "$query", "user_id": "${_userId.value ?? "anonymous"}"}');

      final response = await http.post(
        Uri.parse('http://182.191.94.19:5005/chat'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "query": query,
          "user_id": _userId.value ?? "anonymous",
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      _currentSession.value?.messages
          .removeWhere((msg) => msg.text.startsWith('Finding best Answer'));

      if (response.statusCode == 200) {
        String responseMessage = '';

        try {
          final data = jsonDecode(response.body);
          print('Successfully parsed JSON: $data');

          if (data is Map<String, dynamic>) {
            if (data.containsKey('file_url')) {
              final url = data['file_url'];
              responseMessage = '$url';
            } else if (data.containsKey('link')) {
              responseMessage = data['link'].toString();
            } else if (data.containsKey('result')) {
              responseMessage = data['result'].toString();
            } else if (data.containsKey('message')) {
              responseMessage = data['message'].toString();
            } else if (data.containsKey('response')) {
              responseMessage = data['response'].toString();
            } else {
              responseMessage = 'API response: ${jsonEncode(data)}';
            }
          } else {
            responseMessage = data.toString();
          }
        } catch (e) {
          print('Error parsing JSON: $e');
          responseMessage = 'Raw API response: ${response.body}';
        }

        _currentSession.value?.messages.add(
          Message(text: responseMessage, isUser: false, userRole: 'assistant'),
        );
      } else {
        _currentSession.value?.messages.add(
          Message(
              text:
                  'Error: Server responded with status ${response.statusCode}.\nResponse: ${response.body}',
              isUser: false,
              userRole: 'assistant'),
        );
      }
    } catch (e) {
      print('Exception during HTML check: $e');

      _currentSession.value?.messages
          .removeWhere((msg) => msg.text.startsWith('Finding best Answer'));

      _currentSession.value?.messages.add(
        Message(
            text:
                'Error: Failed to connect to HTML check API. Please check your network connection.\nError details: $e',
            isUser: false,
            userRole: 'assistant'),
      );
    } finally {
      _isLoading.value = false;
      scrollToBottom();
      saveChatSessions();
    }
  }

  void showWebView(String content) {
    if (content.trim().startsWith('http')) {
      webViewController.loadRequest(Uri.parse(content));
    } else {
      webViewController.loadHtmlString(content);
    }

    _isWebViewVisible.value = true;
  }

  void hideWebView() {
    _isWebViewVisible.value = false;
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      userId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('userId', userId);
    }
    _userId.value = userId;
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void toggleHistoryExpanded() {
    _isHistoryExpanded.value = !_isHistoryExpanded.value;
  }

  void clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_sessions');

    selectMsgType.value = '';
    _chatSessions.clear();
    _currentSession.value = ChatSession('', []);
    _hasMessages.value = false;
    selectedTabs.clear(); // NEW: Clear tab selections
  }

  void setSelectedIncomeType(String value) {
    _selectedIncomeType.value = value;
  }

  // Generate Random Session id's
  String generateSessionId() {
    const chars = 'abcdef0123456789';
    final rand = Random.secure();
    return List.generate(24, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }
}

class ChatSession {
  final String id;
  final List<Message> messages;

  ChatSession(this.id, this.messages);

  Map<String, dynamic> toJson() => {
        'id': id,
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      json['id'],
      (json['messages'] as List)
          .map((msgJson) => Message.fromJson(msgJson as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Message {
  final String text;
  final String userRole;
  final bool isUser;
  final List<String> followUps;
  final List<ResourceLink>? resources;

  Message({
    required this.text,
    required this.isUser,
    required this.userRole,
    this.followUps = const [],
    this.resources,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'userRole': userRole,
      'isUser': isUser,
      'followUps': followUps,
      'resources': resources?.map((e) => e.toJson()).toList(),
    };
  }

  // Message.fromJson
  factory Message.fromJson(Map<String, dynamic> json) {
    List<String> followUpsList = [];
    if (json['followUps'] != null) {
      if (json['followUps'] is List) {
        followUpsList = (json['followUps'] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      } else if (json['followUps'] is Map) {
        followUpsList = (json['followUps'] as Map<String, dynamic>)
            .values
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      }
    }

    List<ResourceLink>? resourceList;
    if (json['resources'] != null && json['resources'] is List) {
      resourceList = (json['resources'] as List)
          .map((e) => ResourceLink.fromJson(e))
          .toList();
    }

    return Message(
      text: json['text'] ?? '',
      userRole: json['userRole'] ?? '',
      isUser: json['isUser'] ?? false,
      followUps: followUpsList,
      resources: resourceList,
    );
  }
}

class PreviewData {
  final String? title;
  final String? description;
  final String? image;

  PreviewData({this.title, this.description, this.image});
}
