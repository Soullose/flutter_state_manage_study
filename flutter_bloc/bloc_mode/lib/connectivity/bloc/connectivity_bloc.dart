import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

part 'connectivity_event.dart';

part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityBloc() : super(const ConnectivityInitial()) {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((connectivityResult) {
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        add(const ConnectionRequestedEvent());
      } else if (connectivityResult.contains(ConnectivityResult.none)) {
        add(const ConnectivityChangedEvent(false));
      }
    });
    on<ConnectionRequestedEvent>(_onConnectionRequested);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);
    on<ConnectivityClosedEvent>(_onConnectivityClosed);
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<void> _onConnectionRequested (
    ConnectionRequestedEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(const ConnectivityInProgress());
    // final connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult.contains(ConnectivityResult.mobile)) {
    //   emit(const ConnectivitySuccess(true));
    // } else if (connectivityResult.contains(ConnectivityResult.none)) {
    //   emit(const ConnectivityFailure());
    // }
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChangedEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    if (event.isConnected) {
      emit(ConnectivitySuccess(event.isConnected));
    } else {
      emit(const ConnectivityFailure());
    }
  }

  Future<void> _onConnectivityClosed(
    ConnectivityClosedEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(const ConnectivityInitial());
    _connectivitySubscription?.cancel();
  }
}
