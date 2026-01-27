import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/models/transaction_models.dart';
import 'package:my_app/services/transaction_service.dart';
import 'transaction_detail_page.dart';

class CategoryTransactionPage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final int amount;
  final int change;
  final int percent;
  final Color color;
  final DateTime? month;

  const CategoryTransactionPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.amount,
    required this.change,
    required this.percent,
    required this.color,
    this.month,
  });

  @override
  State<CategoryTransactionPage> createState() =>
      _CategoryTransactionPageState();
}

class _CategoryTransactionPageState extends State<CategoryTransactionPage> {
  final TransactionService _service = TransactionService();

  String selectedSort = '최신순';
  final List<String> sortOptions = ['최신순', '고액순'];

  bool _isLoading = true;
  String? _error;
  CategoryDetail? _detail;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = widget.month ?? DateTime.now();
      final detail = await _service.getCategoryDetail(
        now.year,
        now.month,
        widget.categoryName,
      );
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Group transactions by date string (e.g. "23일 (금)")
  Map<String, List<CategoryTransaction>> get _groupedTransactions {
    if (_detail == null) return {};

    final transactions = List<CategoryTransaction>.from(_detail!.transactions);

    if (selectedSort == '고액순') {
      transactions.sort((a, b) => b.amount.compareTo(a.amount));
    } else {
      transactions.sort((a, b) => b.spentAt.compareTo(a.spentAt));
    }

    final Map<String, List<CategoryTransaction>> grouped = {};
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    for (final tx in transactions) {
      final day = tx.spentAt.day;
      final weekday = weekdays[tx.spentAt.weekday - 1];
      final key = '${day}일 ($weekday)';
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '카테고리별 지출',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCategoryHeader(),
          _buildSortOptions(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('데이터를 불러올 수 없습니다'))
                    : _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.categoryName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.percent}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrencyFull(widget.amount),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                children: [
                  const TextSpan(text: '지난달 같은 기간보다 '),
                  TextSpan(
                    text: _formatCurrencyFull(widget.change),
                    style: TextStyle(
                      color: widget.change < 0
                          ? AppColors.primary
                          : const Color(0xFFFF5252),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...sortOptions.map((option) {
            final isSelected = selectedSort == option;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedSort = option;
                  });
                },
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final grouped = _groupedTransactions;

    if (grouped.isEmpty) {
      return const Center(child: Text('거래 내역이 없습니다'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: grouped.entries.map((entry) {
        return _buildDateGroup(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildDateGroup(String date, List<CategoryTransaction> items) {
    final totalAmount = items.fold<int>(0, (sum, tx) => sum + tx.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_formatCurrencyFull(-totalAmount)} · ${items.length}건',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...items.map((tx) => _buildTransactionItem(tx)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTransactionItem(CategoryTransaction tx) {
    final timeStr = DateFormat('HH:mm').format(tx.spentAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailPage(
              merchantName: tx.merchantName,
              categoryIcon: widget.categoryIcon,
              amount: -tx.amount,
              paymentMethod: tx.cardName,
              color: widget.color,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  widget.categoryIcon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.merchantName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx.cardName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrencyFull(-tx.amount),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrencyFull(int amount) {
    final formatted = amount.abs().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '${amount < 0 ? '-' : ''}$formatted원';
  }
}
