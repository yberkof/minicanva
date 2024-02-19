import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          context: context, btnOkOnPress: () async {
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
          adUnitId: 'ca-app-pub-3940256099942544/1033173712',
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
      body:Padding(
        padding: EdgeInsets.only(top: 10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              getEditor(_fileManagementProvider, isGeneration: !editing),
              Container(
                height: 40.h,
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MyMenuBar(),
                        Divider(),
                        Container(
                          height: 30.h,
                          child: items(_fileManagementProvider)[
                              _drawerProvider.selectedIndex],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding getEditor(FileManagementProvider _fileManagementProvider,
      {bool isGeneration = false, bool isFinal = false}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
              borderRadius:
                  BorderRadius.circular(_fileManagementProvider.selectedRadius),
              child: ImageWidget(
                  urlOrPath: _fileManagementProvider.backgroundImage,
                  width: _fileManagementProvider.selectedWidth,
                  height: _fileManagementProvider.selectedHeight,
                  fit: BoxFit.cover)
              // child: Image.asset(
              //     _fileManagementProvider.backgroundImage,
              //     width: _fileManagementProvider.selectedWidth,
              //     height: _fileManagementProvider.selectedHeight,
              //     fit: BoxFit.cover),
              ),
          Container(
            width: _fileManagementProvider.selectedWidth,
            height: _fileManagementProvider.selectedHeight,
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    _fileManagementProvider.selectedRadius),
                color: _fileManagementProvider.selectedColor),
          ),
          getTextWidget(isGeneration, isFinal, _fileManagementProvider),
        ],
      ),
    );
  }

  Widget getTextWidget(bool isGeneration, bool isFinal,
      FileManagementProvider _fileManagementProvider) {
    return isGeneration
        ? Container(
            width: _fileManagementProvider.selectedWidth,
            height: _fileManagementProvider.selectedHeight,
            child: OverlayWidget(
              isFinal: isFinal,
              notifier: notifier,
              widget: Text(
                quoteController.text,
                maxLines: 10,
                style: GoogleFonts.getFont(_fileManagementProvider.selectedFont,
                    color: _fileManagementProvider.selectedTextColor,
                    fontSize: _fileManagementProvider.selectedFontSize,
                    fontWeight: _fileManagementProvider.selectedFontWeight,
                    height: _fileManagementProvider.selectedLineHeight),
              ),
            ),
          )
        : Container(
            width: _fileManagementProvider.selectedWidth,
            height: _fileManagementProvider.selectedHeight,
            padding: EdgeInsets.symmetric(
                horizontal: _fileManagementProvider.horizontalPadding,
                vertical: _fileManagementProvider.verticalPadding),
            child: TextField(
              controller: quoteController,
              maxLines: 10,
              expands: false,
              minLines: 1,
              decoration: InputDecoration(
                fillColor: Colors.transparent,
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
                  pickerColor: Theme.of(context).primaryColor,
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
        SingleChildScrollView(
          child: SizedBox(
            width: Responsive.isDesktop(context) ? 400 : 300,
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxHeight: 200,
                      maxWidth: Responsive.isDesktop(context) ? 400 : 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _fileManagementProvider.quotesList.length,
                    itemBuilder: (context, index) {
                      return Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1)),
                          child: Text(_fileManagementProvider.quotesList[index]
                                  [0] ??
                              ''));
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Container(
                //   margin: const EdgeInsets.only(top: 10),
                //   child: ElevatedButton(
                //       onPressed: () async {
                //       String text = '';
                //
                //         FilePickerResult? result = await FilePicker.platform.pickFiles(
                //           type: FileType.custom,
                //           allowMultiple: false,
                //           allowedExtensions: ['csv'],
                //         );
                //
                //         if (result != null) {
                //           _fileManagementProvider.quotesList.clear();
                //           PlatformFile? file = result.files.first;
                //           final Uint8List? fileBytes = file.bytes;
                //
                //           String text = utf8.decode(fileBytes ?? []);
                //           final fields = const CsvToListConverter().convert(text);
                //           for (var element in fields) {
                //             text += element.join(",");
                //             _fileManagementProvider.quotesList.add(element);
                //           }
                //           _fileManagementProvider.quotesTextController.text = text;
                //           setState(() {});
                //         }
                //       },
                //       child: const Text('Choose CSV file')),
                // ),
                // const Divider(),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          maxLength: 3,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) {
                            _fileManagementProvider
                                .widthChange(double.parse(val));
                          },
                          keyboardType: TextInputType.number,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              counter: const SizedBox.shrink(),
                              filled: true,
                              isDense: true,
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              hintText: 'Width',
                              hintStyle: const TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: TextField(
                          maxLength: 3,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) {
                            _fileManagementProvider
                                .heightChange(double.tryParse(val)!);
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
                              hintText: 'Height',
                              hintStyle: const TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: TextField(
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
                              hintText: 'Radius',
                              hintStyle: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () => _openColorPicker(
                              _fileManagementProvider, ColorType.background),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)),
                            child: AbsorbPointer(
                              child: TextField(
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
                                    hintText: 'Background',
                                    hintStyle: const TextStyle(fontSize: 12)),
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
                              child: TextField(
                                decoration: InputDecoration(
                                    fillColor: _fileManagementProvider
                                        .selectedTextColor,
                                    isDense: true,
                                    // Added this
                                    contentPadding: const EdgeInsets.all(8),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    hintText: 'Text color',
                                    hintStyle: const TextStyle(fontSize: 12)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d*'))
                          ],
                          onChanged: (val) {
                            _fileManagementProvider
                                .lineHeightChange(double.parse(val));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              filled: true,
                              isDense: true,
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: 'Line height',
                              hintStyle: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
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
                const SizedBox(height: 20),
                const Text('Horizontal and Vertical Padding'),
                Row(
                  children: [
                    Expanded(
                      child: Slider.adaptive(
                          label:
                              "Horizontal Padding ${_fileManagementProvider.horizontalPadding}",
                          value: _fileManagementProvider.horizontalPadding,
                          min: 25,
                          max: 200,
                          divisions: 100,
                          onChanged:
                              _fileManagementProvider.horizontalPaddingChange),
                    ),
                    Expanded(
                      child: Slider.adaptive(
                          label:
                              "Vertical Padding ${_fileManagementProvider.verticalPadding}",
                          value: _fileManagementProvider.verticalPadding,
                          min: 25,
                          max: 200,
                          divisions: 100,
                          onChanged:
                              _fileManagementProvider.verticalPaddingChange),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
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
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GridView.builder(
                controller: ScrollController(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
                itemCount: assetImages.length,
                itemBuilder: (context, index) {
                  String image = assetImages[index];
                  return InkWell(
                      onTap: () =>
                          _fileManagementProvider.backgroundImageChange(image),
                      child: ImageWidget(urlOrPath: image));
                },
              ),
            ),
          ],
        )
      ];
}
