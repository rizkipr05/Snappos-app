import 'package:flutter/material.dart';
import 'package:snappos_flutter/core/api.dart';
import 'package:snappos_flutter/core/storage.dart';
import '../auth/login_page.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_page.dart';
import '../transactions/history_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final cart = CartController();
  bool loading = true;
  String? err;
  List<Map<String, dynamic>> products = [];

  Future<void> load() async {
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final token = await Storage.getToken();
      final res = await Api.get("/api/products", token: token);
      final data = (res["data"] as List).cast<Map<String, dynamic>>();
      setState(() => products = data);
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
      appBar: AppBar(
        title: const Text("Produk"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartPage(cart: cart)),
              );
              await load(); // refresh stok setelah checkout
              setState(() {});
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err != null
          ? err!.toLowerCase().contains("unauthorized") || err!.toLowerCase().contains("unauthenticated")
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, size: 48, color: Colors.orange),
                      const SizedBox(height: 16),
                      const Text("Sesi Habis (Unauthorized)"),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: logout,
                        child: const Text("Login Ulang"),
                      ),
                    ],
                  ),
                )
              : Center(child: Text(err!))
          : RefreshIndicator(
              onRefresh: load,
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (c, i) {
                  final p = products[i];
                  final id = int.parse(p["id"].toString());
                  final name = p["name"].toString();
                  final price = int.parse(p["price"].toString());
                  final stock = int.parse(p["stock"].toString());

                  return ListTile(
                    title: Text(name),
                    subtitle: Text("Rp $price • Stok: $stock"),
                    trailing: ElevatedButton(
                      onPressed: stock <= 0
                          ? null
                          : () {
                              cart.add(id, name, price);
                              setState(() {});
                            },
                      child: const Text("Tambah"),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Item: ${cart.items.length} • Total: Rp ${cart.total}",
              ),
            ),
            ElevatedButton(
              onPressed: cart.items.isEmpty
                  ? null
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CartPage(cart: cart)),
                      );
                      await load();
                      setState(() {});
                    },
              child: const Text("Checkout"),
            ),
          ],
        ),
      ),
    );
  }
}
