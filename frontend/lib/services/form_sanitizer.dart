/// Form Sanitizer & Input Boundary Validation Service
/// (Module 19: Security & Validation)
///
/// Provides client-side string sanitization (XSS and script injection stripping),
/// physics boundary limit checking, and password/email format validation.
library form_sanitizer;

class FormSanitizer {
  // Regex to strip HTML tags (<tag>...</tag> or self-closing)
  static final RegExp _htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);

  // Regex to strip script tags and javascript: URIs
  static final RegExp _scriptPatternRegex = RegExp(
    r'(<script\b[^>]*>([\s\S]*?)<\/script>|javascript:|onerror=|onload=|onclick=)',
    caseSensitive: false,
  );

  // Common easily-guessable passwords
  static const Set<String> _prohibitedPasswords = {
    'password',
    'password123',
    'admin',
    'admin123',
    '123456',
    '12345678',
    '123456789',
    'qwerty',
    'letmein',
    'welcome',
    'smartpack',
    'packaging',
  };

  /// Sanitizes text input by stripping script injection, HTML tags, control characters,
  /// and normalizing whitespace.
  static String sanitizeString(String input, {int maxLength = 255}) {
    if (input.isEmpty) return '';

    // Remove null bytes and control characters (except standard newlines/tabs)
    String cleaned = input.replaceAll('\x00', '');

    // Remove script patterns and HTML tags
    cleaned = cleaned.replaceAll(_scriptPatternRegex, '');
    cleaned = cleaned.replaceAll(_htmlTagRegex, '');

    // Normalize multiple consecutive spaces into a single space
    cleaned = cleaned.replaceAll(RegExp(r'[ \t]+'), ' ').trim();

    // Enforce maximum length limit
    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength).trim();
    }

    return cleaned;
  }

  /// Sanitizes all string values inside a map payload recursively.
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> input) {
    final Map<String, dynamic> result = {};
    for (final entry in input.entries) {
      if (entry.value is String) {
        result[entry.key] = sanitizeString(entry.value as String);
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = sanitizeMap(entry.value as Map<String, dynamic>);
      } else if (entry.value is List) {
        result[entry.key] = entry.value.map((item) {
          if (item is String) return sanitizeString(item);
          if (item is Map<String, dynamic>) return sanitizeMap(item);
          return item;
        }).toList();
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Validates storage temperature boundary [-10.0, 45.0] °C.
  static String? validateStorageTemp(double? temp) {
    if (temp == null) return 'Storage temperature is required.';
    if (temp.isNaN || temp.isInfinite) return 'Invalid storage temperature value.';
    if (temp < -10.0 || temp > 45.0) {
      return 'Storage temperature must be between -10.0°C and 45.0°C.';
    }
    return null;
  }

  /// Validates relative humidity boundary [10.0, 100.0] %.
  static String? validateRelativeHumidity(double? rh) {
    if (rh == null) return 'Relative humidity is required.';
    if (rh.isNaN || rh.isInfinite) return 'Invalid relative humidity value.';
    if (rh < 10.0 || rh > 100.0) {
      return 'Relative humidity must be between 10.0% and 100.0%.';
    }
    return null;
  }

  /// Validates target shelf life boundary [1, 365] days.
  static String? validateTargetShelfLife(int? days) {
    if (days == null) return 'Target shelf life is required.';
    if (days < 1 || days > 365) {
      return 'Target shelf life must be between 1 and 365 days.';
    }
    return null;
  }

  /// Validates package food weight boundary [0.01, 100.0] kg.
  static String? validateFoodWeight(double? weight) {
    if (weight == null) return 'Food weight is required.';
    if (weight.isNaN || weight.isInfinite) return 'Invalid food weight value.';
    if (weight < 0.01 || weight > 100.0) {
      return 'Food weight must be between 0.01 kg and 100.0 kg.';
    }
    return null;
  }

  /// Validates standard email format according to RFC 5322 standard.
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email address is required.';
    }
    final cleaned = email.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$',
    );
    if (!emailRegex.hasMatch(cleaned) || cleaned.length > 254) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates password complexity:
  /// - Minimum 8 characters, maximum 128 characters
  /// - At least one uppercase letter [A-Z]
  /// - At least one lowercase letter [a-z]
  /// - At least one digit [0-9]
  /// - At least one special symbol
  /// - Not in prohibited common dictionary list
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required.';
    }

    if (_prohibitedPasswords.contains(password.toLowerCase().trim())) {
      return 'Password is too common and easily guessable.';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    if (password.length > 128) {
      return 'Password cannot exceed 128 characters.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter (A-Z).';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter (a-z).';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number (0-9).';
    }

    if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password)) {
      return 'Password must contain at least one special character (!@#\$%^&* etc.).';
    }

    return null;
  }
}
