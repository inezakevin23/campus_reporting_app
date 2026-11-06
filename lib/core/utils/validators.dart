// ALU email validator.
const Set<String> allowedAluEmailDomains = {
  'alueducation.com',
  'alustudent.com',
};

bool isValidAluEmail(String email) {
  final normalizedEmail = email.trim().toLowerCase();

  final emailParts = normalizedEmail.split('@');

  if (emailParts.length != 2) {
    return false;
  }

  final username = emailParts[0];
  final domain = emailParts[1];

  if (username.isEmpty) {
    return false;
  }

  return allowedAluEmailDomains.contains(domain);
}

String? validateAluEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email address is required.';
  }

  final email = value.trim();

  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }

  if (!isValidAluEmail(email)) {
    return 'Please use your ALU email address '
        '(@alueducation.com or @alustudent.com).';
  }

  return null;
}
