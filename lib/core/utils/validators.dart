class Validators {
  // Validation email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    
    return null;
  }

  // Validation mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    return null;
  }

  // Validation confirmation mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }

  // Validation nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }
    
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    
    return null;
  }

  // Validation téléphone (format tunisien)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    final phoneRegex = RegExp(r'^[0-9]{8}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Numéro de téléphone invalide (8 chiffres)';
    }
    
    return null;
  }

  // Validation prix
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le prix est requis';
    }
    
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Prix invalide';
    }
    
    return null;
  }

  // Validation kilométrage
  static String? validateMileage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le kilométrage est requis';
    }
    
    final mileage = int.tryParse(value);
    if (mileage == null || mileage < 0) {
      return 'Kilométrage invalide';
    }
    
    return null;
  }

  // Validation année
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'année est requise';
    }
    
    final year = int.tryParse(value);
    final currentYear = DateTime.now().year;
    
    if (year == null || year < 1950 || year > currentYear + 1) {
      return 'Année invalide';
    }
    
    return null;
  }

  // Validation description
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'La description est requise';
    }
    
    if (value.length < 20) {
      return 'La description doit contenir au moins 20 caractères';
    }
    
    return null;
  }

  // Validation champ requis
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }
}