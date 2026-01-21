import 'package:flutter/material.dart';
import 'package:my_app/screens/login/ssn_input_page.dart';

class NameInputPage extends StatefulWidget {
  const NameInputPage({super.key});

  @override
  State<NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final TextEditingController _nameController = TextEditingController();

  bool get _canProceed => _nameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (!_canProceed) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SsnInputPage(name: _nameController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                '이름을 입력해주세요.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              Text(
                '이름',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: '',
                  suffixIcon: _nameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _nameController.clear()),
                        )
                      : null,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _onConfirm(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed ? _onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}