/// Thrown when the remote weather request fails (HTTP error, timeout, no key).
class NetworkException implements Exception {
  const NetworkException([
    this.message = 'Could not reach the weather service',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when the Hive cache cannot be read or is malformed.
class CacheException implements Exception {
  const CacheException([this.message = 'Could not read the local cache']);

  final String message;

  @override
  String toString() => message;
}
