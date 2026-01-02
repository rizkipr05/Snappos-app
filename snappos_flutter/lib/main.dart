import 'package:flutter/material.dart';
import 'core/storage.dart';
import 'features/auth/login_page.dart';
import 'features/products/product_list_page.dart';

void main() {
  runApp(const SnapposApp());
}

class SnapposApp extends StatelessWidget {
  const SnapposApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Snappos",
      theme: ThemeData(useMaterial3: true),
      home: const Boot(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final token = await Storage.getToken();
    if (!mounted) return;
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProductListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
