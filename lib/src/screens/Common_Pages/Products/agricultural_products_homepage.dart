import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



import '../../../Language/app_localization.dart';
import '../../Customs/constants.dart';
import '../../Customs/custom_page_container_withimage.dart';
import 'Specific_Product_Types/SpecificProductTypes_Agriculture_tools.dart';
import 'Specific_Product_Types/SpecificProductTypes_Combine_Harvesters.dart';
import 'Specific_Product_Types/SpecificProductTypes_Fencing.dart';
import 'Specific_Product_Types/SpecificProductTypes_Greenhouses.dart';
import 'Specific_Product_Types/SpecificProductTypes_Harvesting_tools.dart';
import 'Specific_Product_Types/SpecificProductTypes_Irrigation_Machines.dart';
import 'Specific_Product_Types/SpecificProductTypes_Seeders_and_Planters.dart';
import 'Specific_Product_Types/SpecificProductTypes_Soil_sensors.dart';
import 'Specific_Product_Types/SpecificProductTypes_Tractor.dart';
import 'package:provider/provider.dart';

class AgriculturalProductsHomepage extends StatefulWidget {
  @override
  _AgriculturalProductsHomepageState createState() =>
      _AgriculturalProductsHomepageState();
}

class _AgriculturalProductsHomepageState
    extends State<AgriculturalProductsHomepage> {
// Variable to store the farmer's selected need

  @override
  void initState() {
    super.initState();
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
                                  context.watch<LocalizationService>().translate('app_name'), style: TitleStyle),
                              const SizedBox(height: 5),
                              Text(context.watch<LocalizationService>().translate('tagline'),
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
                                Text(context.watch<LocalizationService>().translate('agri_products'),  style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('T'),
                              imagePath: 'assets/images/Agri_Products/Tractor.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpecificproducttypesTractor(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header:  context.watch<LocalizationService>().translate('CH'),
                              imagePath: 'assets/images/Agri_Products/Combine Harvesters.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpecificproducttypesCombineHarvesters(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('IM'),
                              imagePath: 'assets/images/Agri_Products/Irrigation Machines.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpecificproducttypesIrrigationMachines(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('GH'),
                              imagePath: 'assets/images/Agri_Products/Green house.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpecificproducttypesGreenhouses(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('F'),
                              imagePath: 'assets/images/Agri_Products/Fencing.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpecificproducttypesFencing(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header:  context.watch<LocalizationService>().translate('SS'),
                              imagePath: 'assets/images/Agri_Products/soil sensor.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpecificproducttypesSoilSensors(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header:  context.watch<LocalizationService>().translate('AT'),
                              imagePath: 'assets/images/Agri_Products/at.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpecificproducttypesAgricultureTools(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header:  context.watch<LocalizationService>().translate('HT'),
                              imagePath: 'assets/images/Agri_Products/ht.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpecificproducttypesHarvestingTools(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header:  context.watch<LocalizationService>().translate('SP'),
                              imagePath: 'assets/images/Agri_Products/sp.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpecificproducttypesSeedersAndPlanters(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
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
