import 'package:flutter/material.dart';
import 'package:snappos_flutter/core/storage.dart';
import 'package:snappos_flutter/features/auth/login_page.dart';
import 'package:snappos_flutter/features/products/product_list_page.dart';
import 'package:snappos_flutter/features/reports/report_page.dart';
import 'package:snappos_flutter/features/transactions/history_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String role = "";
  
  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final r = await Storage.getRole();
    if (mounted) setState(() => role = r ?? "");
  }

  Future<void> logout() async {
    await Storage.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == "admin";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              accountName: Text(isAdmin ? "Administrator" : "Kasir"),
              accountEmail: const Text("Snappos System"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  size: 32,
                  color: Colors.deepPurple,
                ),
              ),
            ),
             ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Katalog Produk'),
              onTap: () {
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListPage()));
              },
            ),
             ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Transaksi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
              },
            ),
            if (isAdmin)
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildWelcomeCard(isAdmin),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _menuItem(
                  "Katalog Produk",
                  Icons.store,
                  Colors.deepPurple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListPage())),
                ),
                _menuItem(
                  "Riwayat",
                  Icons.history,
                  Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage())),
                ),
                if (isAdmin)
                  _menuItem(
                    "Laporan",
                    Icons.bar_chart,
                    Colors.blue,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage())),
                  ),
                _menuItem(
                  "Keluar",
                  Icons.logout,
                  Colors.red,
                  logout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              size: 32,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat Datang,",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin ? "Administrator" : "Kasir",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
