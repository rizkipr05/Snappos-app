import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/storage.dart';
import 'user_form_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> users = [];
  bool loading = false;
  String? err;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final token = await Storage.getToken();
      final res = await Api.get("/api/users", token: token);
      setState(() => users = res["data"]);
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus User?"),
        content: const Text("User akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => loading = true);
    try {
      final token = await Storage.getToken();
      await Api.delete("/api/users/$id", token: token);
      await load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User berhasil dihapus")));
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Kasir")),
      body: loading && users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : err != null
          ? Center(child: Text(err!))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (c, i) {
                final u = users[i];
                final id = int.parse(u["id"].toString());
                final role = u["role"].toString();
                final name = u["name"].toString();
                final email = u["email"].toString();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: role == "admin" ? Colors.deepPurple : Colors.blue,
                      child: Icon(
                        role == "admin" ? Icons.admin_panel_settings : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(name),
                    subtitle: Text("$email • ${role.toUpperCase()}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteUser(id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormPage()),
          );
          if (refresh == true) load();
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
