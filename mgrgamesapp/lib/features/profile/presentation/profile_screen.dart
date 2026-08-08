import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/presentation/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.user?.displayName ?? 'Khách',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          state.user?.email ?? '',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const ListTile(leading: Icon(Icons.settings), title: Text('Cài đặt')),
              const ListTile(leading: Icon(Icons.devices), title: Text('Thiết bị')),
              const ListTile(leading: Icon(Icons.receipt_long), title: Text('Đơn hàng')),
              const ListTile(leading: Icon(Icons.help_outline), title: Text('Hỗ trợ')),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.read<AuthCubit>().logout(),
                child: const Text('Đăng xuất'),
              ),
            ],
          );
        },
      ),
    );
  }
}