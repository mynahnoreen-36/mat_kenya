import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'sw'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? swText = '',
  }) =>
      [enText, swText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // SignupPage
  {
    'xl6sw5vf': {
      'en': 'Create an account',
      'sw': '',
    },
    '1xvqpk4r': {
      'en': 'Let\'s get started by filling out the form below.',
      'sw': '',
    },
    'jcfb59g0': {
      'en': 'Email',
      'sw': '',
    },
    'ljqik1mv': {
      'en': 'Password',
      'sw': '',
    },
    'p8i38rbi': {
      'en': 'Confirm Password',
      'sw': '',
    },
    'qnibcjcn': {
      'en': 'Create Account',
      'sw': '',
    },
    'cgj0j57g': {
      'en': 'Already have an account? ',
      'sw': '',
    },
    'yogj9k1i': {
      'en': ' Sign In here',
      'sw': '',
    },
    '5l1bb7wj': {
      'en': 'UserName',
      'sw': '',
    },
    'qpyicw4i': {
      'en': 'Overall',
      'sw': '',
    },
    'clrxqjhk': {
      'en': '5',
      'sw': '',
    },
    'mctv7iwc': {
      'en':
          'Nice outdoor courts, solid concrete and good hoops for the neighborhood.',
      'sw': '',
    },
    'eroh3o6f': {
      'en': 'Home',
      'sw': '',
    },
  },
  // ForgotpasswordPage
  {
    'v78ws4eh': {
      'en': 'Back',
      'sw': '',
    },
    'vw03gdwj': {
      'en': 'Forgot Password',
      'sw': '',
    },
    'souw8kuc': {
      'en':
          'We will send you an email with a link to reset your password, please enter the email associated with your account below.',
      'sw': '',
    },
    'mqf5wntc': {
      'en': 'Your email address...',
      'sw': '',
    },
    'fthnii2e': {
      'en': 'Enter your email...',
      'sw': '',
    },
    'jhdzq65n': {
      'en': 'Send Link',
      'sw': '',
    },
    'e5bnj207': {
      'en': 'Back',
      'sw': '',
    },
    'jzr06j1i': {
      'en': 'Home',
      'sw': '',
    },
  },
  // WelcomePage
  {
    'fl5l4n8u': {
      'en': 'Kenya in your pocket',
      'sw': '',
    },
    'pmm69071': {
      'en': 'Get Started',
      'sw': '',
    },
    'clidsilc': {
      'en': 'My Account',
      'sw': '',
    },
    'xtc3nzhc': {
      'en': 'Home',
      'sw': '',
    },
  },
  // LoginPage
  {
    'oz2ymjep': {
      'en': 'Get Started',
      'sw': '',
    },
    'n76bhdby': {
      'en': 'Let\'s get started by filling out the form below.',
      'sw': '',
    },
    'p09tvu5i': {
      'en': 'Email',
      'sw': '',
    },
    'aapurgq2': {
      'en': 'Password',
      'sw': '',
    },
    'tly4eyk1': {
      'en': 'Log in',
      'sw': '',
    },
    'rccthlev': {
      'en': 'Forgot password?  ',
      'sw': '',
    },
    '0myd4iz2': {
      'en': 'Click here',
      'sw': '',
    },
    'xtykavyc': {
      'en': 'Home',
      'sw': '',
    },
  },
  // HomePage
  {
    '85lme1ab': {
      'en': 'Find Route',
      'sw': '',
    },
    'u6swthju': {
      'en': 'Estimate Fare',
      'sw': '',
    },
    'dnvta0rr': {
      'en': 'View Map',
      'sw': '',
    },
    '9yo3z5lw': {
      'en': 'Popular Places',
      'sw': '',
    },
    'lse14vit': {
      'en': 'Nairobi',
      'sw': '',
    },
    'mtvc47lz': {
      'en':
          'A small description about this card that helps users understand the importance of what makes this so special.',
      'sw': '',
    },
    '22ed65z7': {
      'en': 'Kisumu',
      'sw': '',
    },
    'l6t95evp': {
      'en':
          'A small description about this card that helps users understand the importance of what makes this so special.',
      'sw': '',
    },
    '3y2suub4': {
      'en': 'Nakuru',
      'sw': '',
    },
    'p7gefm9u': {
      'en':
          'A small description about this card that helps users understand the importance of what makes this so special.',
      'sw': '',
    },
    'brq4dgfq': {
      'en': 'Mombasa',
      'sw': '',
    },
    '6rmsegfp': {
      'en': 'Hello World..description',
      'sw': '',
    },
    'zqsmg6fp': {
      'en': 'Kenya in your pocket',
      'sw': '',
    },
    '7t6j0r3z': {
      'en': 'Home',
      'sw': '',
    },
  },
  // MapPage
  {
    'iy2u501b': {
      'en': 'Map Page',
      'sw': '',
    },
    'yrkwfbjp': {
      'en': 'Select Location',
      'sw': '',
    },
    'fe4ygq6h': {
      'en': 'Home',
      'sw': '',
    },
  },
  // RoutesPage
  {
    'fz7q13ww': {
      'en': 'Available Routes',
      'sw': '',
    },
    'm8h998sg': {
      'en': 'Home',
      'sw': '',
    },
  },
  // FaresPage
  {
    'wopejzjm': {
      'en': 'View current fare estimates for your routes',
      'sw': '',
    },
    'bt5zjrhr': {
      'en': 'Standard fare estimate',
      'sw': '',
    },
    'aibxv6kh': {
      'en': 'Fare Estimates',
      'sw': '',
    },
    '9ypv5f9j': {
      'en': 'Home',
      'sw': '',
    },
  },
  // AdminPage
  {
    'ezdvn7rg': {
      'en': 'Welcome, Admin👋',
      'sw': '',
    },
    'h3xr58wo': {
      'en': 'Your recent activity is below.',
      'sw': '',
    },
    '4ygq0vsb': {
      'en': 'Routes',
      'sw': '',
    },
    '15l40d8j': {
      'en': 'Stages',
      'sw': '',
    },
    'aqxflqgz': {
      'en': 'Last 30 Days',
      'sw': '',
    },
    'bn777bpu': {
      'en': 'Avg. Grade',
      'sw': '',
    },
    '0h51uy98': {
      'en': 'Routes Overview',
      'sw': '',
    },
    'mog8d2nq': {
      'en': 'A summary of outstanding tasks.',
      'sw': '',
    },
    '007z1981': {
      'en': 'Route name',
      'sw': '',
    },
    'zrydvszv': {
      'en': 'Start→ End',
      'sw': '',
    },
    'c1udsdy0': {
      'en': 'Route ID',
      'sw': '',
    },
    'vjhhrd3w': {
      'en': 'Today, 5:30pm',
      'sw': '',
    },
    'ygp9h0fg': {
      'en': 'Edit',
      'sw': '',
    },
    '89530qp5': {
      'en': '1',
      'sw': '',
    },
    'v31rbbfy': {
      'en': 'Task Type',
      'sw': '',
    },
    '5nifmaq3': {
      'en':
          'Task Description here this one is really long and it goes over maybe? And goes to two lines.',
      'sw': '',
    },
    '52ry3c22': {
      'en': 'Due',
      'sw': '',
    },
    'samvbqg2': {
      'en': 'Today, 5:30pm',
      'sw': '',
    },
    'gcuq2qm7': {
      'en': 'Update',
      'sw': '',
    },
    'ws7ltml3': {
      'en': '1',
      'sw': '',
    },
    'a0wq44gk': {
      'en': 'Admin Dashboard',
      'sw': '',
    },
    'jav6wc11': {
      'en': 'Home',
      'sw': '',
    },
  },
  // ProfilePage
  {
    '2j7vfqwe': {
      'en': 'Account',
      'sw': '',
    },
    'y3r8niyq': {
      'en': 'Edit Profile',
      'sw': '',
    },
    '8ho6fxte': {
      'en': 'General',
      'sw': '',
    },
    'wakhcgs1': {
      'en': 'Support',
      'sw': '',
    },
    'idfe1s4h': {
      'en': 'Terms of Service',
      'sw': '',
    },
    'pht9cjbk': {
      'en': 'Log out',
      'sw': '',
    },
    'syg5hxdm': {
      'en': 'Karibu👋',
      'sw': '',
    },
    '5voklwzm': {
      'en': 'Home',
      'sw': '',
    },
  },
  // Miscellaneous
  {
    '8d9h0pj3': {
      'en': '',
      'sw': '',
    },
    'ssfc8w6p': {
      'en': '',
      'sw': '',
    },
    'xz87px6r': {
      'en': 'In order to view location',
      'sw': '',
    },
    'wryxay39': {
      'en': '',
      'sw': '',
    },
    '7xsewnaq': {
      'en': '',
      'sw': '',
    },
    'hbjtsz08': {
      'en': '',
      'sw': '',
    },
    '0hnqv4z3': {
      'en': '',
      'sw': '',
    },
    'zwj1gveb': {
      'en': '',
      'sw': '',
    },
    'd6btvjsq': {
      'en': '',
      'sw': '',
    },
    'vl63lv51': {
      'en': '',
      'sw': '',
    },
    'j4lk8e4i': {
      'en': '',
      'sw': '',
    },
    '9kldsh0o': {
      'en': '',
      'sw': '',
    },
    'zn7z4aik': {
      'en': '',
      'sw': '',
    },
    'r2y0rdkv': {
      'en': '',
      'sw': '',
    },
    '9ks02bo3': {
      'en': '',
      'sw': '',
    },
    'o4pxwgt2': {
      'en': '',
      'sw': '',
    },
    'gmh7sqxb': {
      'en': '',
      'sw': '',
    },
    'zl5gh806': {
      'en': '',
      'sw': '',
    },
    '9rx9fxu9': {
      'en': '',
      'sw': '',
    },
    '5r16dwqv': {
      'en': '',
      'sw': '',
    },
    '3wozyq4v': {
      'en': '',
      'sw': '',
    },
    'p50hf5g2': {
      'en': '',
      'sw': '',
    },
    'nf1ls9io': {
      'en': '',
      'sw': '',
    },
    'biuepyno': {
      'en': '',
      'sw': '',
    },
    'bczeexxj': {
      'en': '',
      'sw': '',
    },
    '1mmo5mms': {
      'en': '',
      'sw': '',
    },
    'fvymzi4u': {
      'en': '',
      'sw': '',
    },
    'ifwdbk5d': {
      'en': '',
      'sw': '',
    },
  },
].reduce((a, b) => a..addAll(b));
