import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quotesmaker/layout/menubar.dart';
import 'package:quotesmaker/layout/overlay_widget.dart';
import 'package:quotesmaker/provider/drawer_provider.dart';
import 'package:quotesmaker/provider/file_management_provider.dart';
import 'package:quotesmaker/provider/m_themes.dart';
import 'package:quotesmaker/utils/image_widget.dart';
import 'package:quotesmaker/utils/responsive.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../configuration/app_configuration.dart';
import '../utils/dialog_utils.dart';
import 'custom_paint.dart';
import 'dart:ui' as ui;

class QuotePage extends StatefulWidget {
  const QuotePage({Key? key}) : super(key: key);

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {

  var quoteController = TextEditingController();
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  bool editing = true;
  InterstitialAd? _interstitialAd;
  bool adLoaded = false;
  GlobalKey stickyKey = GlobalKey();
  late ui.Image cropImage;
  loadAppUpdates(BuildContext context) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('settings');
    var documentSnapshot =
        (await users.doc('Default').get()).data() as Map<String, dynamic>;
    if (documentSnapshot[APP_VERSION_KEY] != APP_VERSION) {
      print("not the same");
      DialogUtils.showInfoDialog(
          title: "You need to update the app",
          message: "Please update the app to enjoy the new features",
          context: context,
          btnOkOnPress: () async {
            print("Opening");
            final Uri _url = Uri.parse(documentSnapshot[APP_LINK_KEY]);

            if (!await launchUrl(_url)) {
              throw Exception('Could not launch $_url');
            }
          });
    }
  }
  load() {
    InterstitialAd.load(
        adUnitId: GENERATE_UNIT_ID,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {
                  print("onAdShowedFullScreenContent");
                },
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {
                  print("onAdImpression");
                },
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  print("onAdFailedToShowFullScreenContent");
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  print("onAdDismissedFullScreenContent");
                },
                onAdWillDismissFullScreenContent: (ad) {
                  print("onAdWillDismissFullScreenContent");
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
    loadAppUpdates(context);
    FirebaseStorage.instance
        .ref("backgrounds/")
        .listAll()
        .then((value) async => {
              for (var element in value.items)
                {assetImages.add(await element.getDownloadURL())},
            });
    quoteController.text = "Lorem Ipsum";
  }

  @override
  Widget build(BuildContext context) {
    final DrawerProvider _drawerProvider = Provider.of<DrawerProvider>(context);
    final MthemesProvider _themeProvider =
        Provider.of<MthemesProvider>(context);

    final FileManagementProvider _fileManagementProvider =
        Provider.of<FileManagementProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _themeProvider.themeMode==ThemeMode.dark?Colors.black:Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => setState(() {
                    editing = !editing;
                  }),
              icon: Icon(editing ? Icons.check : Icons.edit)),
          IconButton(
              onPressed: () => _themeProvider.changeThemeMode(),
              icon: Icon(_themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode))
        ],
      ),
      drawerScrimColor: Colors.transparent,
      floatingActionButton: Visibility(
          visible: !_fileManagementProvider.isProcessing,
          child: FloatingActionButton.extended(
              onPressed: () {
                _interstitialAd!.show();
                // Dispose the ad here to free resources.
                _fileManagementProvider.generatePicture(
                    getEditor(_fileManagementProvider,
                        isGeneration: true, isFinal: true),
                    context);
              },
              label: const Text('Generate'))),
      body: Padding(

        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 2.h,),
              getEditor(_fileManagementProvider, isGeneration: !editing),
              SizedBox(height: 2.h,),
              MyMenuBar(),
              SizedBox(height: 2.h,),
              SizedBox(
                height: 29.h,
                width: 85.w,
                child: items(_fileManagementProvider)[
                _drawerProvider.selectedIndex],
              )
              // Container(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Container(
              //     padding: EdgeInsets.all(10),
              //     color: Colors.white,
              //     child: SingleChildScrollView(
              //       child: Column(
              //         children: [
              //
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getEditor(FileManagementProvider _fileManagementProvider,
      {bool isGeneration = false, bool isFinal = false}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
            borderRadius:
                BorderRadius.circular(_fileManagementProvider.selectedRadius),
            child: ImageWidget(
                urlOrPath: _fileManagementProvider.backgroundImage,
                width: 45.h,
                height: 45.h,
                fit: BoxFit.fill)),
        Container(
          width: 45.h,
          height: 45.h,
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  _fileManagementProvider.selectedRadius),
              ),
        ),
        getTextWidget(isGeneration, isFinal, _fileManagementProvider),
      ],
    );
  }

  Widget getTextWidget(bool isGeneration, bool isFinal,
      FileManagementProvider _fileManagementProvider) {

    return isGeneration
        ? Container(
            width: 45.h,
            height: 45.h,
            child: OverlayWidget(
              isFinal: isFinal,
              notifier: notifier,
              widget: isFinal?Container(
                color: _fileManagementProvider.selectedColor,
                padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 2.h),
                child: Text(
                  quoteController.text,
                  maxLines: 10,
                  style: GoogleFonts.getFont(_fileManagementProvider.selectedFont,
                      color: _fileManagementProvider.selectedTextColor,
                      fontSize: _fileManagementProvider.selectedFontSize,
                      fontWeight: _fileManagementProvider.selectedFontWeight,
                      height: _fileManagementProvider.selectedLineHeight),
                ),
              ):CustomPaint(
                foregroundPainter: ZoomPaint(key:stickyKey),

                child: Container(
                  key: stickyKey,
                  color: _fileManagementProvider.selectedColor,
                  padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 2.h),
                  child: Text(
                    quoteController.text,
                    maxLines: 10,
                    style: GoogleFonts.getFont(_fileManagementProvider.selectedFont,
                        color: _fileManagementProvider.selectedTextColor,
                        fontSize: _fileManagementProvider.selectedFontSize,
                        fontWeight: _fileManagementProvider.selectedFontWeight,
                        height: _fileManagementProvider.selectedLineHeight),
                  ),
                ),
              ),
            ),
        )
        : Container(
            width: 45.h,
            height: 45.h,
            padding: EdgeInsets.symmetric(
                horizontal: _fileManagementProvider.horizontalPadding,
                vertical: _fileManagementProvider.verticalPadding),
            child: TextField(
              controller: quoteController,
              maxLines: 10,
              expands: false,
              minLines: 1,
              decoration: InputDecoration(
                fillColor:         _fileManagementProvider.selectedColor,
                border: InputBorder.none,
                hoverColor: Colors.transparent,
              ),
              textAlign: TextAlign.start,
              style: GoogleFonts.getFont(_fileManagementProvider.selectedFont,
                  color: _fileManagementProvider.selectedTextColor,
                  fontSize: _fileManagementProvider.selectedFontSize,
                  fontWeight: _fileManagementProvider.selectedFontWeight,
                  height: _fileManagementProvider.selectedLineHeight),
            ),
          );
  }

  _openColorPicker(FileManagementProvider provider, ColorType type) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                controller: ScrollController(),
                child: ColorPicker(
                  pickerColor: type == ColorType.background
                      ? provider.selectedColor??Colors.white
                      : provider.selectedTextColor,
                  onColorChanged: (color) => type == ColorType.background
                      ? provider.colorChange(color)
                      : provider.textColorChange(color),
                ),
              ),
              actions: [
                ElevatedButton(
                  child: const Text('Select'),
                  onPressed: () {
                    // provider.colorChange(color)
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  List<Widget> items(FileManagementProvider _fileManagementProvider) => [
        SizedBox(
          width: 90.w,
          child: Column(
            children: [
              Row(
                crossAxisAlignment:CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Text('Radius'),
                        SizedBox(height: 0.5.h,),
                        TextField(
                          maxLength: 2,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) {
                            _fileManagementProvider
                                .radiusChange(double.parse(val));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              counter: const SizedBox.shrink(),
                              filled: true,
                              isDense: true,
                              // Added this
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              hintText: '',
                              hintStyle: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10,),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _openColorPicker(
                          _fileManagementProvider, ColorType.background),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15)),
                        child: AbsorbPointer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Background'),
                              SizedBox(height: 0.5.h,),
                              TextField(
                                decoration: InputDecoration(
                                    fillColor:
                                        _fileManagementProvider.selectedColor ??
                                            Colors.transparent,
                                    filled:
                                        _fileManagementProvider.selectedColor !=
                                            null,
                                    isDense: true,
                                    // Added this
                                    contentPadding: const EdgeInsets.all(8),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    hintStyle: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _openColorPicker(
                          _fileManagementProvider, ColorType.text),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15)),
                        child: AbsorbPointer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Text color'),
                              SizedBox(height: 0.5.h,),
                              TextField(
                                decoration: InputDecoration(
                                    fillColor: _fileManagementProvider
                                        .selectedTextColor,
                                    isDense: true,
                                    // Added this
                                    contentPadding: const EdgeInsets.all(8),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    hintStyle: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                ],
              ),
              const Divider(),
              const SizedBox(height: 20),
              const Text('Font size'),
              Slider(
                  label:
                      "Font size ${_fileManagementProvider.selectedFontSize}",
                  value: _fileManagementProvider.selectedFontSize,
                  min: 10,
                  max: 100,
                  divisions: 90,
                  onChanged: _fileManagementProvider.fontSizeChange),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
        GridView.builder(
          controller: ScrollController(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5),
          itemBuilder: (context, index) {
            String font = GoogleFonts.asMap().keys.toList()[index];
            return GestureDetector(
              onTap: () => _fileManagementProvider.fontChange(font),
              child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    font,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.getFont(font),
                  )),
            );
          },
          itemCount: GoogleFonts.asMap().keys.toList().length,
        ),
        SingleChildScrollView(
          child: Wrap(
            spacing: 1.w,
            runSpacing: 2.w,
            children: [
              for (var image in assetImages)
                InkWell(
                    onTap: () =>
                        _fileManagementProvider.backgroundImageChange(image),
                    child: ImageWidget(urlOrPath: image,width: 27.w,))
            ],
          ),
        )
      ];
}
