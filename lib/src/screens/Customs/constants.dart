import 'package:flutter/material.dart';

Color? MainGreen = const Color(0xff1ACD36);
Color? FieldBoxColor = Colors.grey[200];
Color? ButtonColor = Colors.grey[700];
Color? WhiteText = Colors.white;
Color? BlackText = Colors.black;
Color? BoxColor = const Color(0xffD9D9D9);

TextStyle? SmallTextWhite =
    const TextStyle(fontFamily: 'Alatsi', fontSize: 15, color: Colors.white);
TextStyle? SmallTextGreen = const TextStyle(
    fontFamily: 'Alatsi', fontSize: 15, color: Color(0xff1ACD36));
TextStyle? SmallTextGrey = const TextStyle(
    fontFamily: 'Alatsi', fontSize: 15, color: Color(0xff7F7171));
TextStyle? SmallTextBlue =
    const TextStyle(fontFamily: 'Alatsi', fontSize: 15, color: Colors.blue);
TextStyle? SmallTextRed =
    const TextStyle(fontFamily: 'Alatsi', fontSize: 15, color: Colors.red);
TextStyle? SmallTextBlack =
    const TextStyle(fontFamily: 'Alatsi', fontSize: 15, color: Colors.black);
TextStyle? TextBlack =
    const TextStyle(fontFamily: 'Alatsi', fontSize: 17, color: Colors.black);
TextStyle? TextGrey = const TextStyle(
    fontFamily: 'Alatsi', fontSize: 17, color: Color(0xff7F7171));
TextStyle? NormalTextGrey = const TextStyle(
    fontFamily: 'Alatsi', fontSize: 20, color: Color(0xff7F7171));
TextStyle? NormalTextWhite =
    const TextStyle(fontFamily: 'Alatsi', fontSize: 20, color: Colors.white);
TextStyle? NormalTextRed =
    const TextStyle(fontFamily: 'Alatsi', fontSize: 20, color: Colors.red);
TextStyle? NormalTextBlack =
    const TextStyle(fontFamily: 'Alatsi', fontSize: 24, color: Colors.black);
TextStyle? TitleStyle =
    const TextStyle(fontFamily: 'Alatsi', fontSize: 32, color: Colors.white);

InputDecoration InputFieldBox(String labtext) {
  return InputDecoration(
    labelText: labtext, // Use the passed label text
    labelStyle: TextStyle(fontFamily: 'Alatsi', color: Colors.grey),

    filled: true,
    fillColor: Colors.grey[200],
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Color(0xff1ACD36),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
  );
}

Container MainContainer({required Widget child}) {
  // You need to return the Container widget
  return Container(
    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
    margin: const EdgeInsets.only(right: 10, left: 10),
    constraints: BoxConstraints(minWidth: 400, minHeight: 685),

    decoration: BoxDecoration(
      // image: DecorationImage(
      //   image: AssetImage('assets/images/paddy_bg.jpg'),
      //   opacity: .4,
      // ),
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child, // Include the child parameter
  );
}

Container Line = Container(
  padding: EdgeInsets.symmetric(vertical: 0.3, horizontal: 0),
  margin: EdgeInsets.only(bottom: 8, top: 0, left: 10, right: 10),
  color: Colors.white,
);
Container LineGrey = Container(
  padding: EdgeInsets.symmetric(vertical: 0.3, horizontal: 0),
  margin: EdgeInsets.only(bottom: 8, top: 0, left: 10, right: 10),
  color: Colors.grey,
);

ButtonStyle customButtonStyle1 = ElevatedButton.styleFrom(
    elevation: 20,
    padding: const EdgeInsets.symmetric(
        horizontal: 35, vertical: 10), // Button padding
    backgroundColor: Colors.grey[700], // Button background color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20), // Button shape (rounded corners)
    ));

Widget circularImageButtonWithText(
    VoidCallback onPressed, String imagePath, String labelText) {
  return Column(
    mainAxisSize: MainAxisSize.min, // Take minimum space
    crossAxisAlignment: CrossAxisAlignment.center, // Center-align the items
    children: [
      SizedBox(
        // Wrap the button in a SizedBox for consistent height
        height: 50, // Reduced height for the button
        child: ElevatedButton(
          onPressed: onPressed,
          child: Image(
            image: AssetImage(imagePath),
            height: 30, // Reduced height of the image
            width: 30, // Reduced width of the image
          ),
          style: ElevatedButton.styleFrom(
            elevation: 10,
            shape: CircleBorder(),
            backgroundColor: Color(0xffe8f1ff),
            padding: EdgeInsets.all(8), // Reduced padding
          ),
        ),
      ),
      SizedBox(height: 5), // Space between the button and text
      Text(
        labelText,
        style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontFamily: 'Alatsi'), // Adjust font size if necessary
        textAlign: TextAlign.center, // Center the text
      ),
      SizedBox(
        height: 1,
      ),
    ],
  );
}

Container MainContainer1({required Widget child}) {
  // You need to return the Container widget
  return Container(
    padding: const EdgeInsets.only(top: 10, bottom: 50, left: 20, right: 20),
    margin: const EdgeInsets.only(right: 10, left: 10),
    constraints: BoxConstraints(minWidth: 400, minHeight: 665),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child, // Include the child parameter
  );
}

Container FollowRequestMainContainer({required Widget child}) {
  // You need to return the Container widget
  return Container(
    padding: const EdgeInsets.only(top: 10, bottom: 50, left: 0, right: 0),
    margin: const EdgeInsets.only(right: 10, left: 10),
    constraints: BoxConstraints(minWidth: 400, minHeight: 665),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child, // Include the child parameter
  );
}
