import 'package:flutter/material.dart';

class NameStep extends StatelessWidget {
  final VoidCallback onNext;

  const NameStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이름을 입력해주세요.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          const TextField(
            decoration: InputDecoration(
              hintText: '이름',
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }
}
