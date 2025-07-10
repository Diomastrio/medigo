import '../data/models/reminder.dart';
import '../data/models/medicine.dart';

class SearchService {
  static List<Reminder> filterReminders(
    List<Reminder> reminders,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) {
      return reminders;
    }

    final lowerSearchTerm = searchTerm.toLowerCase().trim();

    return reminders
        .where(
          (reminder) =>
              reminder.medicineName.toLowerCase().contains(lowerSearchTerm),
        )
        .toList()
      ..sort(
        (a, b) => _compareByRelevance(
          a.medicineName.toLowerCase(),
          b.medicineName.toLowerCase(),
          lowerSearchTerm,
        ),
      );
  }

  static List<Medicine> filterMedicines(
    List<Medicine> medicines,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) {
      return medicines;
    }

    final lowerSearchTerm = searchTerm.toLowerCase().trim();

    return medicines
        .where(
          (medicine) => medicine.name.toLowerCase().contains(lowerSearchTerm),
        )
        .toList()
      ..sort(
        (a, b) => _compareByRelevance(
          a.name.toLowerCase(),
          b.name.toLowerCase(),
          lowerSearchTerm,
        ),
      );
  }

  static int _compareByRelevance(
    String nameA,
    String nameB,
    String searchTerm,
  ) {
    // Exact matches first
    if (nameA == searchTerm && nameB != searchTerm) return -1;
    if (nameB == searchTerm && nameA != searchTerm) return 1;

    // Starts with search term second
    if (nameA.startsWith(searchTerm) && !nameB.startsWith(searchTerm))
      return -1;
    if (nameB.startsWith(searchTerm) && !nameA.startsWith(searchTerm)) return 1;

    // Then alphabetical order
    return nameA.compareTo(nameB);
  }

  static bool hasResults(List<dynamic> filteredItems, String searchTerm) {
    return filteredItems.isNotEmpty || searchTerm.isEmpty;
  }

  static String getEmptyMessage(
    List<dynamic> originalItems,
    String searchTerm,
    String itemType,
  ) {
    if (searchTerm.isNotEmpty) {
      return 'No se encontraron $itemType';
    }
    return 'No hay $itemType.';
  }
}
