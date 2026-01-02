import 'package:flutter/material.dart';
import 'package:snappos_flutter/core/api.dart';
import 'package:snappos_flutter/core/storage.dart';
import 'cart_controller.dart';

class CartPage extends StatefulWidget {
  final CartController cart;
  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final paidC = TextEditingController();
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
        token: token,
        body: {
          "paid": paid,
          "items": widget.cart.items.map((e) => e.toApi()).toList(),
        },
      );

      final total = res["total"];
      final change = res["change"];
      setState(() => ok = "Berhasil! Total: Rp $total • Kembalian: Rp $change");
      widget.cart.clear();
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
      appBar: AppBar(title: const Text("Keranjang")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (err != null)
              Text(err!, style: const TextStyle(color: Colors.red)),
            if (ok != null)
              Text(ok!, style: const TextStyle(color: Colors.green)),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("Keranjang kosong"))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (c, i) {
                        final it = items[i];
                        return ListTile(
                          title: Text(it.name),
                          subtitle: Text(
                            "Rp ${it.price} x ${it.qty} = Rp ${it.subtotal}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() => widget.cart.dec(it));
                                },
                                icon: const Icon(Icons.remove),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() => widget.cart.inc(it));
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Total: Rp ${widget.cart.total}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: paidC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Uang dibayar",
                hintText: "contoh: 50000",
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (loading || items.isEmpty) ? null : checkout,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Bayar & Simpan Transaksi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
