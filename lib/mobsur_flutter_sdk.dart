library mobsur_flutter_sdk;

import 'dart:convert' as convert;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MobSurSDK {
  static final MobSurSDK _instance = MobSurSDK._internal();

  static const String _domain = 'api.mobsur.com';
  static const String _path = 'api/surveys';
  static const String _cacheKey = 'MobSurSurveysCache';

  factory MobSurSDK() {
    return _instance;
  }

  MobSurSDK._internal() {
    // initialize();
  }

  String? _appID;
  String? _clientID;

  final bool _launched = false;

  SurveysData? _data;

  SharedPreferences? _prefs;

  PackageInfo? _packageInfo;

  void setup(String appID, String? clientID) async {
    _prefs = await SharedPreferences.getInstance();
    _packageInfo = await PackageInfo.fromPlatform();

    _appID = appID;

    if (clientID != null && clientID.isNotEmpty) {
      _clientID = clientID;

      _fetchData();
    }
  }

  void updateClientId(String clientID) async {
    if (clientID.isNotEmpty) {
      _clientID = clientID;

      _fetchData();
    }
  }

  void logEvent(String name, BuildContext context) async {
    var surveys = availableSurveys() ?? [];

    if (surveys.isEmpty) {
      return;
    }

    for (Survey survey in surveys) {
      if (!survey.isValid()) {
        continue;
      }

      for (SurveyRule rule in survey.rules) {
        if (rule.type != 'counted_event') {
          continue;
        }

        if (rule.name == name) {
          var delay = Duration(milliseconds: rule.delay);
          Future.delayed(delay, () {
            _showBottomSheet(context, survey);
          });
        }
      }
    }
  }

  void _showBottomSheet(BuildContext context, Survey survey) {
    final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
      Factory(() => EagerGestureRecognizer())
    };
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) =>
              _navigationHandler(survey, request, context),
        ),
      );
    controller.loadRequest(Uri.parse(survey.url));
    UniqueKey key = UniqueKey();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        builder: (context) => Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: Color(0xFEFFFAFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )),
                  child: Row(
                    children: [
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close))
                    ],
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9 - 50,
                    width: MediaQuery.of(context).size.width,
                    child: WebViewWidget(
                      key: key,
                      gestureRecognizers: gestureRecognizers,
                      controller: controller,
                    ))
              ],
            ));
  }

  NavigationDecision _navigationHandler(
      Survey survey, NavigationRequest request, BuildContext context) {
    if (request.url.contains('#close')) {
      _data?.data.removeWhere((element) => element.id == survey.id);
      Navigator.pop(context);

      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _fetchData() async {
    if (_appID == null ||
        _appID!.isEmpty ||
        _clientID == null ||
        _clientID!.isEmpty) {
      return;
    }

    var platform = Platform.operatingSystem;

    var url = Uri.https(_domain, _path, {
      'app_id': _appID!,
      'user_reference_id': _clientID!,
      'platform': platform,
      'app_version': _packageInfo?.version ?? '',
    });

    var response =
        await http.get(url, headers: {'Accept-Language': Platform.localeName});

    if (response.statusCode != 200) {
      // TODO: Log error
      return;
    }

    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    _data = SurveysData.fromJson(jsonResponse);

    _prefs?.setString(_cacheKey, response.body);
  }

  List<Survey>? availableSurveys() {
    if (_data != null) {
      return _data?.data;
    }
    String? responseString = _prefs?.getString(_cacheKey);

    if (responseString == null) {
      return null;
    }

    var jsonResponse =
        convert.jsonDecode(responseString) as Map<String, dynamic>;
    _data = SurveysData.fromJson(jsonResponse);

    return _data?.data;
  }
}

class SurveysData {
  final List<Survey> data;

  SurveysData({required this.data});

  factory SurveysData.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    var data = list.map((e) => Survey.fromJson(e)).toList();

    return SurveysData(data: data);
  }

  Map<String, dynamic> toJson() => {'data': data.map((e) => e.toJson())};
}

class Survey {
  final int id;
  final String url;
  final DateTime startDate;
  final DateTime endDate;
  final List<SurveyRule> rules;

  Survey({
    required this.id,
    required this.url,
    required this.startDate,
    required this.endDate,
    required this.rules,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    var rules = json['rules'] as List;

    return Survey(
        id: json['id'],
        url: json['url'],
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        rules: rules.map((e) => SurveyRule.fromJson(e)).toList());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'rules': rules.map((e) => e.toJson())
      };

  bool isValid() {
    DateTime now = DateTime.now();

    return startDate.isBefore(now) && endDate.isAfter(now);
  }
}

class SurveyRule {
  final String type;
  final String name;
  final int delay;
  final int? occurred;

  SurveyRule({
    required this.type,
    required this.name,
    required this.delay,
    this.occurred,
  });

  factory SurveyRule.fromJson(Map<String, dynamic> json) {
    return SurveyRule(
        type: json['type'],
        name: json['name'],
        delay: json['delay'] ?? 0,
        occurred: json['occurred']);
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'delay': delay,
        'occurred': occurred,
      };
}
