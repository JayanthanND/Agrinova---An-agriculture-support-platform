// user.dart (combined class definitions)

abstract class User {
  final String id; // User ID
  final String profileImageUrl; // Profile image URL
  final String username; // User's name
  final String role; // User's role
  final String description; // User's description
  final String phoneNumber; // User's phone number
  final String location; // User's location
  final String email; // User's email

  User({
    required this.id,
    required this.profileImageUrl,
    required this.username,
    required this.role,
    required this.description,
    required this.phoneNumber,
    required this.location,
    required this.email, // Add email field
  });

  // Abstract factory method to be implemented in subclasses
  factory User.fromMap(Map<String, dynamic> data) {
    throw UnimplementedError(); // Abstract method to be implemented in subclasses
  }

  // Abstract method to convert User to Map
  Map<String, dynamic> toMap();
}

// Donor class
class Donor extends User {
  Donor({
    required String id,
    required String profileImageUrl,
    required String username,
    required String role,
    required String description,
    required String phoneNumber,
    required String location,
    required String email, // Add email to constructor
  }) : super(
          id: id,
          profileImageUrl: profileImageUrl,
          username: username,
          role: role,
          description: description,
          phoneNumber: phoneNumber,
          location: location,
          email: email, // Initialize email
        );

  factory Donor.fromMap(Map<String, dynamic> data) {
    return Donor(
      id: data['id'],
      profileImageUrl: data['profileImageUrl'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      description: data['description'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      location: data['location'] ?? '',
      email: data['email'] ?? '', // Fetch email from data
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileImageUrl': profileImageUrl,
      'username': username,
      'role': role,
      'description': description,
      'phoneNumber': phoneNumber,
      'location': location,
      'email': email, // Add email to map
    };
  }
}

// Investor class
class Investor extends User {
  Investor({
    required String id,
    required String profileImageUrl,
    required String username,
    required String role,
    required String description,
    required String phoneNumber,
    required String location,
    required String email, // Add email to constructor
  }) : super(
          id: id,
          profileImageUrl: profileImageUrl,
          username: username,
          role: role,
          description: description,
          phoneNumber: phoneNumber,
          location: location,
          email: email, // Initialize email
        );

  factory Investor.fromMap(Map<String, dynamic> data) {
    return Investor(
      id: data['id'],
      profileImageUrl: data['profileImageUrl'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      description: data['description'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      location: data['location'] ?? '',
      email: data['email'] ?? '', // Fetch email from data
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileImageUrl': profileImageUrl,
      'username': username,
      'role': role,
      'description': description,
      'phoneNumber': phoneNumber,
      'location': location,
      'email': email, // Add email to map
    };
  }
}

// Farmer class
// Farmer class
class Farmer extends User {
  final String landMapImageUrl; // Handle land map URL
  final String liveStock; // Live stock details
  final String waterFacility; // Water facility details
  final String request; // Donation or Investment request
  final String requirement;
  final List<Map<String, dynamic>> crops; // List of crops

  Farmer({
    required String id,
    required String profileImageUrl,
    required String username,
    required String role,
    required String description,
    required String phoneNumber,
    required String location,
    required this.landMapImageUrl,
    required this.liveStock,
    required this.waterFacility,
    required this.request,
    required this.requirement,
    required this.crops, // Add crops to constructor
    required String email, // Add email to constructor
  }) : super(
          id: id,
          profileImageUrl: profileImageUrl,
          username: username,
          role: role,
          description: description,
          phoneNumber: phoneNumber,
          location: location,
          email: email, // Initialize email
        );

  factory Farmer.fromMap(Map<String, dynamic> data) {
    return Farmer(
      id: data['id'],
      profileImageUrl: data['profileImageUrl'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      description: data['description'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      location: data['location'] ?? '',
      landMapImageUrl: data['landMapImageUrl'] ?? '',
      liveStock: data['liveStock'] ?? '',
      waterFacility: data['waterFacility'] ?? '',
      request: data['request'] ?? '',
      requirement: data['requirement'] ?? '',
      crops: List<Map<String, dynamic>>.from(
          data['crops'] ?? []), // Fetch crops from data
      email: data['email'] ?? '', // Fetch email from data
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileImageUrl': profileImageUrl,
      'username': username,
      'role': role,
      'description': description,
      'phoneNumber': phoneNumber,
      'location': location,
      'landMapImageUrl': landMapImageUrl, // Add new fields here
      'liveStock': liveStock,
      'waterFacility': waterFacility,
      'request': request,
      'requirement': requirement,
      'crops': crops, // Add crops to map
      'email': email, // Add email to map
    };
  }
}

// Retailer class
class Retailer extends User {
  final String companyName;
  final String cropReqd;

  Retailer({
    required String id,
    required String profileImageUrl,
    required String username,
    required String role,
    required String description,
    required String phoneNumber,
    required String location,
    required String email,
    required this.companyName,
    required this.cropReqd,
  }) : super(
          id: id,
          profileImageUrl: profileImageUrl,
          username: username,
          role: role,
          description: description,
          phoneNumber: phoneNumber,
          location: location,
          email: email,
        );

  factory Retailer.fromMap(Map<String, dynamic> data) {
    return Retailer(
      id: data['id'],
      profileImageUrl: data['profileImageUrl'] ?? '',
      username: data['username'] ?? '',
      role: 'Retailer',
      description: data['description'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      location: data['location'] ?? '',
      email: data['email'] ?? '',
      companyName: data['companyName'] ?? '',
      cropReqd: data['cropReqd'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileImageUrl': profileImageUrl,
      'username': username,
      'role': role,
      'description': description,
      'phoneNumber': phoneNumber,
      'location': location,
      'email': email,
      'companyName': companyName,
      'cropReqd': cropReqd,
    };
  }
}
