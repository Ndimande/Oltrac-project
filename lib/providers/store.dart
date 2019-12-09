import 'package:oltrace/stores/app_store.dart';

class StoreProvider {
  static final StoreProvider _appStoreProvider = StoreProvider._();

  final AppStore _appStore = AppStore();

  StoreProvider._();

  factory StoreProvider() {
    return _appStoreProvider;
  }

  AppStore get appStore {
    if (_appStore == null) {
      throw Exception('Store provider not initialised');
    }

    return _appStore;
  }
}
