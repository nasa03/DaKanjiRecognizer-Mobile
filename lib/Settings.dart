import 'package:da_kanji_recognizer_mobile/globals.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  /// The placeholder in the URL's which will be replaced by the predicted kanji
  String kanjiPlaceholder = "%X%";

  /// The custom URL a user can define on the settings page.
  String customURL;

  /// The URL of the jisho website
  String jishoURL;

  /// The URL of the takoboto website
  String takobotoURL;

  /// The URL of the wadoku website
  String wadokuURL;

  /// The URL of the weblio website
  String weblioURL;

  /// Indicates if a long press will use the custom URL.
  bool openWithCustomURL;

  /// Indicates if a long press will use the jisho URL.
  bool openWithJisho;

  /// Indicates if a long press will use the wadoku URL.
  bool openWithWadoku;

  /// Indicates if a long press will use the weblio URL.
  bool openWithWeblio;
  
  /// Indicates if a long press will use the default translator.
  bool openWithDefaultTranslator;

  /// The theme which the application will use.
  /// System will match the settings of the system.
  String selectedTheme;

  // if the showcase view should be shown for the drawing screen
  bool showShowcaseViewDrawing;

  // the application version used when those settings were saved
  String versionUsed;

  /// A list with all available themes.
  List<String> themes = ["light", "dark", "system"];

  /// A Map from the string of a theme to the ThemeMode of the theme.
  Map<String, ThemeMode> themesDict = {
    "light": ThemeMode.light,
    "dark": ThemeMode.dark,
    "system": ThemeMode.system
  };

  Settings() {
    setTogglesToFalse();

    String kanjiPlaceholder = "%X%";

    jishoURL = "https://jisho.org/search/" + kanjiPlaceholder + "%23kanji";
    wadokuURL = "https://www.wadoku.de/search/" + kanjiPlaceholder;
    weblioURL = "https://www.weblio.jp/content/" + kanjiPlaceholder;
  }

  /// Get the URL to the predicted kanji in the selected dictionary.
  ///
  /// @returns The URL which leads to the predicted kanji in the selected dict.
  String openWithSelectedDictionary(String kanji) {
    String url;

    // determine which URL should be used for finding the character
    if (openWithCustomURL)
      url = customURL;
    else if (openWithJisho)
      url = jishoURL;
    else if (openWithWadoku)
      url = wadokuURL;
    else if (openWithWeblio)
      url = weblioURL;
    else if (openWithDefaultTranslator)
      url = takobotoURL;

    // check that the URL starts with protocol, otherwise launch(fails)
    if (!(url.startsWith("http://") || url.startsWith("https://")))
      url = "https://" + url;

    // replace the placeholder with the actual character
    url = url.replaceFirst(new RegExp(kanjiPlaceholder), kanji);
    url = Uri.encodeFull(url);
    return url;
  }

  /// Set all values of the dictionary toggles in the Settings menu to false.
  void setTogglesToFalse() {
    openWithCustomURL = false;
    openWithJisho = false;
    openWithWadoku = false;
    openWithWeblio = false;
    openWithDefaultTranslator = false;
  }

  /// Saves all settings to the SharedPreferences.
  void save() async {
    print("saving");

    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // set value
    prefs.setBool('openWithCustomURL', openWithCustomURL);
    prefs.setBool('openWithJisho', openWithJisho);
    prefs.setBool('openWithDefaultTranslator', openWithDefaultTranslator);
    prefs.setBool('openWithWadoku', openWithWadoku);
    prefs.setBool('openWithWeblio', openWithWeblio);
    prefs.setBool('showShowcaseViewDrawing', showShowcaseViewDrawing);
    
    prefs.setString('customURL', customURL);
    prefs.setString('selectedTheme', selectedTheme);
    prefs.setString('versionUsed', VERSION);
  }

  /// Load all saved settings from SharedPreferences.
  void load() async {
    print("loading");

    openWithCustomURL = await loadBool('openWithCustomURL');
    openWithJisho = await loadBool('openWithJisho');
    openWithDefaultTranslator = await loadBool('openWithDefaultTranslator');
    openWithWadoku = await loadBool('openWithWadoku');
    openWithWeblio = await loadBool('openWithWeblio');
    showShowcaseViewDrawing = await loadBool('showShowcaseViewDrawing');

    customURL = await loadString('customURL');
    selectedTheme = await loadString('selectedTheme');
    versionUsed = await loadString('versionUsed');

    // assure that at least one switch is set to true
    if (!this.openWithCustomURL &&
        !this.openWithJisho &&
        !this.openWithDefaultTranslator &&
        !this.openWithWadoku &&
        !this.openWithWeblio) {
      this.openWithJisho = true;
    }

    // if another version used than last time -> show showcase
    if(versionUsed != VERSION){ 
      showShowcaseViewDrawing = true;
    }
  }

  /// Loads a bool from shared preferences.
  ///
  /// @returns The bool's loaded value of found, otherwise false
  Future<bool> loadBool(String boolName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loaded = prefs.getBool(boolName) ?? false;

    return loaded;
  }

  /// Loads a string value from the shared preferences.
  ///
  /// @returns The string value if found, "" otherwise
  Future<String> loadString(String stringName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String loaded = prefs.getString(stringName) ?? "";

    return loaded;
  }
}

