class AppMedia {
  static const String dashboardHero =
      'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=1200&q=80';
  static const String clinicHero =
      'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?auto=format&fit=crop&w=1200&q=80';
  static const String adoptionHero =
      'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=1200&q=80';
  static const String profileHero =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=1200&q=80';
  static const String ownerHero =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1200&q=80';
  static const String vetHero =
      'https://images.unsplash.com/photo-1576765607924-3f7f1a0a0c2b?auto=format&fit=crop&w=1200&q=80';

  static const String dogHeroOne =
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80';
  static const String dogHeroTwo =
      'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=900&q=80';
  static const String dogHeroThree =
      'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=900&q=80';
  static const String catHeroOne =
      'https://images.unsplash.com/photo-1511044568932-338cba0ad803?auto=format&fit=crop&w=900&q=80';
  static const String catHeroTwo =
      'https://images.unsplash.com/photo-1513245543132-31f507417b26?auto=format&fit=crop&w=900&q=80';

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
