import 'package:amplissimus/logging.dart';
import 'package:amplissimus/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static int counter = 0;
  static SharedPreferences preferences;
  static String username = '';
  static String password = '';
  static String grade = '5';
  static String char = 'a';

  static void loadPrefs() async {
    preferences = await SharedPreferences.getInstance();
    loadVariables();
  }

  static void loadVariables() {
    loadCounter();
    loadCurrentDesignMode();
    loadCredentials();
    loadClass();
  }

  static void loadCounter() {
    counter = preferences.getInt('counter');
    if(counter == null) counter = 0;
    ampLog(ctx: 'Prefs', message: 'loaded counter = $counter');
  }

  static void saveCounter(int saveCounter) {
    counter = saveCounter;
    preferences.setInt('counter', counter);
  }

  static void loadCurrentDesignMode() {
    bool tempBool = preferences.getBool('is_dark_mode');
    ampLog(ctx: 'Prefs', message: 'recognized isDarkMode = $tempBool');
    if(tempBool == null) tempBool = false;
    if(tempBool) {
      if(!AmpColors.isDarkMode) AmpColors.changeMode();
    } else {
      if(AmpColors.isDarkMode) AmpColors.changeMode();
    }
  }

  static void saveCurrentDesignMode(bool isDarkMode) {
    preferences.setBool('is_dark_mode', isDarkMode);
    ampLog(ctx: 'Prefs', message: 'saved isDarkMode = $isDarkMode');
  }

  static void loadCredentials() {
    String tempUsername = preferences.getString('username_dsb');
    String tempPassword = preferences.getString('password_dsb');
    if(tempUsername == null || tempPassword == null) {
      tempUsername = '';
      tempPassword = '';
    }
    username = tempUsername;
    password = tempPassword;
    ampLog(ctx: 'Prefs', message: 'loaded username = "$username"');
    ampLog(ctx: 'Prefs', message: 'loaded password = "$password"');
  }

  static void saveCredentials(String tempUsername, String tempPassword) {
    username = tempUsername;
    password = tempPassword;
    preferences.setString('username_dsb', username);
    preferences.setString('password_dsb', password);
    ampLog(ctx: 'Prefs', message: 'saved username_dsb = "$username"');
    ampLog(ctx: 'Prefs', message: 'saved password_dsb = "$password"');
  }

  static void loadClass() {
    String tempGrade = preferences.getString('grade');
    String tempChar = preferences.getString('char');
    if(tempGrade == null || tempChar == null) {
      tempGrade = '';
      tempChar = '';
    }
    grade = tempGrade;
    char = tempChar;
    ampLog(ctx: 'Prefs', message: 'loaded grade = "$grade"');
    ampLog(ctx: 'Prefs', message: 'loaded char = "$char"');
  }

  static void saveClass(String grade, String char) {
    preferences.setString('grade', grade.toLowerCase());
    preferences.setString('char', char.toLowerCase());
    ampLog(ctx: 'Prefs', message: 'saved grade = "$grade"');
    ampLog(ctx: 'Prefs', message: 'saved char = "$char"');
  }
}

