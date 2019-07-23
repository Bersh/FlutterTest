import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String KEY_LAST_LOADED_PAGE = 'lastLoadedPage';
const String KEY_ALL_LOADED_FROM_NETWORK = 'allLoadedFromNetwork';

class SharedPrefsManager {
  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> setLastLoadedPage(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_LAST_LOADED_PAGE, page);
  }

  Future<int> getLastLoadedPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Completer completer = Completer<int>();
    int value = prefs.getInt(KEY_LAST_LOADED_PAGE) ?? 1;
    completer.complete(value);
    return completer.future;
  }

  Future<void> setAllLoadedFromNetwork(bool isAllLoaded) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_LAST_LOADED_PAGE, isAllLoaded);
  }

  Future<bool> getAllLoadedFromNetwork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Completer completer = Completer<bool>();
    bool value = prefs.getBool(KEY_ALL_LOADED_FROM_NETWORK) ?? false;
    completer.complete(value);
    return completer.future;
  }
}
