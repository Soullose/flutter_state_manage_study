import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/timer_bloc.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('定时器'),
      //   centerTitle: true,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: Stack(
        children: [
          const Background(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 18.0),
                child: IconButton(
                  color: Colors.black,
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ],
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100),
                child: Center(child: TimerText()),
              ),
              Actions(),
            ],
          ),
        ],
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({super.key});

  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr = ((duration / 60) % 60).floor().toString().padLeft(
      2,
      '0',
    );
    final secondsStr = (duration % 60).toString().padLeft(2, '0');
    return Text(
      '$minutesStr:$secondsStr',
      style: Theme.of(
        context,
      ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...switch (state) {
              TimerInitial() => [
                FloatingActionButton(
                  heroTag: 'timer_play_initial',
                  child: const Icon(Icons.play_arrow),
                  onPressed: () => context.read<TimerBloc>().add(
                    TimerStarted(duration: state.duration),
                  ),
                ),
              ],
              TimerRunInProgress() => [
                FloatingActionButton(
                  heroTag: 'timer_pause',
                  child: const Icon(Icons.pause),
                  onPressed: () {
                    context.read<TimerBloc>().add(const TimerPaused());
                  },
                ),
                FloatingActionButton(
                  heroTag: 'timer_reset_inprogress',
                  child: const Icon(Icons.replay),
                  onPressed: () {
                    context.read<TimerBloc>().add(const TimerReset());
                  },
                ),
              ],
              TimerRunPause() => [
                FloatingActionButton(
                  heroTag: 'timer_resume',
                  child: const Icon(Icons.play_arrow),
                  onPressed: () {
                    context.read<TimerBloc>().add(const TimerResumed());
                  },
                ),
                FloatingActionButton(
                  heroTag: 'timer_reset_pause',
                  child: const Icon(Icons.replay),
                  onPressed: () {
                    context.read<TimerBloc>().add(const TimerReset());
                  },
                ),
              ],
              TimerRunComplete() => [
                FloatingActionButton(
                  heroTag: 'timer_reset_complete',
                  child: const Icon(Icons.replay),
                  onPressed: () {
                    context.read<TimerBloc>().add(const TimerReset());
                  },
                ),
              ],
            },
          ],
        );
      },
    );
  }
}

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.blue.shade500],
          ),
        ),
      ),
    );
  }
}
