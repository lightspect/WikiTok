enum Language {
  english(
      id: "en",
      name: "English",
      flag: "https://hatscripts.github.io/circle-flags/flags/us.svg"),
  spanish(
      id: "es",
      name: "Spanish",
      flag: "https://hatscripts.github.io/circle-flags/flags/es.svg"),
  french(
      id: "fr",
      name: "French",
      flag: "https://hatscripts.github.io/circle-flags/flags/fr.svg");

  final String id;
  final String name;
  final String flag;

  const Language({required this.id, required this.name, required this.flag});

  static Language? fromId(String id) {
    return Language.values
        .firstWhere((lang) => lang.id == id, orElse: () => Language.english);
  }
}
