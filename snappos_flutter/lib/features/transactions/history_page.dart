import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/storage.dart';
import 'transaction_detail_page.dart';

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
          ? Center(child: Text(err!))
          : ListView.builder(
              itemCount: rows.length,
              itemBuilder: (c, i) {
                final t = rows[i];
                final id = int.parse(t["id"].toString());
                return ListTile(
                  title: Text("Transaksi #$id • Rp ${t["total"]}"),
                  subtitle: Text("${t["cashier_name"]} • ${t["created_at"]}"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailPage(id: id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
