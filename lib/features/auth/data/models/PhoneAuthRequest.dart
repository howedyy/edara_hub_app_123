class PhoneAuthRequest {
  final String phoneNumber;

  PhoneAuthRequest({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'phone': phoneNumber,
    };
  }

  factory PhoneAuthRequest.fromJson(Map<String, dynamic> json) {
    return PhoneAuthRequest(
      phoneNumber: json['phone'] as String,
    );
  }

  /// Validates phone number format
  /// Expected format: +[country_code][number] e.g., +201234567890
  bool isValid() {
    // Basic validation: starts with + and has 10-15 digits
    final phoneRegex = RegExp(r'^\+[1-9]\d{9,14}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  /// Formats Egyptian phone number to international format
  /// Converts 01012345678 to +201012345678
  static String formatEgyptianPhone(String phone) {
    // Remove any spaces or special characters
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If it starts with 0, replace with +20
    if (phone.startsWith('0')) {
      return '+20${phone.substring(1)}';
    }
    
    // If it starts with 20, add +
    if (phone.startsWith('20')) {
      return '+$phone';
    }
    
    // If it already starts with +, return as is
    if (phone.startsWith('+')) {
      return phone;
    }
    
    // Default: add +20
    return '+20$phone';
  }
}
