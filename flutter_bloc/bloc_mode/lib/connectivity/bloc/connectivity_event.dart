part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();
}

class ConnectionRequestedEvent extends ConnectivityEvent {
  const ConnectionRequestedEvent();
  @override
  List<Object> get props => [];
}

class ConnectivityChangedEvent extends ConnectivityEvent {
  final bool isConnected;

  const ConnectivityChangedEvent(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

class ConnectivityClosedEvent extends ConnectivityEvent {
  const ConnectivityClosedEvent();
  @override
  List<Object> get props => [];
}
