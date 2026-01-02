import 'package:flutter/material.dart';
import 'package:snappos_flutter/core/api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  String role = "cashier";

  bool loading = false;
  String? err;
  String? ok;

  Future<void> register() async {
    setState(() {
      loading = true;
      err = null;
      ok = null;
    });

    try {
      await Api.post(
        "/api/auth/register",
        body: {
          "name": nameC.text.trim(),
          "email": emailC.text.trim(),
          "password": passC.text,
          "role": role,
        },
      );
      setState(() => ok = "Register berhasil, silakan login.");
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (err != null)
              Text(err!, style: const TextStyle(color: Colors.red)),
            if (ok != null)
              Text(ok!, style: const TextStyle(color: Colors.green)),
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passC,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Role: "),
                DropdownButton<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(value: "cashier", child: Text("cashier")),
                    DropdownMenuItem(value: "admin", child: Text("admin")),
                  ],
                  onChanged: (v) => setState(() => role = v ?? "cashier"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : register,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Daftar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
