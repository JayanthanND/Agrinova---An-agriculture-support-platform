import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(context
                  .watch<LocalizationService>()
                  .translate('password_reset_success')),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1ACD36),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: const Color(0xff1ACD36),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      context
                          .watch<LocalizationService>()
                          .translate('app_name'),
                      style: TitleStyle,
                    ),
                    Text(
                      context.watch<LocalizationService>().translate('tagline'),
                      style: SmallTextWhite,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.3, horizontal: 0),
                      margin: EdgeInsets.only(
                          bottom: 8, top: 0, left: 10, right: 10),
                      color: Colors.white,
                    ),
                    MainContainer(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment
                                .topLeft, // Aligns the arrow to the left
                            child: IconButton(
                              padding: EdgeInsets.only(top: 10),
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Colors.grey),
                              onPressed: () {
                                Navigator.pop(
                                    context); // Navigate back when pressed
                              },
                            ),
                          ),
                          Positioned.fill(
                            child: Lottie.asset(
                              'assets/farmer.json',
                              fit: BoxFit.cover,
                              repeat: true,
                              width: 180,
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              context
                                  .watch<LocalizationService>()
                                  .translate('password_reset_prompt'),
                              style: SmallTextGrey,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputFieldBox(
                              context
                                  .watch<LocalizationService>()
                                  .translate('email'),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context
                                    .watch<LocalizationService>()
                                    .translate('email_error_empty');
                              } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch(value)) {
                                return context
                                    .watch<LocalizationService>()
                                    .translate('email_error_invalid');
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: passwordReset,
                                child: Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('reset_password'),
                                  style: SmallTextWhite,
                                ),
                                style: customButtonStyle1,
                              )),
                          // Add your input field and button here
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
