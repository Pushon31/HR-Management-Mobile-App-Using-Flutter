class ErrorResponse {
  final int status;
  final String error;
  final String message;
  final String path;

  ErrorResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.path,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
    status: json['status'] ?? 500,
    error: json['error'] ?? 'Error',
    message: json['message'] ?? 'Something went wrong',
    path: json['path'] ?? '',
  );
}
