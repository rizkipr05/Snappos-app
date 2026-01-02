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
        title: const Text("Katalog Produk"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.deepPurple),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.deepPurple),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CartPage(cart: cart)),
                  );
                  await load();
                  setState(() {});
                },
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${cart.items.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.grey),
            onPressed: logout,
          ),
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
                      const Icon(Icons.lock_clock_outlined, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text("Sesi Habis", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text("Silakan login kembali untuk melanjutkan"),
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
          : RefreshIndicator(
              onRefresh: load,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (c, i) {
                  final p = products[i];
                  final id = int.parse(p["id"].toString());
                  final name = p["name"].toString();
                  final price = int.parse(p["price"].toString());
                  final stock = int.parse(p["stock"].toString());
                  final isOos = stock <= 0;

                  return Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade100,
                            width: double.infinity,
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: Colors.deepPurple.shade100,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp $price",
                                style: TextStyle(
                                  color: Colors.deepPurple.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isOos ? "Stok Habis" : "Stok: $stock",
                                style: TextStyle(
                                  color: isOos ? Colors.red : Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: isOos
                                      ? null
                                      : () {
                                          cart.add(id, name, price);
                                          setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('$name masuk keranjang'),
                                              duration: const Duration(milliseconds: 500),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("TAMBAH"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${cart.items.length} Barang",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "Total: Rp ${cart.total}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CartPage(cart: cart)),
                        );
                        await load();
                        setState(() {});
                      },
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text("Checkout"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(140, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
