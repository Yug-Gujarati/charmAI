import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('nl'),
    Locale('pa'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @charmAI.
  ///
  /// In en, this message translates to:
  /// **'CharmAI'**
  String get charmAI;

  /// No description provided for @aiimageeditor.
  ///
  /// In en, this message translates to:
  /// **'AI Image Generator'**
  String get aiimageeditor;

  /// No description provided for @thisActionmay.
  ///
  /// In en, this message translates to:
  /// **'This action may contain ads'**
  String get thisActionmay;

  /// No description provided for @selectelanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectelanguage;

  /// No description provided for @intro1title.
  ///
  /// In en, this message translates to:
  /// **'Create Your Perfect Dating Look'**
  String get intro1title;

  /// No description provided for @intro1description.
  ///
  /// In en, this message translates to:
  /// **'Generate stunning AI dating photos that make you stand out. Create attractive, natural-looking profile pictures designed to boost your confidence and matches.'**
  String get intro1description;

  /// No description provided for @intro2title.
  ///
  /// In en, this message translates to:
  /// **'Create Professional AI Headshots'**
  String get intro2title;

  /// No description provided for @intro2description.
  ///
  /// In en, this message translates to:
  /// **'Turn your selfies into studio-quality professional headshots for LinkedIn, resumes, business profiles, and social media — all powered by AI.'**
  String get intro2description;

  /// No description provided for @intro3title.
  ///
  /// In en, this message translates to:
  /// **'Try Hairstyles & Outfits Instantly'**
  String get intro3title;

  /// No description provided for @intro3description.
  ///
  /// In en, this message translates to:
  /// **'Explore trendy hairstyles and virtual outfit changes tailored to your face and style. Discover the perfect look before making any real changes.'**
  String get intro3description;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @userCancelled.
  ///
  /// In en, this message translates to:
  /// **'User cancelled'**
  String get userCancelled;

  /// No description provided for @youarenotallowed.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to purchase'**
  String get youarenotallowed;

  /// No description provided for @usernotallowed.
  ///
  /// In en, this message translates to:
  /// **'User not allowed to purchase'**
  String get usernotallowed;

  /// No description provided for @paymentispending.
  ///
  /// In en, this message translates to:
  /// **'Payment is Pending'**
  String get paymentispending;

  /// No description provided for @youplansubscribe.
  ///
  /// In en, this message translates to:
  /// **'Your plan subscribe successfully'**
  String get youplansubscribe;

  /// No description provided for @failedtopurcahse.
  ///
  /// In en, this message translates to:
  /// **'Failed To Purchase'**
  String get failedtopurcahse;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @base.
  ///
  /// In en, this message translates to:
  /// **'base'**
  String get base;

  /// No description provided for @bonuscredit.
  ///
  /// In en, this message translates to:
  /// **'bonus credit'**
  String get bonuscredit;

  /// No description provided for @continuee.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuee;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade To Premium'**
  String get upgradeToPremium;

  /// No description provided for @generatePremium.
  ///
  /// In en, this message translates to:
  /// **'Generate Premium AI Dating Photos'**
  String get generatePremium;

  /// No description provided for @createprofetional.
  ///
  /// In en, this message translates to:
  /// **'Create Professional AI Headshots'**
  String get createprofetional;

  /// No description provided for @tryhairstyles.
  ///
  /// In en, this message translates to:
  /// **'Try Hairstyles & Outfits Instantly'**
  String get tryhairstyles;

  /// No description provided for @privacypolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacypolicy;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @iamtester.
  ///
  /// In en, this message translates to:
  /// **'I Am Tester'**
  String get iamtester;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @shareapp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareapp;

  /// No description provided for @rateup.
  ///
  /// In en, this message translates to:
  /// **'Rate US'**
  String get rateup;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please Wait For A While'**
  String get pleaseWait;

  /// No description provided for @tryNow.
  ///
  /// In en, this message translates to:
  /// **'Try Now'**
  String get tryNow;

  /// No description provided for @savedImages.
  ///
  /// In en, this message translates to:
  /// **'Saved Images'**
  String get savedImages;

  /// No description provided for @chagehairstyle.
  ///
  /// In en, this message translates to:
  /// **'Change Hair Style'**
  String get chagehairstyle;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @selecthaircolor.
  ///
  /// In en, this message translates to:
  /// **'Select Hair Color'**
  String get selecthaircolor;

  /// No description provided for @taptoselectimage.
  ///
  /// In en, this message translates to:
  /// **'Tap to select images'**
  String get taptoselectimage;

  /// No description provided for @suggesthairstyle.
  ///
  /// In en, this message translates to:
  /// **'Recommend Hairstyle'**
  String get suggesthairstyle;

  /// No description provided for @faceshape.
  ///
  /// In en, this message translates to:
  /// **'Face Shape:'**
  String get faceshape;

  /// No description provided for @recommendedhairstyles.
  ///
  /// In en, this message translates to:
  /// **'Recommended Hairstyles'**
  String get recommendedhairstyles;

  /// No description provided for @clothimage.
  ///
  /// In en, this message translates to:
  /// **'Cloth Image'**
  String get clothimage;

  /// No description provided for @tryonnow.
  ///
  /// In en, this message translates to:
  /// **'Try On Now'**
  String get tryonnow;

  /// No description provided for @tryonresult.
  ///
  /// In en, this message translates to:
  /// **'Try-On Result'**
  String get tryonresult;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @mycreations.
  ///
  /// In en, this message translates to:
  /// **'My Creations'**
  String get mycreations;

  /// No description provided for @errorloadingimage.
  ///
  /// In en, this message translates to:
  /// **'Error loading images'**
  String get errorloadingimage;

  /// No description provided for @nocreationyet.
  ///
  /// In en, this message translates to:
  /// **'No creations yet'**
  String get nocreationyet;

  /// No description provided for @getrewared.
  ///
  /// In en, this message translates to:
  /// **'Get reward'**
  String get getrewared;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @areyousureyouwant.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image'**
  String get areyousureyouwant;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @getmorecoins.
  ///
  /// In en, this message translates to:
  /// **'Get more coins'**
  String get getmorecoins;

  /// No description provided for @createrealistic.
  ///
  /// In en, this message translates to:
  /// **'Create Realistic AI Face Swaps'**
  String get createrealistic;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @datingredyimage.
  ///
  /// In en, this message translates to:
  /// **'Dating Ready Image'**
  String get datingredyimage;

  /// No description provided for @choosehowtoliketogenerate.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to continue generating image'**
  String get choosehowtoliketogenerate;

  /// No description provided for @faceSwap.
  ///
  /// In en, this message translates to:
  /// **'Face Swap'**
  String get faceSwap;

  /// No description provided for @yourface.
  ///
  /// In en, this message translates to:
  /// **'Your Face'**
  String get yourface;

  /// No description provided for @aidatingimage.
  ///
  /// In en, this message translates to:
  /// **'AI Dating Image'**
  String get aidatingimage;

  /// No description provided for @faceAnalyzer.
  ///
  /// In en, this message translates to:
  /// **'Face Analyzer'**
  String get faceAnalyzer;

  /// No description provided for @facebeauty.
  ///
  /// In en, this message translates to:
  /// **'Face Beauty'**
  String get facebeauty;

  /// No description provided for @faceimage.
  ///
  /// In en, this message translates to:
  /// **'Face Image'**
  String get faceimage;

  /// No description provided for @generateimage.
  ///
  /// In en, this message translates to:
  /// **'Generate Image'**
  String get generateimage;

  /// No description provided for @manfaceimage.
  ///
  /// In en, this message translates to:
  /// **'Man Face Image'**
  String get manfaceimage;

  /// No description provided for @womanfaceimage.
  ///
  /// In en, this message translates to:
  /// **'Women Face Image'**
  String get womanfaceimage;

  /// No description provided for @youcreation.
  ///
  /// In en, this message translates to:
  /// **'Your Creation'**
  String get youcreation;

  /// No description provided for @virtualtryon.
  ///
  /// In en, this message translates to:
  /// **'Virtual Try-On'**
  String get virtualtryon;

  /// No description provided for @creditneveexpire.
  ///
  /// In en, this message translates to:
  /// **'Credit never expire'**
  String get creditneveexpire;

  /// No description provided for @surprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise'**
  String get surprise;

  /// No description provided for @surpriseme.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get surpriseme;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fr', 'hi', 'ja', 'ko', 'ms', 'nl', 'pa', 'pt', 'ru', 'th', 'tr', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'ms': return AppLocalizationsMs();
    case 'nl': return AppLocalizationsNl();
    case 'pa': return AppLocalizationsPa();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'th': return AppLocalizationsTh();
    case 'tr': return AppLocalizationsTr();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
