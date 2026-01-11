import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';

class CropSuggestionApp extends StatefulWidget {
  @override
  _CropSuggestionAppState createState() => _CropSuggestionAppState();
}

class _CropSuggestionAppState extends State<CropSuggestionApp> {
  Interpreter? interpreter;
  String? suggestedCrop;
  List<MapEntry<String, double>>? topCrops;

  String selectedSeason = "season_0";
  String selectedLandType = "land_type_0";
  String selectedSoilType = "soil_type_0";
  String selectedWaterSource = "water_source_0";
  String selectedPreviousCrop = "previous_crop_0";
  double landSize = 2.5;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
          'assets/final_crop_suggestion_model.tflite');
      print("✅ Model Loaded Successfully!");
    } catch (e) {
      print("❌ Error loading model: $e");
    }
  }

  Future<void> predictCrop() async {
    if (interpreter == null) {
      setState(() {
        suggestedCrop = "Model not loaded";
      });
      return;
    }

    // Define the lists here since they're only used in this method
    List<String> seasonKeys = ["season_0", "season_1", "season_2"];
    List<String> landTypeKeys = ["land_type_0", "land_type_1", "land_type_2"];
    List<String> soilTypeKeys = ["soil_type_0", "soil_type_1", "soil_type_2"];
    List<String> waterSourceKeys = [
      "water_source_0",
      "water_source_1",
      "water_source_2"
    ];
    List<String> previousCropKeys = [
      "previous_crop_0",
      "previous_crop_1",
      "previous_crop_2",
      "previous_crop_3",
      "previous_crop_4",
      "previous_crop_5",
      "previous_crop_6",
      "previous_crop_7",
      "previous_crop_8",
      "previous_crop_9",
      "previous_crop_10",
      "previous_crop_11",
      "previous_crop_12",
      "previous_crop_13",
      "previous_crop_14",
      "previous_crop_15"
    ];
    List<String> suggestedCropKeys = [
      "suggested_crop_0",
      "suggested_crop_1",
      "suggested_crop_2",
      "suggested_crop_3",
      "suggested_crop_4",
      "suggested_crop_5",
      "suggested_crop_6",
      "suggested_crop_7",
      "suggested_crop_8",
      "suggested_crop_9",
      "suggested_crop_10",
      "suggested_crop_11",
      "suggested_crop_12",
      "suggested_crop_13",
      "suggested_crop_14",
      "suggested_crop_15",
      "suggested_crop_16",
      "suggested_crop_17",
      "suggested_crop_18",
      "suggested_crop_19",
      "suggested_crop_20",
      "suggested_crop_21",
      "suggested_crop_22",
      "suggested_crop_23",
      "suggested_crop_24",
    ];

    // Prepare input data
    List<double> inputData = [
      seasonKeys.indexOf(selectedSeason).toDouble(),
      landTypeKeys.indexOf(selectedLandType).toDouble(),
      soilTypeKeys.indexOf(selectedSoilType).toDouble(),
      waterSourceKeys.indexOf(selectedWaterSource).toDouble(),
      landSize,
      previousCropKeys.indexOf(selectedPreviousCrop).toDouble(),
    ];
    var input = Float32List.fromList(inputData);
    var outputTensor = interpreter!.getOutputTensor(0);
    var outputShape = outputTensor.shape;
    int outputSize = outputShape.reduce((a, b) => a * b);
    var output = List.filled(outputSize, 0.0).reshape(outputShape);

    interpreter!.run(input, output);

    List<MapEntry<String, double>> cropProbabilities = [];
    int numCrops = outputSize < suggestedCropKeys.length
        ? outputSize
        : suggestedCropKeys.length;

    for (int i = 0; i < numCrops; i++) {
      cropProbabilities.add(MapEntry(suggestedCropKeys[i], output[0][i]));
    }

    cropProbabilities.sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      topCrops =
          cropProbabilities.where((entry) => entry.value * 100 >= 10).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> seasonKeys = ["season_0", "season_1", "season_2"];
    List<String> landTypeKeys = ["land_type_0", "land_type_1", "land_type_2"];
    List<String> soilTypeKeys = ["soil_type_0", "soil_type_1", "soil_type_2"];
    List<String> waterSourceKeys = [
      "water_source_0",
      "water_source_1",
      "water_source_2"
    ];
    List<String> previousCropKeys = [
      "previous_crop_0",
      "previous_crop_1",
      "previous_crop_2",
      "previous_crop_3",
      "previous_crop_4",
      "previous_crop_5",
      "previous_crop_6",
      "previous_crop_7",
      "previous_crop_8",
      "previous_crop_9",
      "previous_crop_10",
      "previous_crop_11",
      "previous_crop_12",
      "previous_crop_13",
      "previous_crop_14",
      "previous_crop_15"
    ];

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
                                        .translate('crop_suggestion'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedSeason,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('season')),
                              items: seasonKeys.map((key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(context
                                      .watch<LocalizationService>()
                                      .translate(key)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedSeason = val!),
                            ),
                            const SizedBox(height: 20),

                            // Land Type Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedLandType,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('land_type')),
                              items: landTypeKeys.map((key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(context
                                      .watch<LocalizationService>()
                                      .translate(key)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedLandType = val!),
                            ),
                            const SizedBox(height: 20),

                            // Soil Type Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedSoilType,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('soil_type')),
                              items: soilTypeKeys.map((key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(context
                                      .watch<LocalizationService>()
                                      .translate(key)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedSoilType = val!),
                            ),
                            const SizedBox(height: 20),

                            // Water Source Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedWaterSource,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('water_source')),
                              items: waterSourceKeys.map((key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(context
                                      .watch<LocalizationService>()
                                      .translate(key)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedWaterSource = val!),
                            ),
                            const SizedBox(height: 20),

                            // Previous Crop Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedPreviousCrop,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('previous_crop')),
                              items: previousCropKeys.map((key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(context
                                      .watch<LocalizationService>()
                                      .translate(key)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedPreviousCrop = val!),
                            ),
                            const SizedBox(height: 20),

                            // Land Size Slider
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('land_size'),
                                  style: TextStyle(
                                    fontFamily: 'Alatsi',
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Slider(
                                  activeColor: MainGreen,
                                  value: landSize,
                                  min: 0.5,
                                  max: 100.0,
                                  divisions: 200,
                                  label:
                                      '${landSize.toStringAsFixed(1)} ${context.watch<LocalizationService>().translate('acres')}',
                                  onChanged: (value) =>
                                      setState(() => landSize = value),
                                ),
                              ],
                            ),

                            // Predict Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: predictCrop,
                                  child: Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('predict_crop'),
                                    style: SmallTextWhite,
                                  ),
                                  style: customButtonStyle1,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Results Display
                            topCrops == null
                                ? Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('select_inputs'),
                                    style: TextStyle(fontSize: 16),
                                  )
                                : buildPredictionOutput(topCrops!)
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

  Widget buildPredictionOutput(List<MapEntry<String, double>> topCrops) {
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
              context
                  .watch<LocalizationService>()
                  .translate('top_suggested_crops'),
              style: TextBlack,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          ...topCrops.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextGrey,
                  children: [
                    TextSpan(
                      text:
                          "${context.read<LocalizationService>().translate(entry.key)}: ",
                    ),
                    TextSpan(
                      text: "${(entry.value * 100).round()}%",
                      style: SmallTextGreen,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
