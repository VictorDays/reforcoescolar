import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_controller.dart';
import 'admin_dashboard_screen.dart';

class AnunciarScreen extends StatelessWidget {
  const AnunciarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminController()),
      ],
      child: const AdminDashboardScreen(),
    );
  }
}