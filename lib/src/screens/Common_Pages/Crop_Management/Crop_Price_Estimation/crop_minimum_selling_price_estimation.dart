import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';

class CropMinimumSellingPriceEstimation extends StatefulWidget {
  const CropMinimumSellingPriceEstimation({super.key});

  @override
  _CropMinimumSellingPriceEstimationState createState() =>
      _CropMinimumSellingPriceEstimationState();
}

class _CropMinimumSellingPriceEstimationState
    extends State<CropMinimumSellingPriceEstimation> {
  final TextEditingController cropTypeController = TextEditingController();
  final TextEditingController acreageController = TextEditingController();
  final TextEditingController productionCostController =
      TextEditingController();
  final TextEditingController harvestingCostController =
      TextEditingController();
  final TextEditingController marketCostController = TextEditingController();
  final TextEditingController totalYieldController = TextEditingController();
  final TextEditingController desiredProfitController = TextEditingController();

  double? minSellingPricePerKg;
  double? totalPrice;
  double? profitPerKg;
  double? totalProfit;
  double? currentMarketPrice;

  @override
  void initState() {
    super.initState();
  }

  void calculateSellingPrice() {
    double acreage = double.tryParse(acreageController.text) ?? 1;
    double productionCost =
        (double.tryParse(productionCostController.text) ?? 0) / acreage;
    double harvestingCost =
        (double.tryParse(harvestingCostController.text) ?? 0) / acreage;
    double marketCost =
        (double.tryParse(marketCostController.text) ?? 0) / acreage;
    double totalYield =
        (double.tryParse(totalYieldController.text) ?? 1) / acreage;
    double desiredProfit = double.tryParse(desiredProfitController.text) ?? 0;
    double marketPrice = currentMarketPrice ?? 0;

    double totalCosts = productionCost + harvestingCost + marketCost;
    double minPrice =
        (totalCosts + (totalCosts * (desiredProfit / 100))) / totalYield;

    setState(() {
      minSellingPricePerKg = minPrice;
      totalPrice = minPrice * totalYield * acreage;
      profitPerKg = minPrice - (totalCosts / totalYield);
      totalProfit = profitPerKg! * totalYield;
    });
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
                                        .translate('crop_price_estimation'),
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
                            TextFormField(
                              controller: acreageController,
                              keyboardType: TextInputType.numberWithOptions(),
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('acre')),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: productionCostController,
                              keyboardType: TextInputType.number,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('total_production_cost')),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: harvestingCostController,
                              keyboardType: TextInputType.number,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('total_harvesting_cost')),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: marketCostController,
                              keyboardType: TextInputType.number,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('market_costs')),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: totalYieldController,
                              keyboardType: TextInputType.number,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('total_yield_kg')),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: desiredProfitController,
                              keyboardType: TextInputType.number,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('desired_profit_percent')),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: calculateSellingPrice,
                                  child: Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate(
                                            'calculate_minimum_selling_price'),
                                    style: SmallTextWhite,
                                  ),
                                  style: customButtonStyle1,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            const SizedBox(height: 20),
                            SizedBox(height: 20),
                            buildOutputContainer(),
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
                        '${context.watch<LocalizationService>().translate('minimum_selling_price_per_kg')}:')),
                TextSpan(
                  text: '₹ ${minSellingPricePerKg?.toStringAsFixed(2) ?? '--'}',
                  style: SmallTextGreen,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          RichText(
            text: TextSpan(
              style: TextGrey,
              children: [
                TextSpan(
                    text: context.watch<LocalizationService>().translate(
                        '${context.watch<LocalizationService>().translate('total_selling_price')}:')),
                TextSpan(
                  text: '₹ ${totalPrice?.toStringAsFixed(2) ?? '--'}',
                  style: SmallTextGreen,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          RichText(
            text: TextSpan(
              style: TextGrey,
              children: [
                TextSpan(
                    text: context.watch<LocalizationService>().translate(
                        '${context.watch<LocalizationService>().translate('profit_per_kg')}:')),
                TextSpan(
                  text: '₹ ${profitPerKg?.toStringAsFixed(2) ?? '--'}',
                  style: SmallTextGreen,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          RichText(
            text: TextSpan(
              style: TextGrey,
              children: [
                TextSpan(
                    text: context.watch<LocalizationService>().translate(
                        '${context.watch<LocalizationService>().translate('total_profit_for_crop')} ${cropTypeController.text.isNotEmpty ? cropTypeController.text : context.watch<LocalizationService>().translate('selected_crop')}: ')),
                TextSpan(
                  text: '₹ ${totalProfit?.toStringAsFixed(2) ?? '--'}',
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
