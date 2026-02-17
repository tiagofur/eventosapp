extension StringExtension on String {
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^\+?[0-9]{10,14}$').hasMatch(this);
  }

  bool get isNumeric => RegExp(r'^\d+\.?\d*$').hasMatch(this);

  String get initials {
    if (isEmpty) return '';
    return split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .take(2)
        .join();
  }

  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String get titleCase {
    return split(' ')
        .map((word) => word.capitalized)
        .join(' ');
  }
}
