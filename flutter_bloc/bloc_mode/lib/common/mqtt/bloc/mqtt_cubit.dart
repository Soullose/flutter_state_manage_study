import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'mqtt_state.dart';

class MqttCubit extends Cubit<MqttState> {
  MqttCubit() : super(MqttInitial());
}
