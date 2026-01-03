import 'package:flutter/material.dart';
import 'package:snappos_flutter/core/api.dart';
import 'package:snappos_flutter/core/storage.dart';
import 'receipt_page.dart';
import '../auth/login_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool loading = true;
  String? err;
  List<Map<String, dynamic>> rows = [];

  Future<void> load() async {
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final token = await Storage.getToken();
      final res = await Api.get("/api/transactions", token: token);
      rows = (res["data"] as List).cast<Map<String, dynamic>>();
      setState(() {});
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> logout() async {
    await Storage.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err != null
          ? (err!.toLowerCase().contains("unauthorized") || err!.toLowerCase().contains("unauthenticated"))
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_clock_outlined, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text("Sesi Habis", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: logout,
                         style: ElevatedButton.styleFrom(
                          maximumSize: const Size(200, 50),
                        ),
                        child: const Text("LOGIN ULANG"),
                      ),
                    ],
                  ),
                )
              : Center(child: Text(err!))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              itemBuilder: (c, i) {
                final t = rows[i];
                final id = int.parse(t["id"].toString());
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiptPage(transactionId: id),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Transaksi #$id",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${t["created_at"]}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Kasir: ${t["cashier_name"]}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Rp ${t["total"]}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
