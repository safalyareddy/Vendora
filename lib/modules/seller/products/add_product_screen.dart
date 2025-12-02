import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _form = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _categoryCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _priceCtl = TextEditingController();
  final _moqCtl = TextEditingController();
  final _stockCtl = TextEditingController();

  bool _negotiable = true;

  final List<XFile> _images = [];
  final List<Map<String, dynamic>> _slabs = [];

  final ImagePicker _picker = ImagePicker();

  // ------------------
  // Pick Images
  // ------------------
  Future<void> _pickImages() async {
    final pickedImages = await _picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      setState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _addSlab() {
    setState(() {
      _slabs.add({"min": 1, "max": 1, "price": 0});
    });
  }

  void _removeSlab(int idx) {
    setState(() => _slabs.removeAt(idx));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final service = Provider.of<ProductService>(context, listen: false);

    final newProduct = Product(
      id: service.generateId(),
      name: _nameCtl.text.trim(),
      category: _categoryCtl.text.trim(),
      description: _descCtl.text.trim(),
      price: double.tryParse(_priceCtl.text.trim()) ?? 0.0,
      moq: int.tryParse(_moqCtl.text.trim()) ?? 1,
      stock: int.tryParse(_stockCtl.text.trim()) ?? 0,
      negotiable: _negotiable,
      images: _images.map((e) => e.path).toList(), // only paths for now
      slabPricing: _slabs,
    );

    await service.addProduct(newProduct);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _categoryCtl.dispose();
    _descCtl.dispose();
    _priceCtl.dispose();
    _moqCtl.dispose();
    _stockCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add product")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: InputDecoration(labelText: "Product name"),
                validator: (v) => (v?.isEmpty ?? true) ? "Required" : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _categoryCtl,
                decoration: InputDecoration(labelText: "Category"),
                validator: (v) => (v?.isEmpty ?? true) ? "Required" : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descCtl,
                decoration: InputDecoration(labelText: "Description"),
                minLines: 3,
                maxLines: 5,
              ),
              SizedBox(height: 12),

              // ------------------
              // IMAGE PICKER UI
              // ------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Product Images",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: _pickImages,
                    icon: Icon(Icons.add_a_photo),
                    label: Text("Add Images"),
                  ),
                ],
              ),

              SizedBox(height: 8),

              _images.isEmpty
                  ? Text("No images selected.")
                  : SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (_, i) => Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(
                                    // using FileImage for preview
                                    File(_images[i].path),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // delete button
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(i),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtl,
                      decoration: InputDecoration(labelText: "Price (₹)"),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Required" : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _moqCtl,
                      decoration: InputDecoration(labelText: "MOQ"),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Required" : null,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),
              TextFormField(
                controller: _stockCtl,
                decoration: InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),

              SwitchListTile(
                title: Text("Allow negotiation"),
                value: _negotiable,
                onChanged: (v) => setState(() => _negotiable = v),
              ),

              Divider(),

              // Slab pricing section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Slab pricing",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: _addSlab,
                    icon: Icon(Icons.add),
                    label: Text("Add slab"),
                  ),
                ],
              ),

              if (_slabs.isEmpty)
                Text("No slabs. Buyers will be charged the base price."),

              ..._slabs.asMap().entries.map((e) {
                final idx = e.key;
                final slab = e.value;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: slab['min'].toString(),
                                decoration: InputDecoration(
                                  labelText: "Min qty",
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => slab['min'] =
                                    int.tryParse(v) ?? slab['min'],
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: slab['max'].toString(),
                                decoration: InputDecoration(
                                  labelText: "Max qty",
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => slab['max'] =
                                    int.tryParse(v) ?? slab['max'],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        TextFormField(
                          initialValue: slab['price'].toString(),
                          decoration: InputDecoration(
                            labelText: "Price per unit (₹)",
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) => slab['price'] =
                              double.tryParse(v) ?? slab['price'],
                        ),

                        SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _removeSlab(idx),
                            icon: Icon(Icons.delete),
                            label: Text("Remove slab"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(Icons.save),
                label: Text("Save product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
