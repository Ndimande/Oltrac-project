// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppStore on _AppStore, Store {
  Computed<bool> _$tripHasStartedComputed;

  @override
  bool get tripHasStarted =>
      (_$tripHasStartedComputed ??= Computed<bool>(() => super.tripHasStarted))
          .value;
  Computed<bool> _$haulHasStartedComputed;

  @override
  bool get haulHasStarted =>
      (_$haulHasStartedComputed ??= Computed<bool>(() => super.haulHasStarted))
          .value;
  Computed<bool> _$vesselIsConfiguredComputed;

  @override
  bool get vesselIsConfigured => (_$vesselIsConfiguredComputed ??=
          Computed<bool>(() => super.vesselIsConfigured))
      .value;

  final _$currentMainViewIndexAtom =
      Atom(name: '_AppStore.currentMainViewIndex');

  @override
  MainViewIndex get currentMainViewIndex {
    _$currentMainViewIndexAtom.context
        .enforceReadPolicy(_$currentMainViewIndexAtom);
    _$currentMainViewIndexAtom.reportObserved();
    return super.currentMainViewIndex;
  }

  @override
  set currentMainViewIndex(MainViewIndex value) {
    _$currentMainViewIndexAtom.context.conditionallyRunInAction(() {
      super.currentMainViewIndex = value;
      _$currentMainViewIndexAtom.reportChanged();
    }, _$currentMainViewIndexAtom,
        name: '${_$currentMainViewIndexAtom.name}_set');
  }

  final _$_tripAtom = Atom(name: '_AppStore._trip');

  @override
  Trip get _trip {
    _$_tripAtom.context.enforceReadPolicy(_$_tripAtom);
    _$_tripAtom.reportObserved();
    return super._trip;
  }

  @override
  set _trip(Trip value) {
    _$_tripAtom.context.conditionallyRunInAction(() {
      super._trip = value;
      _$_tripAtom.reportChanged();
    }, _$_tripAtom, name: '${_$_tripAtom.name}_set');
  }

  final _$_completedTripsAtom = Atom(name: '_AppStore._completedTrips');

  @override
  List<Trip> get _completedTrips {
    _$_completedTripsAtom.context.enforceReadPolicy(_$_completedTripsAtom);
    _$_completedTripsAtom.reportObserved();
    return super._completedTrips;
  }

  @override
  set _completedTrips(List<Trip> value) {
    _$_completedTripsAtom.context.conditionallyRunInAction(() {
      super._completedTrips = value;
      _$_completedTripsAtom.reportChanged();
    }, _$_completedTripsAtom, name: '${_$_completedTripsAtom.name}_set');
  }

  final _$_haulAtom = Atom(name: '_AppStore._haul');

  @override
  Haul get _haul {
    _$_haulAtom.context.enforceReadPolicy(_$_haulAtom);
    _$_haulAtom.reportObserved();
    return super._haul;
  }

  @override
  set _haul(Haul value) {
    _$_haulAtom.context.conditionallyRunInAction(() {
      super._haul = value;
      _$_haulAtom.reportChanged();
    }, _$_haulAtom, name: '${_$_haulAtom.name}_set');
  }

  final _$_vesselAtom = Atom(name: '_AppStore._vessel');

  @override
  Vessel get _vessel {
    _$_vesselAtom.context.enforceReadPolicy(_$_vesselAtom);
    _$_vesselAtom.reportObserved();
    return super._vessel;
  }

  @override
  set _vessel(Vessel value) {
    _$_vesselAtom.context.conditionallyRunInAction(() {
      super._vessel = value;
      _$_vesselAtom.reportChanged();
    }, _$_vesselAtom, name: '${_$_vesselAtom.name}_set');
  }

  final _$_AppStoreActionController = ActionController(name: '_AppStore');

  @override
  void changeMainView(MainViewIndex index) {
    final _$actionInfo = _$_AppStoreActionController.startAction();
    try {
      return super.changeMainView(index);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void startTrip(Trip trip) {
    final _$actionInfo = _$_AppStoreActionController.startAction();
    try {
      return super.startTrip(trip);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void endTrip() {
    final _$actionInfo = _$_AppStoreActionController.startAction();
    try {
      return super.endTrip();
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void startHaul(Haul haul) {
    final _$actionInfo = _$_AppStoreActionController.startAction();
    try {
      return super.startHaul(haul);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVessel(Vessel vessel) {
    final _$actionInfo = _$_AppStoreActionController.startAction();
    try {
      return super.setVessel(vessel);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }
}
