class UserUtils {
  static String getInitials(String name) {
    if (name.isEmpty) return "?";

    List<String> names = name.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();

    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }
}
