class Sanitizer {
  static String sanitizeMetadata(String input) {
    if (input.isEmpty) return input;
    
    // Remove HTML tags
    final htmlRegExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    var sanitized = input.replaceAll(htmlRegExp, '');
    
    // Unescape common HTML entities
    sanitized = sanitized
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
        
    return sanitized.trim();
  }
}
