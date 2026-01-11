import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Language/app_localization.dart';
import '../../Customs/constants.dart';
import '../../Customs/custom_page_container_TNschemes_orange.dart';
import '../../Customs/custom_page_container_TNschemes_yellow.dart';
import '../../Customs/custom_page_container_schemes_green.dart';
import '../../Customs/custom_page_container_schemes_orange.dart';
import 'Central Government Schemes Description/Central_herd_Registration_Scheme.dart';
import 'Central Government Schemes Description/Gramin_Agricultural_Markets.dart';
import 'Central Government Schemes Description/Integrated_Scheme_for_Agricultural_Marketing.dart';
import 'Central Government Schemes Description/Marketing_research_and_information_network.dart';
import 'Central Government Schemes Description/Minimum_Support_Price_Scheme.dart';
import 'Central Government Schemes Description/Mission_for_Integrated_Development_of_Horticulture.dart';
import 'Central Government Schemes Description/National_Food_Security_Mission.dart';
import 'Central Government Schemes Description/National_Innovations_on_Climate_Resilient_Agriculture.dart';
import 'Central Government Schemes Description/National_Mission_for_Sustainable_Agriculture.dart';
import 'Central Government Schemes Description/Pradhan_Mantri_Fasal_Bima_Yojana.dart';
import 'Central Government Schemes Description/Pradhan_Mantri_Krishi_Sinchayee_Yojana.dart';
import 'Central Government Schemes Description/Rainfed_Area_Development_Programme.dart';
import 'Central Government Schemes Description/Rashtriya_Krishi_Vikas_Yojana.dart';
import 'Central Government Schemes Description/Sankalp_Se_Siddhi.dart';
import 'Central Government Schemes Description/SubMission_on_Agricultural_Mechanization.dart';
import 'Central Government Schemes Description/SubMission_on_Agroforestry_under_NMSA.dart';
import 'State Government Schemes Description/Chief_Minister_Mannuyir_Kaathu_Mannuyir_Kaappom_Scheme.dart';
import 'State Government Schemes Description/Chief_Minister_Scheme_of_Solar_Powered_Pump_set.dart';
import 'State Government Schemes Description/E_NAM.dart';
import 'State Government Schemes Description/ICAR_KVK_Training.dart';
import 'State Government Schemes Description/Kalaignars_All_Village_Integrated_Agriculture_Development_Programme.dart';
import 'State Government Schemes Description/NADP_Sugarcane_crop_improvement.dart';
import 'State Government Schemes Description/National_Agriculture_Development_Programme.dart';
import 'State Government Schemes Description/National_Horticulture_Mission.dart';
import 'State Government Schemes Description/National_Mission_on_Edible_Oil_Oil_Palm.dart';
import 'State Government Schemes Description/Palmyrah_Development_Mission.dart';
import 'State Government Schemes Description/Pradhan_Mantri_Formalisation_of_Micro_Food_Processing_Enterprises.dart';
import 'State Government Schemes Description/Pradhan_Mantri_Krishi_Sinchayee_yojana_Micro_Irrigation.dart';
import 'State Government Schemes Description/Rainfed_Area_Development.dart';
import 'State Government Schemes Description/State_Horticulture_Development_Scheme.dart';
import 'State Government Schemes Description/Tamil_Nadu_Irrigated_Agriculture_Modernization_Project.dart';
import 'State Government Schemes Description/Uzhavar_sandhai.dart';

class GovernmentSchemesHomepage extends StatefulWidget {
  @override
  GovernmentSchemesHomepageState createState() =>
      GovernmentSchemesHomepageState();
}

class GovernmentSchemesHomepageState extends State<GovernmentSchemesHomepage> {
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
                            const SizedBox(height: 10),
                            Text(
                                context
                                    .watch<LocalizationService>()
                                    .translate('state_government_schemes'),
                                style: SmallTextBlack),
                            const SizedBox(height: 10),
                            CustomPageContainerTnschemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SSMAM'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SubmissionOnAgriculturalMechanization(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesYellow(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SCMMKMK'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChiefMinisterMannuyirKaathuMannuyirKaappomScheme(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // CustomPageContainerTnschemesYellow(
                            //   Header: context
                            //       .watch<LocalizationService>()
                            //       .translate('SKAVIAD'),
                            //   onTap: () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) =>
                            //             KalaignarsAllVillageIntegratedAgricultureDevelopmentProgramme(),
                            //       ),
                            //     );
                            //   },
                            // ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            CustomPageContainerTnschemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('STNIAMP'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TamilNaduIrrigatedAgricultureModernizationProject(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesYellow(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SRAD'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RainfedAreaDevelopment(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SMI'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PradhanMantriKrishiSinchayeeYojanaMicroIrrigation(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesYellow(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SSHDS'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StateHorticultureDevelopmentScheme(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SPDM'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PalmyrahDevelopmentMission(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesYellow(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SCMSSPS'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChiefMinisterSchemeOfSolarPoweredPumpSet(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SNMH'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NationalHorticultureMission(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesYellow(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SNADP'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NationalAgricultureDevelopmentProgramme(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SNMEOP'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NationalMissionOnEdibleOilOilPalm(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesYellow(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SUS'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UzhavarSandhai(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SPMFME'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PradhanMantriFormalisationOfMicroFoodProcessingEnterprises(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesYellow(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SEN'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ENam(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SICAR'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IcarKvkTraining(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerTnschemesYellow(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SNADPS'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NadpSugarcaneCropImprovement(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            const SizedBox(height: 10),
                            Text(
                                context
                                    .watch<LocalizationService>()
                                    .translate('central_government_schemes'),
                                style: SmallTextBlack),
                            const SizedBox(height: 10),

                            CustomPageContainerSchemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CMSP'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MinimumSupportPriceScheme(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesGreen(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CMRIN'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MarketingResearchAndInformationNetwork(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('SNADPS'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CentralHerdRegistrationScheme(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesGreen(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CNFSM'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NationalFoodSecurityMission(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CRKVY'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RashtriyaKrishiVikasYojana(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesGreen(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CNMSA'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NationalMissionForSustainableAgriculture(),
                                  ),
                                );
                              },
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CNICRA'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NationalInnovationsOnClimateResilientAgriculture(),
                                  ),
                                );
                              },
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesGreen(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CISAM'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        IntegratedSchemeForAgriculturalMarketing(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CMIDH'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MissionForIntegratedDevelopmentOfHorticulture(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesGreen(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CSAM'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SubmissionOnAgriculturalMechanization(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CSA'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SubmissionOnAgroforestryUnderNmsa(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesGreen(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CRADP'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RainfedAreaDevelopmentProgramme(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CPMFBY'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PradhanMantriFasalBimaYojana(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesGreen(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CPMKSY'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PradhanMantriKrishiSinchayeeYojana(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesOrange(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CSSS'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SankalpSeSiddhi(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerSchemesGreen(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('CGAM'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GraminAgriculturalMarkets(),
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
