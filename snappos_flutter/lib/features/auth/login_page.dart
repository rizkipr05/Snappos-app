import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/storage.dart';
import '../products/product_list_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool loading = false;
  String? err;

  Future<void> login() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final res = await Api.post(
        "/api/auth/login",
        body: {"email": emailC.text.trim(), "password": passC.text},
      );

      final token = res["token"] as String;
      await Storage.saveToken(token);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProductListPage()),
      );
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Snappos")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (err != null)
              Text(err!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passC,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
