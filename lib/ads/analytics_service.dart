import 'package:firebase_analytics/firebase_analytics.dart';

import '../utils/app_constants.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalytics
  analytics = FirebaseAnalytics.instance;

  static final FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics:
  analytics);

  static Future<void> logEvent({
    required String eventName,
    Map<String, Object>? parameters, // Change dynamic to Object
  }) async {
    try {
      await
      analytics.logEvent(

        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      showLog("Error logging event: $e");
    }
  }
}