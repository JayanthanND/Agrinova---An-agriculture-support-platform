import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';

class ManageCropYieldPage extends StatefulWidget {
  final String userId;
  final List<dynamic> crops;

  const ManageCropYieldPage(
      {super.key, required this.userId, required this.crops});

  @override
  _ManageCropYieldPageState createState() => _ManageCropYieldPageState();
}

class _ManageCropYieldPageState extends State<ManageCropYieldPage> {
  List<Map<String, dynamic>> crops = []; // List of crops to manage
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    super.initState();
    // If crops are passed directly to the page, use them. Otherwise, fetch from Firestore.
    if (widget.crops.isNotEmpty) {
      crops = List<Map<String, dynamic>>.from(widget.crops);
    } else {
      fetchCropsFromFirestore();
    }
    print("UserId: ${widget.userId}"); // Debug: Check if userId is valid
  }

  // Fetch crop data from Firestore
  Future<void> fetchCropsFromFirestore() async {
    try {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.userId)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        if (data != null && data['crops'] != null) {
          setState(() {
            crops = List<Map<String, dynamic>>.from(data['crops']);
          });
        } else {
          print("No crops found in Firestore for this user.");
        }
      } else {
        print("User not found in Firestore.");
      }
    } catch (e) {
      print("Error fetching crops from Firestore: $e");
    }
  }

  // Save updated crop details to Firestore
  Future<void> saveCrops() async {
    if (widget.userId.isEmpty) {
      print("Error: userId is empty or null");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid user ID')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.userId)
          .update({'crops': crops});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Crops updated successfully!'),
          backgroundColor: Colors.green.withOpacity(0.9),
        ),
      );
    } catch (e) {
      print("Error saving crops: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error saving crops'),
          backgroundColor: Colors.red.withOpacity(0.9),
        ),
      );
    }
  }

  // Delete a crop entry
  Future<void> deleteCrop(int index) async {
    // First, delete the crop from the UI list
    setState(() {
      crops.removeAt(index);
    });

    // Now, update the Firestore document
    try {
      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.userId)
          .update({'crops': crops});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Crop deleted successfully!'),
          backgroundColor: Colors.green.withOpacity(0.9),
        ),
      );
    } catch (e) {
      print("Error deleting crop from Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error deleting crop'),
          backgroundColor: Colors.red.withOpacity(0.9),
        ),
      );
    }
  }

  // Add a new crop entry
  void addCrop() {
    setState(() {
      crops.add({
        'cropType': '',
        'totalYield': 0,
        'sellingPrice': 0.0,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1ACD36),
      body: Stack(
        children: [
          // Main content scrollable
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xff1ACD36),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
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
                      const SizedBox(
                        height: 10,
                      ),
                      Line,
                      MainContainer1(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                    width: 200,
                                    child: Text(
                                      context
                                          .watch<LocalizationService>()
                                          .translate('manage_crop_yield'),
                                      style: NormalTextGrey,
                                    )),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                  onPressed: addCrop, // Add a new crop
                                ),
                              ],
                            ),
                            Divider(),
                            crops.isEmpty
                                ? Center(
                                    child: Text(
                                      context
                                          .watch<LocalizationService>()
                                          .translate('no_crops_found'),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets
                                        .zero, // Remove any default padding for ListView
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: crops.length,
                                    itemBuilder: (context, index) {
                                      TextEditingController cropTypeController =
                                          TextEditingController(
                                              text: crops[index]['cropType']);
                                      TextEditingController yieldController =
                                          TextEditingController(
                                              text: crops[index]['totalYield']
                                                  .toString());
                                      TextEditingController priceController =
                                          TextEditingController(
                                              text: crops[index]['sellingPrice']
                                                  .toString());

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Card(
                                          margin: const EdgeInsets.all(0),
                                          color: Colors.grey[200],
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      context
                                                          .watch<
                                                              LocalizationService>()
                                                          .translate(
                                                              'crop_details'),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.grey),
                                                      onPressed: () {
                                                        deleteCrop(
                                                            index); // Delete crop from Firestore and UI
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Crop Type Field
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 1,
                                                            blurRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: TextField(
                                                        controller:
                                                            cropTypeController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: context
                                                              .watch<
                                                                  LocalizationService>()
                                                              .translate(
                                                                  'crop_type'),
                                                          // Label for input field
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        onChanged: (value) =>
                                                            crops[index][
                                                                    'cropType'] =
                                                                value,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height:
                                                            10), // Spacing between fields

                                                    // Total Yield Field
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 1,
                                                            blurRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: TextField(
                                                        controller:
                                                            yieldController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: context
                                                              .watch<
                                                                  LocalizationService>()
                                                              .translate(
                                                                  'total_yield'), // Label for input field
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) => crops[
                                                                    index]
                                                                ['totalYield'] =
                                                            int.tryParse(
                                                                    value) ??
                                                                0,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height:
                                                            10), // Spacing between fields

                                                    // Selling Price Field
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 1,
                                                            blurRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: TextField(
                                                        controller:
                                                            priceController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: context
                                                              .watch<
                                                                  LocalizationService>()
                                                              .translate(
                                                                  'selling_price'), // Label for input field
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) => crops[
                                                                    index][
                                                                'sellingPrice'] =
                                                            double.tryParse(
                                                                    value) ??
                                                                0.0,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Save Changes button fixed at the bottom
          Positioned(
            bottom: 0, // Adjust the distance from the bottom
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6.0),
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              child: Center(
                child: ElevatedButton(
                  onPressed: saveCrops, // Save crops when clicked
                  child: Text(
                    context
                        .watch<LocalizationService>()
                        .translate('save_changes'),
                    style: SmallTextWhite,
                    textAlign: TextAlign.center,
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    shadowColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 15),
                    backgroundColor: Color(0xff1ACD36),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
