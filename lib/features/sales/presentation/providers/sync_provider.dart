import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/enums/sync_state.dart';

class SyncProvider extends ChangeNotifier {
  SyncState _state = SyncState.synced;

  SyncState get state => _state;

  void setSyncing() {
    _state = SyncState.pending;
    notifyListeners();
  }

  void setSynced() {
    _state = SyncState.synced;
    notifyListeners();
  }

  void setError() {
    _state = SyncState.error;
    notifyListeners();
  }
}
