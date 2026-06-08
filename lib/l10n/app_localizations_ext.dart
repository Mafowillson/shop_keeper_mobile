import 'app_localizations.dart';

extension AppLocalizationsExt on AppLocalizations {
  String translateCategory(String category) {
    switch (category) {
      case 'Beverages':
        return categoryBeverages;
      case 'Snacks & Sweets':
        return categorySnacksSweets;
      case 'Grains & Staples':
        return categoryGrainsStaples;
      case 'Dairy & Eggs':
        return categoryDairyEggs;
      case 'Cleaning & Hygiene':
        return categoryCleaningHygiene;
      case 'Household':
        return categoryHousehold;
      case 'Toiletries':
        return categoryToiletries;
      case 'Other':
        return categoryOther;
      default:
        return category;
    }
  }
}
