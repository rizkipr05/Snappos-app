import 'package:flutter/material.dart';
import 'package:snappos_flutter/core/api.dart';
import 'package:snappos_flutter/core/storage.dart';
import 'package:snappos_flutter/features/transactions/receipt_page.dart';
import 'cart_controller.dart';

class CartPage extends StatefulWidget {
  final CartController cart;
  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final paidC = TextEditingController();
  final customerC = TextEditingController(); // [NEW] Input Customer Name
  bool loading = false;
  String? err;
  String? ok;

  Future<void> checkout() async {
    setState(() {
      loading = true;
      err = null;
      ok = null;
    });

    try {
      final paid = int.tryParse(paidC.text.trim()) ?? 0;
      final token = await Storage.getToken();

      final res = await Api.post(
        "/api/checkout",
        {
          "paid": paid,
          "customer_name": customerC.text.trim(), // [NEW] Send to backend
          "items": widget.cart.items.map((e) => e.toApi()).toList(),
        },
        token: token,
      );

      final total = res["total"];
      final change = res["change"];
      
      if (!mounted) return;
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64),
              SizedBox(height: 16),
              Text("Transaksi Berhasil"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Total: Rp $total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Kembalian: Rp $change", style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                   Navigator.pop(context); // close dialog
                   Navigator.pop(context); // close cart page
                   
                   final trxId = res["transaction_id"];
                   if (trxId != null) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (_) => ReceiptPage(transactionId: int.parse(trxId.toString())),
                       ),
                     );
                   }
                },
                icon: const Icon(Icons.print),
                label: const Text("CETAK STRUK"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close cart page
              },
              child: const Text("OK", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      );
      
      widget.cart.clear();
      paidC.clear();
      customerC.clear();
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.cart.items;

    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang Belanja")),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "Keranjang kosong",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (c, i) {
                      final it = items[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.shopping_bag_outlined, color: Colors.deepPurple),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Rp ${it.price}",
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => setState(() => widget.cart.dec(it)),
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  ),
                                  Text(
                                    "${it.qty}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => widget.cart.inc(it)),
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Belanja", style: TextStyle(fontSize: 16)),
                        Text(
                          "Rp ${widget.cart.total}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    TextField(
                      controller: customerC,
                      decoration: const InputDecoration(
                        labelText: "Nama Pelanggan (Opsional)",
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: paidC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Uang Diterima (Rp)",
                        prefixIcon: Icon(Icons.money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: loading ? null : checkout,
                      child: loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text("PROSES PEMBAYARAN"),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
