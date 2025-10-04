class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  static String? eventTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Event title is required';
    }

    if (value.length < 5) {
      return 'Title must be at least 5 characters';
    }

    return null;
  }

  static String? eventDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    if (value.length < 20) {
      return 'Description must be at least 20 characters';
    }

    return null;
  }

  static String? location(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }

    return null;
  }

  static String? capacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Capacity is required';
    }

    final capacity = int.tryParse(value);
    if (capacity == null || capacity < 1) {
      return 'Please enter a valid capacity';
    }

    if (capacity > 10000) {
      return 'Capacity cannot exceed 10,000';
    }

    return null;
  }

  static String? dateTime(DateTime? value) {
    if (value == null) {
      return 'Date and time are required';
    }

    if (value.isBefore(DateTime.now())) {
      return 'Please select a future date and time';
    }

    return null;
  }

  static String? endDateTime(DateTime? startTime, DateTime? endTime) {
    if (endTime == null) {
      return 'End date and time are required';
    }

    if (startTime != null && endTime.isBefore(startTime)) {
      return 'End time must be after start time';
    }

    return null;
  }
}
