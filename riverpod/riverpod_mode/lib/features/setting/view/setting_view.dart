import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_mode/features/setting/riverpod/setting.dart';

class SettingView extends ConsumerWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingState = ref.read(settingProvider.notifier);
    final setting = ref.watch(settingProvider);
    if (kDebugMode) {
      print('setting---:$setting');
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Setting example')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '地址',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: Row(
                children: [
                  const Text('服务地址'),
                  const Spacer(),
                  Consumer(
                    builder: (context, ref, child) {
                      final value = ref.watch(settingProvider);
                      return Text("${value.value?.ipAddress}");
                    },
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final ok = await showTextInputDialog(
                  context: context,
                  textFields: const [
                    DialogTextField(
                      hintText: '请输入IP地址',
                      prefixText: '',
                      // suffixText: 'Dollar',
                    ),
                  ],
                  title: 'IPAddress',
                  // message: 'This is a message',
                );
                if (ok != null) {
                  await settingState.setIpAddress(ok[0]);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
