import 'package:http/http.dart' as http;
import 'package:wealthnx/utils/app_helper.dart';
import 'package:html/parser.dart' as html_parser;

class ChatMessageModel {
  final String content;
  final String role;
  final DateTime timestamp;
  final List<String> followUps;
  final List<ResourceLink>? resources;

  ChatMessageModel({
    required this.content,
    required this.role,
    required this.timestamp,
    required this.followUps,
    this.resources,
  });

  // ChatMessageModel.fromJson
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    List<String> followUpsList = [];

    if (json['follow_ups'] != null) {
      if (json['follow_ups'] is Map<String, dynamic>) {
        followUpsList = (json['follow_ups'] as Map<String, dynamic>)
            .values
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty) // 🚀 filter empty strings
            .toList();
      } else if (json['follow_ups'] is List) {
        followUpsList = (json['follow_ups'] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      }
    }

    return ChatMessageModel(
      content: json['content'] ?? '',
      role: json['role'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      followUps: followUpsList,
      resources: parseResources(json['content'] ?? ''),
    );
  }
}

class ResourceLink {
  final String url;
  String? title;
  String? description;
  String? favicon;

  ResourceLink({
    required this.url,
    this.title,
    this.description,
    this.favicon,
  });

  factory ResourceLink.fromJson(Map<String, dynamic> json) {
    return ResourceLink(
      url: json['url'] ?? '',
      title: json['title'],
      description: json['description'],
      favicon: json['favicon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'description': description,
      'favicon': favicon,
    };
  }

  /// Extracts website domain only (like `investing.com`)
  String get websiteName {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst("www.", "");
    } catch (e) {
      return "";
    }
  }

  /// ✅ Generate favicon URL from the resource link
  String get webfavicons {
    try {
      final uri = Uri.parse(url);
      return "https://www.google.com/s2/favicons?sz=64&domain_url=${uri.scheme}://${uri.host}";
    } catch (e) {
      return "";
    }
  }

  /// ✅ Extract domain name from URL
  String get extractDomain {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst("www.", "");
    } catch (e) {
      return url;
    }
  }

  /// ✅ Fetch title, description, and favicon from the URL
  Future<void> fetchMetadata() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Title
        title = document.querySelector('title')?.text ?? websiteName;

        // Description
        description = document
                .querySelector('meta[name="description"]')
                ?.attributes['content'] ??
            document
                .querySelector('meta[property="og:description"]')
                ?.attributes['content'] ??
            '';

        // Favicon (prefer site-defined, fallback to Google API)
        final faviconHref =
            document.querySelector('link[rel="icon"]')?.attributes['href'] ??
                document
                    .querySelector('link[rel="shortcut icon"]')
                    ?.attributes['href'];

        if (faviconHref != null) {
          final uri = Uri.parse(url);
          favicon = faviconHref.startsWith("http")
              ? faviconHref
              : "${uri.scheme}://${uri.host}$faviconHref";
        } else {
          final uri = Uri.parse(url);
          favicon =
              "https://www.google.com/s2/favicons?sz=64&domain_url=${uri.scheme}://${uri.host}";
        }
      }
    } catch (e) {
      print("Error fetching metadata for $url: $e");
    }
  }
}
