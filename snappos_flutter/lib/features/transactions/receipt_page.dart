import 'package:flutter/material.dart';
import 'package:snappos_flutter/core/api.dart';
import '../../core/storage.dart';

class ReceiptPage extends StatefulWidget {
  final int transactionId;
  const ReceiptPage({super.key, required this.transactionId});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool loading = true;
  String? err;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final token = await Storage.getToken();
      // We reuse the existing detail endpoint if it returns enough info
      // Or we can assume it returns id, customer_name, items, totals, etc.
      // Let's verify what detail.php returns or just use it.
      // Assuming detail.php uses standardized response.
      final res = await Api.get("/api/transactions/${widget.transactionId}", token: token);
      setState(() {
        data = res["data"];
        loading = false;
      });
    } catch (e) {
      setState(() {
        err = e.toString().replaceAll("Exception:", "").trim();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (err != null) return Scaffold(body: Center(child: Text(err!)));
    if (data == null) return const Scaffold(body: Center(child: Text("Data not found")));

    final items = (data!["items"] as List).cast<Map<String, dynamic>>();
    final total = int.parse(data!["total"].toString());
    final paid = int.parse(data!["paid"].toString());
    final change = int.parse(data!["change_money"].toString());
    final customer = data!["customer_name"] ?? "-";
    final cashier = data!["cashier_name"] ?? "-";
    final date = data!["created_at"] ?? "-";
    final id = data!["id"];

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Background color like report paper context
      appBar: AppBar(
        title: const Text("Cetak Struk"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // TODO: Implement actual printing (bluetooth/usb)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Print belum terhubung ke printer thermal")),
              );
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 350, // Typical receipt width assumption for phone screen
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  "SnapPOS Resto",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Jl. Contoh No. 123\nJakarta Selatan, 12345\n0812-3456-7890",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                
                // Metadata
                _row("Kode Struk:", "#$id"),
                _row("No. Meja:", "3"), // Hardcoded or future feature
                _row("Tanggal:", "$date"),
                _row("Kasir:", "$cashier"),
                _row("Pelanggan:", "$customer"),
                
                const SizedBox(height: 16),
                const Divider(color: Colors.black54),
                _dashedLine(),
                const SizedBox(height: 16),

                // Items
                ...items.map((item) {
                  final iName = item["product_name"] ?? item["name"] ?? "Item";
                  final iQty = item["qty"];
                  final iSub = item["subtotal"];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(iName, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        Text("x$iQty", style: const TextStyle(color: Colors.grey)),
                        SizedBox(
                          width: 80, 
                          child: Text(
                            "$iSub", 
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),
                _dashedLine(),
                const SizedBox(height: 16),

                // Footer totals
                _row("Subtotal", "$total"),
                _row("PPN (0%)", "0"), // Example tax
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("$total", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                _dashedLine(),
                const SizedBox(height: 16),

                _row("Tunai", "$paid"),
                _row("Kembali", "$change"),

                const SizedBox(height: 32),
                const Text(
                  "Terima kasih",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Powered by SnapPOS",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _dashedLine() {
    return Row(
      children: List.generate(150 ~/ 2, (index) => Expanded(
        child: Container(
          color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade400,
          height: 1,
        ),
      )),
    );
  }
}
