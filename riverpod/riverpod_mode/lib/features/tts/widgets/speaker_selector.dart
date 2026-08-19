import 'package:material_ui/material_ui.dart';

/// 说话人选择器组件
class SpeakerSelector extends StatelessWidget {
  final int speakerId;
  final int numSpeakers;
  final Function(int) onSpeakerChanged;

  const SpeakerSelector({
    super.key,
    required this.speakerId,
    required this.numSpeakers,
    required this.onSpeakerChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (numSpeakers <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '声音 ($numSpeakers个说话人)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: speakerId.clamp(0, numSpeakers - 1),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: List.generate(numSpeakers, (index) {
            return DropdownMenuItem(
              value: index,
              child: Text('说话人 ${index + 1}'),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              onSpeakerChanged(value);
            }
          },
        ),
      ],
    );
  }
}
