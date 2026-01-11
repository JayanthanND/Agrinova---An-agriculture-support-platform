import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../../../Language/app_localization.dart';
import '../../../../Customs/constants.dart';
import '../../../../Customs/custom_page_container_withimage.dart';
import '../../Specific_Product_types_description/Agriculture_tools/Plow/ChiselPlows_description.dart';
import '../../Specific_Product_types_description/Agriculture_tools/Plow/DiscPlows_description.dart';
import '../../Specific_Product_types_description/Agriculture_tools/Plow/MoldboardPlows_description.dart';
import '../../Specific_Product_types_description/Agriculture_tools/Plow/RotaryPlow_description.dart';

class PlowTypes extends StatefulWidget {
  @override
  _PlowTypesState createState() =>
      _PlowTypesState();
}
class _PlowTypesState
    extends State<PlowTypes> {
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
                              Text(context.watch<LocalizationService>().translate('app_name'), style: TitleStyle),
                              const SizedBox(height: 5),
                              Text(context.watch<LocalizationService>().translate('tagline'),  style: SmallTextWhite),
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
                            Text(
                              context.watch<LocalizationService>().translate('AT-P'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),

                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TATPM'),
                              imagePath:'assets/images/Agri_Products/moldboard plow.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MoldboardplowsDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TATPC'),
                              imagePath:'assets/images/Agri_Products/chisel plow.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChiselplowsDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TATPD'),
                              imagePath:'assets/images/Agri_Products/disk plow.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DiscplowsDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TATPR'),
                              imagePath:'assets/images/Agri_Products/rotary plow.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RotaryplowDescription()),
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
