import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quotesmaker/utils/dialog_utils.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:screenshot/screenshot.dart';

enum ColorType { background, text }

class FileManagementProvider extends ChangeNotifier {
  final TextEditingController quotesTextController = TextEditingController();
  final ScreenshotController screenshotController = ScreenshotController();

  Color? selectedColor;

  colorChange(Color color) {
    selectedColor = color;
    notifyListeners();
  }

  Color selectedTextColor = const Color(0XFFfb9685);

  textColorChange(Color color) {
    selectedTextColor = color;
    notifyListeners();
  }

  double selectedRadius = 5.0;

  radiusChange(double radius) {
    selectedRadius = radius;
    notifyListeners();
  }

  double selectedHeight = 400;

  heightChange(double height) {
    selectedHeight = height;
    notifyListeners();
  }

  double selectedWidth = 400;

  widthChange(double width) {
    selectedWidth = width;
    notifyListeners();
  }

  double selectedFontSize = 30;

  fontSizeChange(double size) {
    selectedFontSize = size;
    notifyListeners();
  }

  double selectedLineHeight = 1.0;

  lineHeightChange(double h) {
    selectedLineHeight = h;
    notifyListeners();
  }

  FontWeight selectedFontWeight = FontWeight.bold;

  fontWeightChange(FontWeight w) {
    selectedFontWeight = w;
    notifyListeners();
  }

  Alignment align = Alignment.center;

  textPositionChange(Alignment position) {
    align = position;
    notifyListeners();
  }

  String selectedFont = 'Lato';

  fontChange(String font) {
    selectedFont = font;
    notifyListeners();
  }

  bool isNetworkImage = false;
  dynamic backgroundImage = assetImages[2];

  backgroundImageChange(String asset) async {
    if (asset == 'assets/random.png') {
      backgroundImage = assetImages[Random().nextInt(assetImages.length)];
    } else if (asset == 'assets/custom.png') {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        backgroundImage = await image.readAsBytes();
      }
    } else {
      backgroundImage = asset;
    }
    notifyListeners();
  }

  double horizontalPadding = 50;

  horizontalPaddingChange(double padding) {
    horizontalPadding = padding;
    notifyListeners();
  }

  double verticalPadding = 50;

  verticalPaddingChange(double padding) {
    verticalPadding = padding;
    notifyListeners();
  }

  String _progress = '';

  String get progress => _progress;

  progressListener(int count, int length) {
    _progress = 'Download $count/$length complete';
    notifyListeners();
  }

  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  processingChange(bool flag) {
    _isProcessing = flag;
    notifyListeners();
  }

  String _quote_0 = '';

  String get quoteToFront => _quote_0;

  changeQuote(String newQuote) {
    _quote_0 = newQuote;
    notifyListeners();
  }

  final StreamController<String> _quoteStreamController =
      StreamController<String>.broadcast();

  Stream<String> get quoteStream => _quoteStreamController.stream;
  List<String> quotesList = [];

  generatePicture(Widget widget, BuildContext context) async {
    // quotesTextController.clear();
    processingChange(true);
    Uint8List output = await screenshotController.captureFromWidget(widget,
        context: context, delay: const Duration(milliseconds: 1));
    try {
      final String dir = (await getApplicationDocumentsDirectory()).path;
      var imagePath = '$dir/file_name${DateTime.now()}.png';
      var capturedFile = File(imagePath);
      await capturedFile.writeAsBytes(output);
      print(capturedFile.path);
      final result = await SaverGallery.saveImage(output,
          quality: 60,
          name: "file_name${DateTime.now()}",
          androidExistNotSave: false);
      print(result);
      print('png done');
    } catch (e) {
      print(e);
    }
    DialogUtils.showSuccessDialog(title: 'Your Image Has been saved successfully', context: context);
    processingChange(false);
  }
}

List<String> assetImages = [
  'assets/custom.png',
  'assets/random.png',
  'assets/t4.png',
];

// All our dreams can come true, if we have the courage to pursue them.
// The secret of getting ahead is getting started.
// I've missed more than 9,000 shots in my career. I’ve lost almost 300 games. 26 times I’ve been trusted to take the game winning shot and missed. I’ve failed over and over and over again in my life and that is why I succeed
// Don't limit yourself. Many people limit themselves to what they think they can do. You can go as far as your mind lets you. What you believe, remember, you can achieve
// The best time to plant a tree was 20 years ago. The second best time is now.
// It's hard to beat a person who never gives up
// I wake up every morning and think to myself, 'how far can I push this company in the next 24 hours.'
// If people are doubting how far you can go, go so far that you can’t hear them anymore
// We need to accept that we won't always make the right decisions, that we'll screw up royally sometimes – understanding that failure is not the opposite of success, it's part of success.
