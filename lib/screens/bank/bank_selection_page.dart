import 'package:flutter/material.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/bank/card_login_page.dart';

class BankSelectionPage extends StatefulWidget {
  final String name;
  const BankSelectionPage({super.key, required this.name});

  @override
  State<BankSelectionPage> createState() => _BankSelectionPageState();
}

class _BankSelectionPageState extends State<BankSelectionPage> {
  final List<_BankItem> banks = [
    _BankItem(name: '신한카드', orgCode: '0306', color: Colors.blue),
    _BankItem(name: 'BC카드', orgCode: '0305', color: Colors.red),
    _BankItem(name: '국민카드', orgCode: '0301', color: Colors.brown),
    _BankItem(name: '현대카드', orgCode: '0302', color: Colors.black),
    _BankItem(name: '하나카드', orgCode: '0313', color: Colors.teal),
    _BankItem(name: '롯데카드', orgCode: '0311', color: Colors.redAccent),
  ];

  int? _selectedIndex;

  void _onSelect(int idx) {
    setState(() => _selectedIndex = idx);
  }

  void _onConnect() {
    if (_selectedIndex == null) return;
    final selected = banks[_selectedIndex!];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardLoginPage(
          name: widget.name,
          bankName: selected.name,
          organization: selected.orgCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: FlutterLogo(size: 72)),
              const SizedBox(height: 24),
              const Text('은행을 선택해주세요.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  itemCount: banks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final b = banks[index];
                    final selected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _onSelect(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: selected ? Colors.blue.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? Colors.blue : Colors.transparent, width: 1.5),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: b.color,
                              child: Text(b.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            const SizedBox(height: 6),
                            Text(b.name, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndex != null ? _onConnect : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('카드사 연결하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankItem {
  final String name;
  final String orgCode;
  final Color color;
  _BankItem({required this.name, required this.orgCode, required this.color});
}
