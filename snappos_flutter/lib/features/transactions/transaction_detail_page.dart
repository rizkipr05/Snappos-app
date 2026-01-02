import 'package:flutter/material.dart';
import 'package:snappos_flutter/core/api.dart';
import 'package:snappos_flutter/core/storage.dart';

class TransactionDetailPage extends StatefulWidget {
  final int id;
  const TransactionDetailPage({super.key, required this.id});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool loading = true;
  String? err;
  Map<String, dynamic>? trx;
  List<Map<String, dynamic>> items = [];

  Future<void> load() async {
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final token = await Storage.getToken();
      final res = await Api.get("/api/transactions/${widget.id}", token: token);
      trx = res["transaction"] as Map<String, dynamic>;
      items = (res["items"] as List).cast<Map<String, dynamic>>();
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
      appBar: AppBar(title: const Text("Detail Transaksi")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err != null
          ? Center(child: Text(err!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      Text(
                        "Rp ${trx?["total"]}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Text(
                        "Transaksi #${widget.id}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      ...items.map((it) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Text(
                                "${it["qty"]}x",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(it["name"].toString()),
                              ),
                              Text(
                                "Rp ${it["subtotal"]}",
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total", style: TextStyle(color: Colors.grey[600])),
                          Text(
                            "Rp ${trx?["total"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tunai", style: TextStyle(color: Colors.grey[600])),
                          Text(
                            "Rp ${trx?["paid"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Kembali", style: TextStyle(color: Colors.grey[600])),
                          Text(
                            "Rp ${trx?["change_money"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Terima kasih telah berbelanja",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      Text(
                        "${trx?["created_at"]} • ${trx?["cashier_name"]}",
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
