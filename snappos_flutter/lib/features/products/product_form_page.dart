import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api.dart';
import '../../core/storage.dart';

class ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? product; // null = create
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameC;
  late TextEditingController priceC;
  late TextEditingController stockC;
  late TextEditingController skuC;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool loading = false;
  String? err;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameC = TextEditingController(text: p?["name"]?.toString() ?? "");
    priceC = TextEditingController(text: p?["price"]?.toString() ?? "");
    stockC = TextEditingController(text: p?["stock"]?.toString() ?? "");
    skuC = TextEditingController(text: p?["sku"]?.toString() ?? "");
  }

  @override
  void dispose() {
    nameC.dispose();
    priceC.dispose();
    stockC.dispose();
    skuC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  String? buildImageUrl(dynamic image) {
    if (image == null) return null;
    final s = image.toString().trim();
    if (s.isEmpty) return null;

    // sudah URL full
    if (s.startsWith("http://") || s.startsWith("https://")) return s;

    // base file static: baseUrl tanpa /index.php
    final basePublic = Api.baseUrl
        .replaceAll("/index.php", "")
        .replaceAll(RegExp(r"/+$"), "");

    final cleanPath = s.replaceFirst(RegExp(r"^/+"), "");
    return "$basePublic/$cleanPath";
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      err = null;
    });

    try {
      final token = await Storage.getToken();

      final data = {
        "name": nameC.text.trim(),
        "price": priceC.text.trim(),
        "stock": stockC.text.trim(),
        "sku": skuC.text.trim(),
      };

      if (widget.product == null) {
        // CREATE
        await Api.postMultipart(
          "/api/products",
          data,
          token: token,
          filePath: _imageFile?.path, // boleh null
        );
      } else {
        // UPDATE
        final id = widget.product!["id"].toString();
        await Api.postMultipart(
          "/api/products/$id",
          data,
          token: token,
          filePath: _imageFile?.path, // kalau null, jangan ubah image
          method: "PUT",
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final imgUrl = buildImageUrl(widget.product?["image"]);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Produk" : "Tambah Produk")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
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
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Nama Produk"),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Wajib diisi"
                    : null,
              ),
              const SizedBox(height: 16),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : (imgUrl != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 54, color: Colors.grey),
                                ),
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt,
                                    size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Ketuk untuk tambah gambar",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceC,
                      decoration: const InputDecoration(labelText: "Harga (Rp)"),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "Wajib diisi"
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: stockC,
                      decoration: const InputDecoration(labelText: "Stok Awal"),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "Wajib diisi"
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: skuC,
                decoration: const InputDecoration(
                    labelText: "SKU / Kode Barang (Opsional)"),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: loading ? null : save,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(isEdit ? "SIMPAN PERUBAHAN" : "TAMBAH PRODUK"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
