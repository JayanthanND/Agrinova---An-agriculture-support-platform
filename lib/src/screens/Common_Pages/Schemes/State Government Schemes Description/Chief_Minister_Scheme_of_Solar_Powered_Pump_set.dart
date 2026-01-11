import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';

class ChiefMinisterSchemeOfSolarPoweredPumpSet extends StatefulWidget {
  const ChiefMinisterSchemeOfSolarPoweredPumpSet({super.key});

  @override
  State<ChiefMinisterSchemeOfSolarPoweredPumpSet> createState() =>
      _ChiefMinisterSchemeOfSolarPoweredPumpSetState();
}

class _ChiefMinisterSchemeOfSolarPoweredPumpSetState
    extends State<ChiefMinisterSchemeOfSolarPoweredPumpSet> {
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
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              padding: const EdgeInsets.only(
                                  top: 0, left: 30, bottom: 14),
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 15),
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
                                const SizedBox(width: 10),
                                Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('government_schemes'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            Center(
                              child: Text(
                                context
                                    .watch<LocalizationService>()
                                    .translate('SCMSSPS'),
                                style: NormalTextBlack,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Text(
                                context
                                    .watch<LocalizationService>()
                                    .translate('scheme_description'),
                                style: TextBlack),

                            Text(
                              context
                                  .watch<LocalizationService>()
                                  .translate('CMSSPPS'),
                              textAlign: TextAlign.justify,
                              style: TextGrey,
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Image.asset(
                                'assets/images/government_schemes/state_government_schemes/solar1.jpg',
                                height: 300,
                                width: 300,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Image.asset(
                                'assets/images/government_schemes/state_government_schemes/solar2.png',
                                height: 300,
                                width: 300,
                              ),
                            ),
                            // Display follow requests dynamically based on farmer's need
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
