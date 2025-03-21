import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:medication_app_v0/core/base/viewmodel/base_viewmodel.dart';
import 'package:medication_app_v0/core/components/models/others/user_data_model.dart';
import 'package:medication_app_v0/core/constants/enums/shared_preferences_enum.dart';
import 'package:medication_app_v0/core/constants/navigation/navigation_constants.dart';
import 'package:medication_app_v0/core/init/cache/shared_preferences_manager.dart';
import 'package:medication_app_v0/core/init/locale_keys.g.dart';
import 'package:medication_app_v0/core/init/services/auth_manager.dart';
import 'package:medication_app_v0/core/init/services/google_sign_helper.dart';
import 'package:medication_app_v0/views/Inventory/model/inventory_model.dart';
import 'package:medication_app_v0/views/home/Calendar/model/reminder.dart';
import 'package:medication_app_v0/core/extention/string_extention.dart';

import 'package:mobx/mobx.dart';
import 'package:table_calendar/table_calendar.dart';
part 'home_viewmodel.g.dart';

class HomeViewmodel = _HomeViewmodelBase with _$HomeViewmodel;

abstract class _HomeViewmodelBase with Store, BaseViewModel {
  @observable
  bool isLoading = false;
  @observable
  Map<DateTime, List<ReminderModel>> events;
  @observable
  List<ReminderModel> selectedEvents;
  CalendarController calendarController;
  final SharedPreferencesManager _sharedPreferencesManager =
      SharedPreferencesManager.instance;
  //scan QR barcode
  String _scanBarcode = 'Unknown';

  void setContext(BuildContext context) => this.context = context;
  void init() async {
    changeLoading();
    denemeGet();
    final _selectedDay =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    //_sharedPreferencesManager
    //    .setListValue(SharedPreferencesKey.REMINDERMODELS, []);
    events = await getEvents();

    selectedEvents = events[_selectedDay] ?? [];
    calendarController = CalendarController();
    //checking loading indicator
    print("-----------------------------wait");
    await waitIt();
    print("-------------------------done");
    changeLoading();
  }

  Future<void> waitIt() async {
    await Future.delayed(Duration(seconds: 1));
  }

  void dispose() {
    calendarController.dispose();
  }

  @action
  void onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    selectedEvents = events.cast<ReminderModel>();
  }

  @action
  void onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    calendarController.setSelectedDay(first);
    selectedEvents = events[first] ?? [];
    print('CALLBACK: _onVisibleDaysChanged');
  }

  Future<void> storeReminders() async {
    List<String> reminders = [];
    try {
      //add new reminders to the old reminders List.
      events.values.forEach((value) {
        for(ReminderModel reminder in value){
          reminders.add(reminder.toJson());
        }
      });
      //save to sharedPreferences
      await _sharedPreferencesManager.setListValue(SharedPreferencesKey.REMINDERMODELS, reminders);
      return true;
    } catch (e) {
      return false;
    }
  }

  void onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  //scan barcode (qr and normal type barcode is readable.)
  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", LocaleKeys.home_CANCEL.locale, true, ScanMode.QR);
      print("barcode=$barcodeScanRes");
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return; mountedi anlamadım!!!
    _scanBarcode = barcodeScanRes;
  }

  @action
  void changeLoading() {
    isLoading = !isLoading;
  }

  void logoutIconButtonOnPress() async {
    await GoogleSignHelper.instance.signOut();
    navigation.navigateToPageClear(path: NavigationConstants.SPLASH_VIEW);
  }

  void navigateCovidTurkey() {
    navigation.navigateToPage(path: NavigationConstants.COVID_TURKEY_VIEW);
  }

  void navigateInventory() {
    navigation.navigateToPage(path: NavigationConstants.INVENTORY_VIEW);
  }

  void navigateAddMedication() {
    navigation.navigateToPage(path: NavigationConstants.ADD_MEDICATION);
  }

  Future<void> denemeGet() async {
    UserDataModel udm = await AuthManager.instance.getUserData();
    print(udm.toString());
  }

  Future<List<ReminderModel>> getModelListFromSharedPref() async {
    List<String> jsons = await _sharedPreferencesManager
        .getStringListValue(SharedPreferencesKey.REMINDERMODELS);
    List<ReminderModel> results = [];
    jsons.forEach((value) => results.add(ReminderModel.fromJson(value)));
    return results;
  }

  Future<Map<DateTime, List<ReminderModel>>> getEvents() async {
    List<ReminderModel> reminderModels = await getModelListFromSharedPref();
    var eventMap = new Map<DateTime, List<ReminderModel>>();
    reminderModels.forEach((value) {
      DateTime theDay =
          DateTime(value.time.year, value.time.month, value.time.day);
      if (eventMap.containsKey(theDay)) {
        eventMap[theDay].add(value);
      } else {
        eventMap[theDay] = [value];
      }
    });
    return eventMap;
  }
}
