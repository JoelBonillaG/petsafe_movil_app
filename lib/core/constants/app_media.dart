class AppMedia {
  // Local asset images
  static const String dashboardHero = 'assets/images/home_page_image.png';
  static const String clinicHero = 'assets/images/clinical_date_page_image.png';
  static const String historyHero = 'assets/images/historial_pet_page_image.png';
  static const String adoptionHero = 'assets/images/adopt_pet_page_image.png';
  static const String petsHero = 'assets/images/pets_page_image.png';
  static const String profileHero = 'assets/images/recover_password.png';
  static const String ownerHero = 'assets/images/home_page_image.png';
  static const String vetHero = 'assets/images/clinical_date_page_image.png';

  // Pet adoption images
  static const String adoptPetOne = 'assets/images/adopt_pet1.png';
  static const String adoptPetTwo = 'assets/images/adopt_pet2.png';
  static const String adoptPetThree = 'assets/images/adopt_pet3.png';

  // My pets images
  static const String myPetOne = 'assets/images/my_pet1.png';
  static const String myPetTwo = 'assets/images/my_pet2.png';

  // Hero images for dashboard
  static const String dogHeroOne = 'assets/images/my_pet1.png';
  static const String dogHeroTwo = 'assets/images/adopt_pet1.png';
  static const String dogHeroThree = 'assets/images/adopt_pet2.png';
  static const String catHeroOne = 'assets/images/my_pet2.png';
  static const String catHeroTwo = 'assets/images/adopt_pet3.png';

  static String petImageFor({
    required String name,
    String? species,
  }) {
    final normalizedName = name.trim().toLowerCase();
    final normalizedSpecies = species?.trim().toLowerCase() ?? '';

    if (normalizedSpecies.contains('gato') || normalizedSpecies.contains('cat')) {
      if (normalizedName.contains('mia') || normalizedName.contains('nala')) {
        return catHeroOne;
      }
      return catHeroTwo;
    }

    if (normalizedName.contains('luna')) return dogHeroOne;
    if (normalizedName.contains('toby')) return dogHeroTwo;
    if (normalizedName.contains('rocky')) return dogHeroThree;
    if (normalizedName.contains('coco')) return dogHeroOne;

    return dogHeroOne;
  }

  static String adoptionImageFor(String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized.contains('nala') || normalized.contains('mia')) {
      return catHeroOne;
    }
    if (normalized.contains('lola')) {
      return catHeroTwo;
    }
    if (normalized.contains('toby')) {
      return dogHeroTwo;
    }
    if (normalized.contains('rocky')) {
      return dogHeroThree;
    }
    return dogHeroOne;
  }
}
