class UiState<T> {
  final bool isLoading;
  final T? data;
  final String? errorMessage;

  const UiState({
    this.isLoading = false,
    this.data,
    this.errorMessage,
  });

  UiState<T> copyWith({
    bool? isLoading,
    T? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UiState<T>(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
