import 'package:flutter/material.dart';
import 'package:my_app/screens/signup_steps/name_step.dart';

class SignupFlowPage extends StatefulWidget {
  const SignupFlowPage({super.key});

  @override
  State<SignupFlowPage> createState() => _SignupFlowPageState();
}

class _SignupFlowPageState extends State<SignupFlowPage> {
  int currentStep = 0;
  final nameController = TextEditingController();

  late final List<Widget> steps;

  @override
  void initState() {
    super.initState();
    steps = [
      NameStep(controller: nameController),
    ];
  }

  void nextStep() {
    // 지금은 비워둠 (다음 단계 나중에)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: steps[currentStep]),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: nameController.text.isNotEmpty ? nextStep : null,
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
