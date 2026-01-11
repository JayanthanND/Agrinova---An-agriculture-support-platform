// language_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Language/app_localization.dart';
import 'login_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  void _saveLanguageAndProceed() async {
    if (_selectedLanguage != null) {
      await LocalizationService().setLanguage(_selectedLanguage!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1ACD36),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xff1ACD36),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                padding: EdgeInsets.only(top: 0, left: 25),
                                icon: Icon(Icons.arrow_back_ios,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('app_name'),
                                    style: TitleStyle),
                                const SizedBox(height: 5),
                                Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('tagline'),
                                    style: SmallTextWhite),
                              ],
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Line,
                      MainContainer1(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text("Select Language", style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            const SizedBox(height: 190),

                            // Centered content
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: _selectedLanguage,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      labelStyle: TextStyle(
                                        fontFamily: 'Alatsi',
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: Color(0xff1ACD36),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'en', child: Text("English")),
                                      DropdownMenuItem(
                                          value: 'ta', child: Text("தமிழ்")),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedLanguage = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: _saveLanguageAndProceed,
                                    style: customButtonStyle1,
                                    child:
                                        Text("Select", style: SmallTextWhite),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
