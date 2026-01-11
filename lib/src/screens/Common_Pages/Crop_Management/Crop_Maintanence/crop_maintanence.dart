import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';

class CropMaintenanceApp extends StatefulWidget {
  @override
  _CropMaintenanceAppState createState() => _CropMaintenanceAppState();
}

class _CropMaintenanceAppState extends State<CropMaintenanceApp> {
  Interpreter? interpreter;
  String? maintenanceAdvice;
  Map<String, dynamic>? maintenanceDetails;

  // Form fields
  String selectedCrop = "crop_barley";
  String selectedSoilMoisture = "moisture_low";
  int growthDay = 30;
  String selectedWeather = "weather_sunny";
  String selectedDisease = "disease_none";

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
          'assets/final_crop_maintenance_model.tflite');
      print("✅ Maintenance Model Loaded Successfully!");
    } catch (e) {
      print("❌ Error loading maintenance model: $e");
    }
  }

  Future<void> predictMaintenance() async {
    if (interpreter == null) {
      setState(() {
        maintenanceAdvice = "Model not loaded";
      });
      return;
    }
    final localizations = context.read<LocalizationService>();

    // Define the lists here since they're only used in this method
    List<String> cropKeys = [
      "crop_barley",
      "crop_cotton",
      "crop_groundnut",
      "crop_maize",
      "crop_millets",
      "crop_rice",
      "crop_sugarcane",
      "crop_wheat"
    ];
    List<String> moistureKeys = [
      "moisture_low",
      "moisture_medium",
      "moisture_high"
    ];
    List<String> weatherKeys = [
      "weather_sunny",
      "weather_cloudy",
      "weather_rainy",
      "weather_windy"
    ];
    List<String> diseaseKeys = [
      "disease_none",
      "disease_mild",
      "disease_moderate",
      "disease_severe"
    ];

    // Prepare input data (normalize growth day - this should match your Python preprocessing)
    double normalizedGrowthDay =
        (growthDay - 60) / 30.0; // Example normalization

    List<double> inputData = [
      cropKeys.indexOf(selectedCrop).toDouble(),
      moistureKeys.indexOf(selectedSoilMoisture).toDouble(),
      normalizedGrowthDay,
      weatherKeys.indexOf(selectedWeather).toDouble(),
      diseaseKeys.indexOf(selectedDisease).toDouble(),
    ];

    var input = Float32List.fromList(inputData);
    var outputTensor = interpreter!.getOutputTensor(0);
    var outputShape = outputTensor.shape;
    int outputSize = outputShape.reduce((a, b) => a * b);
    var output = List<double>.filled(outputSize, 0.0).reshape(outputShape);

    interpreter!.run(input, output);

    // Get the predicted crop index
    List<double> outputList = List<double>.from(output[0]);
    int predictedCropIndex =
        outputList.indexOf(outputList.reduce((a, b) => a > b ? a : b));
    String predictedCrop = cropKeys[predictedCropIndex];
    // Generate maintenance advice based on inputs (this would be enhanced with your actual logic)
    setState(() {
      maintenanceDetails = {
        'crop': selectedCrop, // <- Use user's selected crop instead
        'moisture': selectedSoilMoisture,
        'disease': selectedDisease,
        'advice': getMaintenanceDetails(
            localizations,
            predictedCrop,
            selectedSoilMoisture,
            normalizedGrowthDay,
            selectedWeather,
            selectedDisease),
      };
    });
  }

  String getMaintenanceDetails(
    LocalizationService localizations, // Accept service directly
    String cropKey,
    String soilMoistureKey,
    double growthDay,
    String weatherKey,
    String diseaseKey,
  ) {
    String cropName = localizations.translate(cropKey);
    String diseaseLevel = localizations.translate(diseaseKey);

    // Base message
    String base = localizations
        .translate('maintenance_base')
        .replaceAll('{crop}', cropName)
        .replaceAll('{disease}', diseaseLevel);

    // Soil moisture advice
    if (soilMoistureKey == "moisture_high") {
      base += " ${localizations.translate('advice_waterlogging')}";
    } else if (soilMoistureKey == "moisture_low") {
      base += " ${localizations.translate('advice_irrigation')}";
    }

    // Disease advice
    if (diseaseKey != "disease_none") {
      base += " ${localizations.translate('advice_fungal')}";
    }

    // Weather advice
    if (weatherKey == "weather_sunny") {
      base += " ${localizations.translate('advice_sunny')}";
    } else if (weatherKey == "weather_rainy") {
      base += " ${localizations.translate('advice_rainy')}";
    }

    // Growth day specific advice
    if (growthDay < 30) {
      base += " ${localizations.translate('advice_young_plants')}";
    } else if (growthDay > 90) {
      base += " ${localizations.translate('advice_mature_plants')}";
    }

    // General advice
    base += " ${localizations.translate('advice_general')}";

    return base;
  }

  @override
  Widget build(BuildContext context) {
    List<String> cropKeys = [
      "crop_barley",
      "crop_cotton",
      "crop_groundnut",
      "crop_maize",
      "crop_millets",
      "crop_rice",
      "crop_sugarcane",
      "crop_wheat"
    ];
    List<String> moistureKeys = [
      "moisture_low",
      "moisture_medium",
      "moisture_high"
    ];
    List<String> weatherKeys = [
      "weather_sunny",
      "weather_cloudy",
      "weather_rainy",
      "weather_windy"
    ];
    List<String> diseaseKeys = [
      "disease_none",
      "disease_mild",
      "disease_moderate",
      "disease_severe"
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
                                        .translate('crop_maintenance'),
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
                                        .translate('crop_maintenance'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            const SizedBox(height: 10),

                            // Crop Type Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedCrop,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('crop_type')),
                              items: cropKeys.map((key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(context
                                      .watch<LocalizationService>()
                                      .translate(key)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedCrop = val!),
                            ),
                            const SizedBox(height: 20),

                            // Soil Moisture Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedSoilMoisture,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('soil_moisture')),
                              items: moistureKeys.map((key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(context
                                      .watch<LocalizationService>()
                                      .translate(key)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedSoilMoisture = val!),
                            ),
                            const SizedBox(height: 20),

                            // Growth Day Slider
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('growth_day'),
                                  style: TextStyle(
                                    fontFamily: 'Alatsi',
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Slider(
                                  activeColor: MainGreen,
                                  value: growthDay.toDouble(),
                                  min: 1,
                                  max: 120,
                                  divisions: 119,
                                  label: '$growthDay days',
                                  onChanged: (value) =>
                                      setState(() => growthDay = value.toInt()),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Weather Forecast Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedWeather,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('weather_forecast')),
                              items: weatherKeys.map((key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(context
                                      .watch<LocalizationService>()
                                      .translate(key)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedWeather = val!),
                            ),
                            const SizedBox(height: 20),

                            // Disease Presence Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedDisease,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('disease_presence')),
                              items: diseaseKeys.map((key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(context
                                      .watch<LocalizationService>()
                                      .translate(key)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => selectedDisease = val!),
                            ),
                            const SizedBox(height: 20),

                            // Predict Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: predictMaintenance,
                                  child: Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('get_advice'),
                                    style: SmallTextWhite,
                                  ),
                                  style: customButtonStyle1,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Results Display
                            maintenanceDetails == null
                                ? Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('select_inputs'),
                                    style: TextStyle(fontSize: 16),
                                  )
                                : buildMaintenanceOutput(maintenanceDetails!)
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

  Widget buildMaintenanceOutput(Map<String, dynamic> details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  .translate('maintenance_advice'),
              style: TextBlack,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15),

          // Crop Type
          RichText(
            text: TextSpan(
              style: TextGrey,
              children: [
                TextSpan(
                  text:
                      "${context.read<LocalizationService>().translate('crop_type')}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: context
                      .read<LocalizationService>()
                      .translate(details['crop']),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Soil Moisture
          RichText(
            text: TextSpan(
              style: TextGrey,
              children: [
                TextSpan(
                  text:
                      "${context.read<LocalizationService>().translate('soil_moisture')}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: context
                      .read<LocalizationService>()
                      .translate(details['moisture']),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Disease Presence
          RichText(
            text: TextSpan(
              style: TextGrey,
              children: [
                TextSpan(
                  text:
                      "${context.read<LocalizationService>().translate('disease_presence')}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: context
                      .read<LocalizationService>()
                      .translate(details['disease']),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Maintenance Advice
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              details['advice'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
