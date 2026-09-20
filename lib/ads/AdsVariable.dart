import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/globalVariables.dart';


class AdsVariable {

  static bool isPrivacyOptionsRequired = false;
  static String ca_splash_interstitialAd = "11";
  static String ca_pre_interstitialAd = "11";
  static String ca_normal_openAd = "11";
  static String ca_language_nativeAd = "11";
  static String ca_full_nativeAd = "11";


  static String ca_rewardedAd = "11";

  static String ca_nativeBgColor = "000000";
  static String ca_headlineTxtColor = "FFFFFF";
  static String ca_bodyTxtColor = "FFFFFF";
  static String ca_buttonBgColor_start = "0477BF";
  static String ca_buttonBgColor_end = "0477BF";
  static String ca_buttonTextColor = "0477BF";
  static int ca_free_coin = 0;
  static int ca_rewared_credit = 0;
  static int ca_week_bonus_coin = 0;
  static int ca_month_bonus_coin = 0;
  static int ca_first_plan_coin = 0;
  static int ca_second_plan_coin = 0;
  static int ca_reduce_coin_on_ai_lab_api = 0;
  static int ca_reduce_coin_on_gemini_api = 0;
  static bool ca_showRewardedAd_ai_lab_api = false;
  static bool ca_showRewaredAd_gemini_api = false;
  static String ca_tester_email = "eiuiwuefiuweb";
  static String ca_tester_password = "foeioi#oeiwfo";



  static int ca_click = 2;
  static int current_click = 0;

  static bool ca_showOpenAdInSplash = false;
  static String ca_gemini_api_key = "11";
  static String ca_ai_lab_tool_api = "11";

  static String week_plan_identifier = "charmai_weekly_premium:weekly";
  static String month_plan_identifier = "charmai_monthly_premium:monthly";


  static const versionKey = "json_version";

  static Future<int?> getVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(versionKey);
  }

  static Future<void> saveVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(versionKey, version);
  }



  //static NativeAd? homeAd;
  static NativeAd? languageAd;
  static NativeAd? subtopicNativeAd;
  static NativeAd? introFullAd;
  static NativeAd? quizNativeAd;
  static NativeAd? bookmarkNativeAd;
  static NativeAd? homeNativeAd;

  static AppOpenAd? appOpenAdInstance;
  static bool isShowingAd = false;

  static void getAdIdsFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    ca_splash_interstitialAd = prefs.getString("ca_splash_interstitialAd") ?? "11";
    ca_pre_interstitialAd = prefs.getString("ca_pre_interstitialAd") ?? "11";
    ca_normal_openAd = prefs.getString("ca_normal_openAd") ?? "11";
    ca_language_nativeAd = prefs.getString("ca_language_nativeAd") ?? "11";
    ca_full_nativeAd = prefs.getString("ca_full_nativeAd") ?? "11";

    ca_rewardedAd = prefs.getString("ca_rewardedAd") ?? "11";
    //home_native_ad_id = prefs.getString("home_native_ad_id") ?? "11";

    ca_free_coin = prefs.getInt("ca_free_coin") ?? 0;
    ca_rewared_credit = prefs.getInt("ca_rewared_credit") ?? 0;
    ca_reduce_coin_on_ai_lab_api = prefs.getInt("ca_reduce_coin_on_ai_lab_api") ?? 0;
    ca_reduce_coin_on_gemini_api = prefs.getInt("ca_reduce_coin_on_gemini_api") ?? 0;
    ca_week_bonus_coin = prefs.getInt("ca_week_bonus_coin") ?? 0;
    ca_month_bonus_coin = prefs.getInt("ca_month_bonus_coin") ?? 0;
    ca_first_plan_coin = prefs.getInt("ca_first_plan_coin") ?? 0;
    ca_second_plan_coin = prefs.getInt("ca_second_plan_coin") ?? 0;

    ca_click = prefs.getInt("ca_click") ?? 2;

    ca_showOpenAdInSplash = prefs.getBool("ca_showOpenAdInSplash") ?? false;
    ca_gemini_api_key = prefs.getString("ca_gemini_api_key") ?? "11";

    ca_ai_lab_tool_api = prefs.getString("ca_ai_lab_tool_api") ?? "11";
    ca_showRewardedAd_ai_lab_api = prefs.getBool("ca_showRewardedAd_ai_lab_api") ?? false;
    ca_showRewaredAd_gemini_api = prefs.getBool("ca_showRewaredAd_gemini_api") ?? false;
    ca_tester_email = prefs.getString("ca_tester_email") ?? "fueiuwieuiw";
    ca_tester_password = prefs.getString("ca_tester_password") ?? "foee#weiwueiuw3";
  }


  static void setAdIdsFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("ca_splash_interstitialAd", ca_splash_interstitialAd);
    prefs.setString("ca_pre_interstitialAd", ca_pre_interstitialAd);
    prefs.setString("ca_normal_openAd", ca_normal_openAd);
    prefs.setString("ca_language_nativeAd", ca_language_nativeAd);
    prefs.setString("ca_full_nativeAd", ca_full_nativeAd);
    prefs.setString("ca_rewardedAd", ca_rewardedAd);
    prefs.setInt("ca_free_coin", ca_free_coin);

    //prefs.setString("home_native_ad_id", home_native_ad_id);

    prefs.setInt("ca_click", ca_click);
    prefs.setBool("ca_showOpenAdInSplash", ca_showOpenAdInSplash);
    //prefs.setBool("showSecondNativeInLanguage", showSecondNativeInLanguage);
    prefs.setString("ca_gemini_api_key", ca_gemini_api_key);
    prefs.setInt("ca_reduce_coin_on_gemini_api", ca_reduce_coin_on_gemini_api);
    prefs.setInt("ca_reduce_coin_on_ai_lab_api", ca_reduce_coin_on_ai_lab_api);
    prefs.setInt("ca_rewared_credit", ca_rewared_credit);

    prefs.setString("ca_ai_lab_tool_api", ca_ai_lab_tool_api);
    prefs.setBool("ca_showRewaredAd_gemini_api", ca_showRewaredAd_gemini_api);
    prefs.setBool("ca_showRewardedAd_ai_lab_api", ca_showRewardedAd_ai_lab_api);
    prefs.setInt("ca_week_bonus_coin", ca_week_bonus_coin);
    prefs.setInt("ca_month_bonus_coin", ca_month_bonus_coin);
    prefs.setInt("ca_first_plan_coin", ca_first_plan_coin);
    prefs.setInt("ca_second_plan_coin", ca_second_plan_coin);


    //prefs.setBool("showPreloadedAd", showPreloadedAd);
  }


  static void resetAdIds() {

    ca_splash_interstitialAd = "11";
    ca_pre_interstitialAd = "11";
    ca_normal_openAd = "11";
    ca_language_nativeAd = "11";
    ca_full_nativeAd = "11";

    ca_full_nativeAd = "11";

    ca_rewardedAd = "11";

    //home_native_ad_id = "11";

    ca_click = 2;

    ca_showOpenAdInSplash = false;
    //showSecondNativeInLanguage = false;
    //showPreloadedAd = false;

    GlobalVariables.isPremiumUser = true;
  }

}
