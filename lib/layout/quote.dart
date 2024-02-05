import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quotesmaker/layout/menubar.dart';
import 'package:quotesmaker/provider/drawer_provider.dart';
import 'package:quotesmaker/provider/file_management_provider.dart';
import 'package:quotesmaker/provider/m_themes.dart';
import 'package:quotesmaker/utils/image_widget.dart';
import 'package:quotesmaker/utils/responsive.dart';
import 'package:screenshot/screenshot.dart';

class QuotePage extends StatefulWidget {
  const QuotePage({Key? key}) : super(key: key);

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  var quoteController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      appBar: AppBar(
        actions: [
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
                _fileManagementProvider.quotesList.add(quoteController.text);
                _fileManagementProvider.generatePicture();
              },
              label: const Text('Generate'))),
      drawer: Drawer(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DrawerHeader(
                    child: Column(
                  children: [
                    Text('Customization'),
                    MyMenuBar(),
                  ],
                )),
                Expanded(
                    child: items(_fileManagementProvider)[
                        _drawerProvider.selectedIndex]),
              ],
            ),
          )),
      endDrawer: Drawer(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DrawerHeader(
                    child: Column(
                  children: [
                    Text('Customization'),
                    MyMenuBar(),
                  ],
                )),
                Expanded(
                    child: items(_fileManagementProvider)[
                        _drawerProvider.selectedIndex]),
              ],
            ),
          )),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Center(
          child: AspectRatio(
            aspectRatio: _fileManagementProvider.selectedWidth /
                _fileManagementProvider.selectedHeight,
            child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(
                    maxHeight: Responsive.isDesktop(context) ? 800 : 400,
                    maxWidth: Responsive.isDesktop(context) ? 800 : 400),
                child: Screenshot(
                  controller: _fileManagementProvider.screenshotController,
                  child: Stack(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(
                              _fileManagementProvider.selectedRadius),
                          child: ImageWidget(
                              urlOrPath:
                                  _fileManagementProvider.backgroundImage,
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
                      Container(
                        alignment: _fileManagementProvider.align,
                        width: _fileManagementProvider.selectedWidth,
                        height: _fileManagementProvider.selectedHeight,
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                _fileManagementProvider.horizontalPadding,
                            vertical: _fileManagementProvider.verticalPadding),
                        child: TextField(
                          controller: quoteController,
                          maxLines: 10,
                          minLines: 1,
                          decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              hoverColor: Colors.transparent,
                          ),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.getFont(
                              _fileManagementProvider.selectedFont,
                              color: _fileManagementProvider.selectedTextColor,
                              fontSize:
                                  _fileManagementProvider.selectedFontSize,
                              fontWeight:
                                  _fileManagementProvider.selectedFontWeight,
                              height:
                                  _fileManagementProvider.selectedLineHeight),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ),
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
                const Divider(),
                const SizedBox(height: 20),
                const Text('Text alignment'),
                ButtonBar(alignment: MainAxisAlignment.center, children: [
                  TextButton(
                      onPressed: () => _fileManagementProvider
                          .textPositionChange(Alignment.topCenter),
                      child: const Text("Top")),
                  TextButton(
                      onPressed: () => _fileManagementProvider
                          .textPositionChange(Alignment.center),
                      child: const Text("Center")),
                  TextButton(
                      onPressed: () => _fileManagementProvider
                          .textPositionChange(Alignment.bottomCenter),
                      child: const Text("Bottom")),
                ]),
                const Divider(),
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
                GestureDetector(
                  onTap: () {
                    !_fileManagementProvider.isProcessing
                        ? _fileManagementProvider.generatePicture()
                        : null;
                  },
                  child: FloatingActionButton.extended(
                      onPressed: _fileManagementProvider.generatePicture,
                      label: const Text('Generate')),
                ),
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
            SliverToBoxAdapter(
              child: GridView.builder(
                controller: ScrollController(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
                itemCount: networkImages.length,
                itemBuilder: (context, index) {
                  String image = networkImages[index];
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
