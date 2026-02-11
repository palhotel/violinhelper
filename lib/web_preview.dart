import 'package:flutter/material.dart';

class WebPreviewPage extends StatelessWidget {
  final List<Map<String, String>> openStrings = const [
    {'name': 'G String', 'pitch': 'G3', 'freq': '196.00 Hz'},
    {'name': 'D String', 'pitch': 'D4', 'freq': '293.66 Hz'},
    {'name': 'A String', 'pitch': 'A4', 'freq': '440.00 Hz'},
    {'name': 'E String', 'pitch': 'E5', 'freq': '659.25 Hz'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Violin Pitch Helper (Web Preview)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前为 Web 输出模式',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '由于浏览器环境无法直接调用移动端音频插件，Web 版提供可预览的基础指法与音高参考，便于在 GitHub Pages 上直接展示。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '常用空弦参考：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: openStrings.length,
                itemBuilder: (context, index) {
                  final item = openStrings[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['name'] ?? ''),
                      subtitle: Text(item['freq'] ?? ''),
                      trailing: Text(
                        item['pitch'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
