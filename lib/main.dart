import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quotesmaker/configuration/app_configuration.dart';
import 'package:quotesmaker/provider/drawer_provider.dart';
import 'package:quotesmaker/provider/file_management_provider.dart';
import 'package:quotesmaker/layout/quote.dart';
import 'package:quotesmaker/provider/m_themes.dart';
import 'package:quotesmaker/utils/dialog_utils.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  setPathUrlStrategy();
  MobileAds.instance.initialize();
  MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
      testDeviceIds: ['F5EF007E0E63D6959D3CCDD3FF79216D']));
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => DrawerProvider()),
            ChangeNotifierProvider(
                create: (context) => FileManagementProvider()),
            ChangeNotifierProvider(create: (context) => MthemesProvider())
          ],
          builder: (context, child) {
            final _themeProvider = Provider.of<MthemesProvider>(context);
            return MaterialApp(
              title: 'Mini Canva',
              debugShowCheckedModeBanner: false,
              theme: _themeProvider.blueThemeLight,
              darkTheme: _themeProvider.blueThemeDark,
              themeMode: _themeProvider.themeMode,
              home: const QuotePage(),
            );
          }),
    );
  }
}

// f2.10 build web --web-renderer canvaskit --release
