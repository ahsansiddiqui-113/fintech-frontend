class CryptoCoinDetailsInfoModel {
  final String? id;
  final String? symbol;
  final String? name;
  final String? webSlug;
  final dynamic assetPlatformId;
  final Platforms? platforms;
  final DetailPlatforms? detailPlatforms;
  final int? blockTimeInMinutes;
  final String? hashingAlgorithm;
  final List<String>? categories;
  final bool? previewListing;
  final dynamic publicNotice;
  final List<dynamic>? additionalNotices;
  final Description? description;
  final Links? links;
  final Image? image;
  final String? countryOrigin;
  final DateTime? genesisDate;
  final double? sentimentVotesUpPercentage;
  final double? sentimentVotesDownPercentage;
  final int? watchlistPortfolioUsers;
  final int? marketCapRank;
  final List<dynamic>? statusUpdates;
  final DateTime? lastUpdated;

  CryptoCoinDetailsInfoModel({
    this.id,
    this.symbol,
    this.name,
    this.webSlug,
    this.assetPlatformId,
    this.platforms,
    this.detailPlatforms,
    this.blockTimeInMinutes,
    this.hashingAlgorithm,
    this.categories,
    this.previewListing,
    this.publicNotice,
    this.additionalNotices,
    this.description,
    this.links,
    this.image,
    this.countryOrigin,
    this.genesisDate,
    this.sentimentVotesUpPercentage,
    this.sentimentVotesDownPercentage,
    this.watchlistPortfolioUsers,
    this.marketCapRank,
    this.statusUpdates,
    this.lastUpdated,
  });

  factory CryptoCoinDetailsInfoModel.fromJson(Map<String, dynamic> json) =>
      CryptoCoinDetailsInfoModel(
        id: json["id"],
        symbol: json["symbol"],
        name: json["name"],
        webSlug: json["web_slug"],
        assetPlatformId: json["asset_platform_id"],
        platforms: json["platforms"] == null
            ? null
            : Platforms.fromJson(json["platforms"]),
        detailPlatforms: json["detail_platforms"] == null
            ? null
            : DetailPlatforms.fromJson(json["detail_platforms"]),
        blockTimeInMinutes: json["block_time_in_minutes"],
        hashingAlgorithm: json["hashing_algorithm"],
        categories: json["categories"] == null
            ? []
            : List<String>.from(json["categories"]!.map((x) => x)),
        previewListing: json["preview_listing"],
        publicNotice: json["public_notice"],
        additionalNotices: json["additional_notices"] == null
            ? []
            : List<dynamic>.from(json["additional_notices"]!.map((x) => x)),
        description: json["description"] == null
            ? null
            : Description.fromJson(json["description"]),
        links: json["links"] == null ? null : Links.fromJson(json["links"]),
        image: json["image"] == null ? null : Image.fromJson(json["image"]),
        countryOrigin: json["country_origin"],
        genesisDate: json["genesis_date"] == null
            ? null
            : DateTime.parse(json["genesis_date"]),
        sentimentVotesUpPercentage:
            json["sentiment_votes_up_percentage"]?.toDouble(),
        sentimentVotesDownPercentage:
            json["sentiment_votes_down_percentage"]?.toDouble(),
        watchlistPortfolioUsers: json["watchlist_portfolio_users"],
        marketCapRank: json["market_cap_rank"],
        statusUpdates: json["status_updates"] == null
            ? []
            : List<dynamic>.from(json["status_updates"]!.map((x) => x)),
        lastUpdated: json["last_updated"] == null
            ? null
            : DateTime.parse(json["last_updated"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "web_slug": webSlug,
        "asset_platform_id": assetPlatformId,
        "platforms": platforms?.toJson(),
        "detail_platforms": detailPlatforms?.toJson(),
        "block_time_in_minutes": blockTimeInMinutes,
        "hashing_algorithm": hashingAlgorithm,
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x)),
        "preview_listing": previewListing,
        "public_notice": publicNotice,
        "additional_notices": additionalNotices == null
            ? []
            : List<dynamic>.from(additionalNotices!.map((x) => x)),
        "description": description?.toJson(),
        "links": links?.toJson(),
        "image": image?.toJson(),
        "country_origin": countryOrigin,
        "genesis_date":
            "${genesisDate!.year.toString().padLeft(4, '0')}-${genesisDate!.month.toString().padLeft(2, '0')}-${genesisDate!.day.toString().padLeft(2, '0')}",
        "sentiment_votes_up_percentage": sentimentVotesUpPercentage,
        "sentiment_votes_down_percentage": sentimentVotesDownPercentage,
        "watchlist_portfolio_users": watchlistPortfolioUsers,
        "market_cap_rank": marketCapRank,
        "status_updates": statusUpdates == null
            ? []
            : List<dynamic>.from(statusUpdates!.map((x) => x)),
        "last_updated": lastUpdated?.toIso8601String(),
      };
}

class Description {
  final String? en;

  Description({
    this.en,
  });

  factory Description.fromJson(Map<String, dynamic> json) => Description(
        en: json["en"],
      );

  Map<String, dynamic> toJson() => {
        "en": en,
      };
}

class DetailPlatforms {
  final EmptyCrp? empty;

  DetailPlatforms({
    this.empty,
  });

  factory DetailPlatforms.fromJson(Map<String, dynamic> json) =>
      DetailPlatforms(
        empty: json[""] == null ? null : EmptyCrp.fromJson(json[""]),
      );

  Map<String, dynamic> toJson() => {
        "": empty?.toJson(),
      };
}

class EmptyCrp {
  final dynamic decimalPlace;
  final String? contractAddress;

  EmptyCrp({
    this.decimalPlace,
    this.contractAddress,
  });

  factory EmptyCrp.fromJson(Map<String, dynamic> json) => EmptyCrp(
        decimalPlace: json["decimal_place"],
        contractAddress: json["contract_address"],
      );

  Map<String, dynamic> toJson() => {
        "decimal_place": decimalPlace,
        "contract_address": contractAddress,
      };
}

class Image {
  final String? thumb;
  final String? small;
  final String? large;

  Image({
    this.thumb,
    this.small,
    this.large,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        thumb: json["thumb"],
        small: json["small"],
        large: json["large"],
      );

  Map<String, dynamic> toJson() => {
        "thumb": thumb,
        "small": small,
        "large": large,
      };
}

class Links {
  final List<String>? homepage;
  final String? whitepaper;
  final List<String>? blockchainSite;
  final List<String>? officialForumUrl;
  final List<dynamic>? chatUrl;
  final List<dynamic>? announcementUrl;
  final dynamic snapshotUrl;
  final String? twitterScreenName;
  final String? facebookUsername;
  final dynamic bitcointalkThreadIdentifier;
  final String? telegramChannelIdentifier;
  final String? subredditUrl;
  final ReposUrl? reposUrl;

  Links({
    this.homepage,
    this.whitepaper,
    this.blockchainSite,
    this.officialForumUrl,
    this.chatUrl,
    this.announcementUrl,
    this.snapshotUrl,
    this.twitterScreenName,
    this.facebookUsername,
    this.bitcointalkThreadIdentifier,
    this.telegramChannelIdentifier,
    this.subredditUrl,
    this.reposUrl,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        homepage: json["homepage"] == null
            ? []
            : List<String>.from(json["homepage"]!.map((x) => x)),
        whitepaper: json["whitepaper"],
        blockchainSite: json["blockchain_site"] == null
            ? []
            : List<String>.from(json["blockchain_site"]!.map((x) => x)),
        officialForumUrl: json["official_forum_url"] == null
            ? []
            : List<String>.from(json["official_forum_url"]!.map((x) => x)),
        chatUrl: json["chat_url"] == null
            ? []
            : List<dynamic>.from(json["chat_url"]!.map((x) => x)),
        announcementUrl: json["announcement_url"] == null
            ? []
            : List<dynamic>.from(json["announcement_url"]!.map((x) => x)),
        snapshotUrl: json["snapshot_url"],
        twitterScreenName: json["twitter_screen_name"],
        facebookUsername: json["facebook_username"],
        bitcointalkThreadIdentifier: json["bitcointalk_thread_identifier"],
        telegramChannelIdentifier: json["telegram_channel_identifier"],
        subredditUrl: json["subreddit_url"],
        reposUrl: json["repos_url"] == null
            ? null
            : ReposUrl.fromJson(json["repos_url"]),
      );

  Map<String, dynamic> toJson() => {
        "homepage":
            homepage == null ? [] : List<dynamic>.from(homepage!.map((x) => x)),
        "whitepaper": whitepaper,
        "blockchain_site": blockchainSite == null
            ? []
            : List<dynamic>.from(blockchainSite!.map((x) => x)),
        "official_forum_url": officialForumUrl == null
            ? []
            : List<dynamic>.from(officialForumUrl!.map((x) => x)),
        "chat_url":
            chatUrl == null ? [] : List<dynamic>.from(chatUrl!.map((x) => x)),
        "announcement_url": announcementUrl == null
            ? []
            : List<dynamic>.from(announcementUrl!.map((x) => x)),
        "snapshot_url": snapshotUrl,
        "twitter_screen_name": twitterScreenName,
        "facebook_username": facebookUsername,
        "bitcointalk_thread_identifier": bitcointalkThreadIdentifier,
        "telegram_channel_identifier": telegramChannelIdentifier,
        "subreddit_url": subredditUrl,
        "repos_url": reposUrl?.toJson(),
      };
}

class ReposUrl {
  final List<String>? github;
  final List<dynamic>? bitbucket;

  ReposUrl({
    this.github,
    this.bitbucket,
  });

  factory ReposUrl.fromJson(Map<String, dynamic> json) => ReposUrl(
        github: json["github"] == null
            ? []
            : List<String>.from(json["github"]!.map((x) => x)),
        bitbucket: json["bitbucket"] == null
            ? []
            : List<dynamic>.from(json["bitbucket"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "github":
            github == null ? [] : List<dynamic>.from(github!.map((x) => x)),
        "bitbucket": bitbucket == null
            ? []
            : List<dynamic>.from(bitbucket!.map((x) => x)),
      };
}

class Platforms {
  final String? empty;

  Platforms({
    this.empty,
  });

  factory Platforms.fromJson(Map<String, dynamic> json) => Platforms(
        empty: json[""],
      );

  Map<String, dynamic> toJson() => {
        "": empty,
      };
}
