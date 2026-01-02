import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/storage.dart';

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
      appBar: AppBar(title: Text("Detail #${widget.id}")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err != null
          ? Center(child: Text(err!))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kasir: ${trx?["cashier_name"]}"),
                  Text("Total: Rp ${trx?["total"]}"),
                  Text("Bayar: Rp ${trx?["paid"]}"),
                  Text("Kembali: Rp ${trx?["change_money"]}"),
                  const Divider(),
                  const Text(
                    "Items:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (c, i) {
                        final it = items[i];
                        return ListTile(
                          title: Text(it["name"].toString()),
                          subtitle: Text(
                            "Rp ${it["price"]} x ${it["qty"]} = Rp ${it["subtotal"]}",
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
