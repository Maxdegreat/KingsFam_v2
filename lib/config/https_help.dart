

  String? findHttps(String str) {
    int startIndex = str.indexOf("https://");
    if (startIndex != -1 && (startIndex == 0 || str[startIndex - 1] == ' ')) {
      int endIndex = str.indexOf(' ', startIndex + 1);
      if (endIndex == -1) {
        return str.substring(startIndex);
      } else {
        return str.substring(startIndex, endIndex);
      }
    }
    return null;
  }