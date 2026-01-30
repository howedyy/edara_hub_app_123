class VerifyOTPRequest {
  final String verificationId;
  final String otpCode;

  VerifyOTPRequest({
    required this.verificationId,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'verification_id': verificationId,
      'otp_code': otpCode,
    };
  }

  factory VerifyOTPRequest.fromJson(Map<String, dynamic> json) {
    return VerifyOTPRequest(
      verificationId: json['verification_id'] as String,
      otpCode: json['otp_code'] as String,
    );
  }

  /// Validates OTP code format (6 digits)
  bool isValid() {
    final otpRegex = RegExp(r'^\d{6}$');
    return otpRegex.hasMatch(otpCode);
  }
}
