class CommonStore {
  final bool loading;

  CommonStore({
    this.loading = false,
  });

  CommonStore copyWith({
    final bool? loading,
  }) {
    return CommonStore(loading: loading ?? this.loading);
  }
}
