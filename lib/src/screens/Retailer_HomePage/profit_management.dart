import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_agrinova/src/screens/Customs/formFieldWidget.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';
import '../Customs/follow_request_container.dart';

class ProfitManagement extends StatefulWidget {
  const ProfitManagement({super.key});

  @override
  _ProfitManagementState createState() => _ProfitManagementState();
}

class _ProfitManagementState extends State<ProfitManagement> {
  final TextEditingController cropTypeController = TextEditingController();
  final TextEditingController totalYieldController = TextEditingController();
  final TextEditingController purchaseCostController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();

  double? profitAmount;
  double? profitPercentage;
  String? cropName;

  void calculateProfit() {
    double totalYield = double.tryParse(totalYieldController.text) ?? 0;
    double purchaseCost = double.tryParse(purchaseCostController.text) ?? 0;
    double sellingPrice = double.tryParse(sellingPriceController.text) ?? 0;
    cropName = cropTypeController.text;

    if (totalYield > 0 && purchaseCost > 0 && sellingPrice > 0) {
      double profit = (sellingPrice - purchaseCost) * totalYield;
      double percentage = ((sellingPrice - purchaseCost) / purchaseCost) * 100;
      setState(() {
        profitAmount = profit;
        profitPercentage = percentage;
      });
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
                                Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('profit_management'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: cropTypeController,
                              keyboardType: TextInputType.text,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('crop_name')),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: totalYieldController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    decoration: InputFieldBox(context
                                        .watch<LocalizationService>()
                                        .translate('total_kg_bought')),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: purchaseCostController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    decoration: InputFieldBox(context
                                        .watch<LocalizationService>()
                                        .translate('purchase_cost_per_kg')),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: sellingPriceController,
                              keyboardType: TextInputType.numberWithOptions(),
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('selling_price_per_kg')),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Call _login function when the button is pressed
                                    calculateProfit();
                                  },
                                  child: Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate(context
                                            .watch<LocalizationService>()
                                            .translate('calculate_profit')),
                                    style: SmallTextWhite,
                                  ),
                                  style: customButtonStyle1,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            const SizedBox(height: 20),
                            buildOutputContainer()
                          ],
                        ),
                      )
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

  Widget buildOutputContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints(maxWidth: double.infinity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              context.watch<LocalizationService>().translate('profit_results'),
              style: TextBlack,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: TextGrey,
              children: [
                TextSpan(
                    text: context.watch<LocalizationService>().translate(
                        '${context.watch<LocalizationService>().translate('total_profit_for_crop')} ${cropTypeController.text.isNotEmpty ? cropTypeController.text : context.watch<LocalizationService>().translate('selected_crop')}: ')),
                TextSpan(
                  text: '₹ ${profitAmount?.toStringAsFixed(2) ?? '--'}',
                  style: SmallTextGreen,
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextGrey,
              children: [
                TextSpan(
                    text:
                        '${context.watch<LocalizationService>().translate('profit_percent')}:'),
                TextSpan(
                  text: '${profitPercentage?.toStringAsFixed(2) ?? '--'}%',
                  style: SmallTextGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
