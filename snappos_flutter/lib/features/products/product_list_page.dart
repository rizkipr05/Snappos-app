import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/storage.dart';
import '../auth/login_page.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_page.dart';
import '../transactions/history_page.dart';
import '../transactions/receipt_page.dart'; // unused but kept for consistency
import '../reports/report_page.dart';
import '../dashboard/dashboard_page.dart';
import 'product_form_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> products = [];
  bool loading = false;
  String? err;
  String? role;

  // Cart
  final CartController cart = CartController();

  @override
  void initState() {
    super.initState();
    _checkRole();
    load();
  }

  Future<void> _checkRole() async {
    final r = await Storage.getRole();
    if (mounted) setState(() => role = r);
  }

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
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> logout() async {
    await Storage.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: const Text("Produk akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => loading = true);
    try {
      final token = await Storage.getToken();
      await Api.delete("/api/products/$id", token: token);
      await load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil dihapus")),
      );
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
      setState(() => loading = false);
    }
  }

  /// Bangun URL gambar yang aman:
  /// - jika value sudah http/https => pakai langsung
  /// - jika value path relatif (uploads/...) => gabungkan ke host public (tanpa index.php)
  String? buildImageUrl(dynamic image) {
    if (image == null) return null;
    final s = image.toString().trim();
    if (s.isEmpty) return null;

    if (s.startsWith("http://") || s.startsWith("https://")) return s;

    // Api.baseUrl biasanya: http://ip:8080/snappos_api/public/index.php
    // Untuk file static, kita butuh: http://ip:8080/snappos_api/public/
    final basePublic = Api.baseUrl
        .replaceAll("/index.php", "")
        .replaceAll(RegExp(r"/+$"), "");

    final cleanPath = s.replaceFirst(RegExp(r"^/+"), "");
    return "$basePublic/$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    // Everyone uses "admin" features (edit/delete) AND "cashier" features (cart)
    const isAdmin = true; 

    return Scaffold(
      appBar: AppBar(
        title: const Text("Katalog Produk"),
        actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.deepPurple),
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
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              accountName: Text("Petugas"),
              accountEmail: Text("Snappos System"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Katalog Produk'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Transaksi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Laporan Penjualan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err != null
              ? err!.toLowerCase().contains("unauthorized") ||
                      err!.toLowerCase().contains("unauthenticated")
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_clock_outlined,
                              size: 64, color: Colors.orange),
                          const SizedBox(height: 16),
                          Text("Sesi Habis",
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          const Text("Silakan login kembali untuk melanjutkan"),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: logout,
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 50),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
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

                      final imgUrl = buildImageUrl(p["image"]);

                      return Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  (imgUrl != null)
                                      ? Image.network(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (c, o, s) => Container(
                                            color: Colors.grey.shade100,
                                            width: double.infinity,
                                            child: Icon(Icons.broken_image,
                                                color: Colors.grey.shade400),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey.shade100,
                                          width: double.infinity,
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            size: 48,
                                            color:
                                                Colors.deepPurple.shade100,
                                          ),
                                        ),
                                    Positioned( // Always show edit/delete
                                      top: 4,
                                      right: 4,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.edit,
                                                  size: 18,
                                                  color: Colors.blue),
                                              onPressed: () async {
                                                final refresh =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ProductFormPage(
                                                            product: p),
                                                  ),
                                                );
                                                if (refresh == true) load();
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.delete,
                                                  size: 18,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  deleteProduct(id),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
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
                                      color: isOos
                                          ? Colors.red
                                          : Colors.grey.shade600,
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
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '$name masuk keranjang'),
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
      floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductFormPage()),
                );
                if (refresh == true) load();
              },
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomNavigationBar: (cart.items.isEmpty)
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
