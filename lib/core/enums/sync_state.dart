enum SyncState {
  /// All offline operations have been committed to the server.
  synced,

  /// A sync is in progress, or offline operations are queued and waiting.
  pending,

  /// One or more entries were rejected by the server (business-rule violation).
  /// The user should review the flagged transactions.
  conflict,

  /// The last sync attempt failed due to a network or server error.
  /// The engine will retry automatically on the next connectivity event.
  error,
}
