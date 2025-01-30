class LayoutConfig {
  static final LayoutConfig _instance = LayoutConfig._internal();

  factory LayoutConfig() {
    return _instance;
  }

  LayoutConfig._internal();

  double bottomPadding = 0;
  double topPadding = 0;
}
