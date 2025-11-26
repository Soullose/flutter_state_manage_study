part of 'connectivity_bloc.dart';

sealed class ConnectivityState extends Equatable {
  const ConnectivityState();
}

final class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();
  @override
  List<Object> get props => [];
}

/// State when connectivity check is in progress
final class ConnectivityInProgress extends ConnectivityState {
  const ConnectivityInProgress();
  @override
  List<Object> get props => [];


}

/// State when connectivity check is successful
class ConnectivitySuccess extends ConnectivityState {
  final bool isConnected;

  const ConnectivitySuccess(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

/// State when there is no connectivity
class ConnectivityFailure extends ConnectivityState {

  const ConnectivityFailure();
  @override
  List<Object> get props => [];
}
