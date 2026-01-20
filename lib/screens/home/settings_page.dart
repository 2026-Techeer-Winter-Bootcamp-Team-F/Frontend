import 'package:flutter/material.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/auth/login_page.dart';
import 'package:my_app/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 계정 섹션
            _buildSectionTitle('계정'),
            _buildSettingsTile(
              title: '프로필',
              subtitle: '개인정보 설정',
              icon: Icons.person_outlined,
              onTap: () {
                // TODO: 프로필 화면으로 이동
              },
            ),
            _buildSettingsTile(
              title: '비밀번호 변경',
              subtitle: '계정 보안',
              icon: Icons.lock_outlined,
              onTap: () {
                // TODO: 비밀번호 변경 화면으로 이동
              },
            ),
            const Divider(),

            // 알림 섹션
            _buildSectionTitle('알림'),
            _buildNotificationTile(
              title: '푸시 알림',
              icon: Icons.notifications_outlined,
            ),
            _buildNotificationTile(
              title: '이메일 알림',
              icon: Icons.email_outlined,
            ),
            const Divider(),

            // 앱 정보 섹션
            _buildSectionTitle('앱 정보'),
            _buildSettingsTile(
              title: '버전 정보',
              subtitle: 'v1.0.0',
              icon: Icons.info_outlined,
              onTap: () {},
            ),
            _buildSettingsTile(
              title: '약관 및 개인정보처리방침',
              icon: Icons.description_outlined,
              onTap: () {
                // TODO: 약관 화면으로 이동
              },
            ),
            const Divider(),

            // 로그아웃/탈퇴 섹션
            _buildSectionTitle('보안'),
            _buildLogoutTile(),
            _buildWithdrawTile(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Switch(
        value: true,
        onChanged: (value) {
          // TODO: 알림 설정 변경
        },
      ),
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.orange),
      title: const Text(
        '로그아웃',
        style: TextStyle(color: Colors.orange),
      ),
      onTap: () {
        _showLogoutDialog();
      },
    );
  }

  Widget _buildWithdrawTile() {
    return ListTile(
      leading: const Icon(Icons.delete_outline, color: Colors.red),
      title: const Text(
        '회원 탈퇴',
        style: TextStyle(color: Colors.red),
      ),
      onTap: () {
        // TODO: 회원 탈퇴 기능
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // 다이얼로그 닫기
                
                // 로그아웃 실행
                await authService.logout();
                
                if (!mounted) return;
                
                // 로그인 화면으로 이동
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃되었습니다')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }
}
