import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quotesmaker/provider/drawer_provider.dart';
import 'package:quotesmaker/provider/file_management_provider.dart';
import 'package:quotesmaker/layout/quote.dart';
import 'package:quotesmaker/provider/m_themes.dart';
import 'package:sizer/sizer.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  setPathUrlStrategy();
  // await dotenv.load(fileName: ".env");
  //
  // await Firebase.initializeApp(
  //     options: FirebaseOptions(
  //         apiKey: dotenv.get('apiKey'),
  //         appId: dotenv.get('appId'),
  //         messagingSenderId: dotenv.get('messagingSenderId'),
  //         projectId: dotenv.get('projectId')));
  MobileAds.instance.initialize();
  MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['F5EF007E0E63D6959D3CCDD3FF79216D']));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder:(context, orientation, deviceType) =>  MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => DrawerProvider()),
            ChangeNotifierProvider(create: (context) => FileManagementProvider()),
            ChangeNotifierProvider(create: (context) => MthemesProvider()),
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
