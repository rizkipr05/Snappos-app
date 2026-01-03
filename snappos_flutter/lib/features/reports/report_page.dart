import 'package:flutter/material.dart';
import 'package:snappos_flutter/core/api.dart';
import '../../core/storage.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool loading = false;
  String? err;
  Map<String, dynamic>? data;
  
  // Future filters: startDate, endDate

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final token = await Storage.getToken();
      final res = await Api.get("/api/reports", token: token);
      setState(() => data = res);
    } catch (e) {
      if (e.toString().contains("401") || e.toString().contains("403")) {
          setState(() => err = "Akses ditolak. Hanya Admin yang bisa melihat laporan.");
      } else {
        setState(() => err = e.toString().replaceAll("Exception:", "").trim());
      }
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Laporan Penjualan")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err != null
          ? Center(child: Text(err!, style: const TextStyle(color: Colors.red)))
          : data == null
          ? const Center(child: Text("Data tidak tersedia"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          "Total Pendapatan",
                          "Rp ${data!['summary']['total_revenue']}",
                          Colors.green,
                          Icons.monetization_on,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _summaryCard(
                          "Total Transaksi",
                          "${data!['summary']['total_transactions']}",
                          Colors.blue,
                          Icons.receipt_long,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text("Penjualan Harian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Daily List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (data!['daily'] as List).length,
                    itemBuilder: (c, i) {
                      final item = data!['daily'][i];
                      return Card(
                         margin: const EdgeInsets.only(bottom: 8),
                         child: ListTile(
                           leading: Container(
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                               color: Colors.deepPurple.shade50,
                               shape: BoxShape.circle,
                             ),
                             child: const Icon(Icons.today, color: Colors.deepPurple),
                           ),
                           title: Text(item['date']),
                           trailing: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               Text("Rp ${item['revenue']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                               Text("${item['count']} Trx", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                             ],
                           ),
                         ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
