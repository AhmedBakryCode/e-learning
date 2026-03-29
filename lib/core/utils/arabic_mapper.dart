class ArabicMapper {
  const ArabicMapper._();

  static String category(String value) {
    switch (value) {
      case 'All':
        return 'All';
      case 'Development':
        return 'Development';
      case 'Design':
        return 'Design';
      case 'Analytics':
        return 'Analytics';
      case 'AI':
        return 'Artificial intelligence';
      case 'Teaching':
        return 'Teaching';
      default:
        return value;
    }
  }

  static String level(String value) {
    switch (value) {
      case 'Beginner':
        return 'Beginner';
      case 'Intermediate':
        return 'Intermediate';
      case 'Advanced':
        return 'Advanced';
      default:
        return value;
    }
  }

  static String publishedState(bool isPublished) {
    return isPublished ? 'Published' : 'Draft';
  }
}
