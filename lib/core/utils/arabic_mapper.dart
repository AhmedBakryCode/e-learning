class ArabicMapper {
  const ArabicMapper._();

  static String category(String value) {
    switch (value) {
      case 'All':
        return 'All';
      case 'Development':
      case 'development':
        return 'Development';
      case 'Design':
      case 'design':
        return 'Design';
      case 'Analytics':
      case 'analytics':
        return 'Analytics';
      case 'AI':
      case 'ai':
        return 'Artificial intelligence';
      case 'Teaching':
      case 'teaching':
        return 'Teaching';
      default:
        return value;
    }
  }

  static String level(String value) {
    switch (value) {
      case 'Beginner':
      case 'beginner':
        return 'Beginner';
      case 'Intermediate':
      case 'intermediate':
        return 'Intermediate';
      case 'Advanced':
      case 'advanced':
        return 'Advanced';
      default:
        return value;
    }
  }

  static String publishedState(bool isPublished) {
    return isPublished ? 'Published' : 'Draft';
  }
}
