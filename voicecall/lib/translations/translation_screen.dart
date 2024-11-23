import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TranslationsScreen extends StatefulWidget {
  const TranslationsScreen({Key? key}) : super(key: key);

  @override
  _TranslationsScreenState createState() => _TranslationsScreenState();
}

class _TranslationsScreenState extends State<TranslationsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String? _speakLanguage;
  String? _translateToLanguage;
  bool _isListening = false;
  bool _isTranslating = false;
  final TextEditingController _inputTextController = TextEditingController();
  final Map<String, String> _translations = {};
  String _listeningMessage = ""; // Listening message state

  final List<String> _languagesCode = ['en', 'ru', 'fr', 'zh-cn', 'hi', 'de', 'it', 'es', 'ja'];

  final Map<String, String> _languageNames = {
    'en': 'English',
    'ru': 'Russian',
    'fr': 'French',
    'zh-cn': 'Chinese',
    'hi': 'Hindi',
    'de': 'German',
    'it': 'Italian',
    'es': 'Spanish',
    'ja': 'Japanese',
  };

  final Map<String, String> _flags = {
    'en': 'assets/united-states.png',
    'ru': 'assets/russia.png',
    'fr': 'assets/france.png',
    'zh-cn': 'assets/china.png',
    'hi': 'assets/india.png',
    'de': 'assets/germany.png',
    'it': 'assets/italy.png',
    'es': 'assets/spain.png',
    'ja': 'assets/japan.png',
  };

  Future<void> _startListening() async {
    if (_speakLanguage == null) {
      _showError("Please select a 'Speak Language' first.");
      return;
    }

    if (!_isListening) {
      final available = await _speech.initialize(
        onStatus: (status) => print("Speech Status: $status"),
        onError: (error) => print("Speech Error: $error"),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _listeningMessage = "Listening..."; // Show listening message
        });

        await _speech.listen(
          localeId: _speakLanguage,
          onResult: (result) {
            setState(() {
              _inputTextController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _listeningMessage = ""; // Clear listening message
      });
      _speech.stop();
    }
  }

  String normalizeLanguageCode(String? code) {
  final languageMap = {
    'en': 'en', // English
    'en-US': 'en',
    'ru': 'ru', // Russian
    'fr': 'fr', // French
    'zh-cn': 'zh-cn', // Chinese
    'hi': 'hi', // Hindi
    'de': 'de', // German
    'it': 'it', // Italian
    'es': 'es', // Spanish
    'ja': 'ja', // Japanese
  };

  return languageMap[code] ?? code!;
}


Future<void> _translateText() async {
  if (_speakLanguage == null || _translateToLanguage == null) {
    _showError("Please select both 'Speak Language' and 'Translate To' language.");
    return;
  }
  if (_inputTextController.text.isEmpty) {
    _showError("Input text is empty. Please speak or type some text.");
    return;
  }

  // Display a SnackBar to indicate translation is in progress
  final snackBar = SnackBar(
    content: Row(
      children: const [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(width: 16),
        Text("Translating... Please wait.")
      ],
    ),
    duration: const Duration(seconds: 10), // Long enough for translation to complete
    backgroundColor: Colors.blue,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  setState(() {
    _isTranslating = true;
    _translations.clear();
  });

  try {
    if (_translateToLanguage == 'all') {
      for (String code in _languagesCode) {
        final translation = await _translator.translate(_inputTextController.text, to: code);
        _translations[code] = translation.text;
      }
    } else {
      final translation = await _translator.translate(_inputTextController.text, to: _translateToLanguage ?? 'en');
      _translations[_translateToLanguage!] = translation.text;
    }
  } catch (e) {
    print("Translation error: $e");
    _showError("Error during translation.");
  } finally {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Dismiss the SnackBar after translation
  }

  setState(() {
    _isTranslating = false;
  });
}



  void _clearFields() {
    setState(() {
      _speakLanguage = null;
      _translateToLanguage = null;
      _inputTextController.clear();
      _translations.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _speak(String text, String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }

  // Inside _TranslationsScreenState
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    resizeToAvoidBottomInset: true, // Prevent overflow when keyboard opens
    appBar: AppBar(
      title: const Text(
        "Translations",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown for Speak Language
            _buildLanguageDropdown(
              label: "Speak Language",
              value: _speakLanguage,
              onChanged: (value) => setState(() {
                _speakLanguage = value;
                if (_translateToLanguage == _speakLanguage) _translateToLanguage = null;
              }),
            ),
            const SizedBox(height: 16),

            // Dropdown for Translate To Language
            _buildLanguageDropdown(
              label: "Translate To",
              value: _translateToLanguage,
              onChanged: (value) => setState(() {
                _translateToLanguage = value;
                if (_translateToLanguage == _speakLanguage) _speakLanguage = null;
              }),
              includeAllOption: true,
            ),
            const SizedBox(height: 16),

            // Voice Recording Section
            GestureDetector(
              onTap: _startListening,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _listeningMessage, // Display listening message
                    style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Text Input Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: TextField(
                controller: _inputTextController,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Type or speak your text here...",
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Translate and Clear Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _translateText,
                  icon: const Icon(Icons.translate, color: Colors.white),
                  label: const Text("Translate", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold, fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearFields,
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Clear", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold, fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Translation Results
            const SizedBox(height: 20),

            // Add a title before translation results
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Translations Completed", // Text you want to show
                style: TextStyle(
                  fontSize: 20, // Larger font size for the title
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Change color if needed
                ),
              ),
            ),
            const SizedBox(height: 10), // Add spacing below the title

            // Display "No translations done yet" message
            if (_translations.isEmpty)
              const Center(
                child: Text(
                  "No translations done yet.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              _isTranslating
                  ? const CircularProgressIndicator()
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _translations.keys
                          .where((key) => key != _speakLanguage) // Filter out the "Speak Language"
                          .length,
                      itemBuilder: (context, index) {
                        final filteredKeys = _translations.keys.where((key) => key != _speakLanguage).toList();
                        final languageCode = filteredKeys[index];
                        final translation = _translations[languageCode]!;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8), // Increased vertical spacing
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Increased padding
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12), // Larger border radius
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                _flags[languageCode]!,
                                width: 40, // Larger flag size
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _languageNames[languageCode]!,
                                      style: const TextStyle(
                                        fontSize: 16, // Larger font size for the language name
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4), // Add spacing between language and translation
                                    Text(
                                      translation,
                                      style: const TextStyle(
                                        fontSize: 18, // Larger font size for the translation
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Speaker icon
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Colors.blue),
                                onPressed: () => _speak(translation, languageCode),
                              ),
                              // Copy icon
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.blue),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: translation));
                                  _showError("Copied to clipboard!");
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ],
        ),
      ),
    ),
  );
}





  Widget _buildLanguageDropdown({
    required String label,
    required String? value,
    required Function(String?) onChanged,
    bool includeAllOption = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 27, 57, 248)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text("Choose a language"),
              isExpanded: true,
              onChanged: onChanged,
              items: [
                if (includeAllOption)
                  const DropdownMenuItem(
                    value: 'all',
                    child: Text('Select All'),
                  ),
               ..._languagesCode.where((code) {
  if (label == "Speak Language") {
    return code != _translateToLanguage; // Exclude Translate To language
  } else if (label == "Translate To") {
    return code != _speakLanguage; // Exclude Speak Language
  }
  return true;
}).map((code) {

                  return DropdownMenuItem(
                    value: code,
                    child: Row(
                      children: [
                        Image.asset(
                          _flags[code]!,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(_languageNames[code]!),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
