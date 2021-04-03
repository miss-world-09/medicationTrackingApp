import 'package:flutter/material.dart';
import 'package:medication_app_v0/core/init/navigation/navigation.service.dart';
import 'package:medication_app_v0/core/init/navigation/navigation_route.dart';
import 'package:medication_app_v0/core/init/notifier/provider_list.dart';
import 'package:medication_app_v0/core/init/notifier/theme_notifier.dart';
import 'package:medication_app_v0/views/home/Calendar/view/calendar_view.dart';
import 'package:provider/provider.dart';


void main() => runApp(MultiProvider(
  providers: [...ApplicationProvider.instance.singleItems],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        theme: Provider.of<ThemeNotifier>(context,listen: false).currentTheme,
        title: 'Material App',
        navigatorKey: NavigationService.instance.navigatorKey,
        onGenerateRoute: NavigationRoute.instance.generateRoute,
        home: CalendarView(),
      );
  }//Home dešižebilir
}