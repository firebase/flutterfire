// Validates an email string.
bool isValidEmail(String email) {
  return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
}
