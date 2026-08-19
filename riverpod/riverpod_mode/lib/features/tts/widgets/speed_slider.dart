import 'package:material_ui/material_ui.dart';

/// 语速滑块组件
class SpeedSlider extends StatelessWidget {
  final double speed;
  final Function(double) onSpeedChanged;

  const SpeedSlider({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('语速', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${speed.toStringAsFixed(1)}x',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: speed,
          min: 0.5,
          max: 3.0,
          divisions: 25,
          label: speed.toStringAsFixed(1),
          onChanged: onSpeedChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0.5x', style: Theme.of(context).textTheme.bodySmall),
            Text('1.0x', style: Theme.of(context).textTheme.bodySmall),
            Text('2.0x', style: Theme.of(context).textTheme.bodySmall),
            Text('3.0x', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
