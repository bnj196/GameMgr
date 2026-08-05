import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Tên hiển thị')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Email hoặc SĐT')),
            const SizedBox(height: 16),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Mật khẩu')),
            const SizedBox(height: 16),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Xác nhận mật khẩu')),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                // TODO: gọi AuthCubit.register
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đăng ký sẽ tích hợp API thật ở bước sau.')),
                );
              },
              child: const Text('Đăng ký'),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Đã có tài khoản? Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}