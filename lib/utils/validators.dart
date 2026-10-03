// Dart port of utils/ValidationConstraints.js + formActions.js (validate.js rules).
// Each validator returns an error message, or null when the value is valid.

final RegExp _emailRegex = RegExp(
  r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,}$",
  caseSensitive: false,
);

/// validate.js style prettify: "fullName" -> "Full name".
String _pretty(String id) {
  final spaced = id.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  final lower = spaced.toLowerCase();
  return lower.isEmpty ? lower : lower[0].toUpperCase() + lower.substring(1);
}

String? validateString(String id, String value) {
  if (value.trim().isEmpty) return "${_pretty(id)} can't be blank";
  return null;
}

String? validateEmail(String id, String value) {
  if (value.trim().isEmpty) return "${_pretty(id)} can't be blank";
  if (!_emailRegex.hasMatch(value)) return '${_pretty(id)} is not a valid email';
  return null;
}

String? validatePassword(String id, String value) {
  if (value.trim().isEmpty) return "${_pretty(id)} can't be blank";
  if (value.length < 6) return '${_pretty(id)} must be at least 6 characters';
  return null;
}

String? validateInput(String inputId, String inputValue) {
  switch (inputId) {
    case 'fullName':
      return validateString(inputId, inputValue);
    case 'email':
      return validateEmail(inputId, inputValue);
    case 'password':
      return validatePassword(inputId, inputValue);
    default:
      return null;
  }
}
