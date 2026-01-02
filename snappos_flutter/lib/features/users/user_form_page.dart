import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/storage.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  String role = "cashier";

  bool loading = false;
  String? err;

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final token = await Storage.getToken();
      await Api.post("/api/users", {
        "name": nameC.text.trim(),
        "email": emailC.text.trim(),
        "password": passC.text,
        "role": role,
      }, token: token);

      if (!mounted) return;
      Navigator.pop(context, true); // Success
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah User")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               if (err != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    err!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passC,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(labelText: "Role"),
                items: const [
                  DropdownMenuItem(value: "cashier", child: Text("Kasir")),
                  DropdownMenuItem(value: "admin", child: Text("Admin")),
                ],
                onChanged: (v) => setState(() => role = v ?? "cashier"),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: loading ? null : save,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text("SIMPAN USER"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
