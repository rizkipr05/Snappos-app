import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api.dart';
import '../../core/storage.dart';

class ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? product; // If null, it's "Create" mode
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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
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
          filePath: _imageFile?.path,
        );
      } else {
        // UPDATE
        final id = widget.product!["id"];
        await Api.postMultipart(
          "/api/products/$id", 
          data, 
          token: token,
          filePath: _imageFile?.path,
          method: "PUT",
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      setState(() => err = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Produk" : "Tambah Produk"),
      ),
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
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : (widget.product?["image"] != null && widget.product!["image"].isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "${Api.baseUrl.replaceAll('/index.php', '')}/${widget.product!["image"]}",
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                                Text("Ketuk untuk tambah gambar", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceC,
                      decoration: const InputDecoration(labelText: "Harga (Rp)"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: stockC,
                      decoration: const InputDecoration(labelText: "Stok Awal"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: skuC,
                decoration: const InputDecoration(labelText: "SKU / Kode Barang (Opsional)"),
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
