import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wholesale_pro_app/models/product_model.dart';
import '../../../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({required this.product, super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _nameCtl;
  late final TextEditingController _categoryCtl;
  late final TextEditingController _descCtl;
  late final TextEditingController _priceCtl;
  late final TextEditingController _moqCtl;
  late final TextEditingController _stockCtl;
  late bool _negotiable;
  late List<String> _images;
  late List<Map<String, dynamic>> _slabs;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtl = TextEditingController(text: p.name);
    _categoryCtl = TextEditingController(text: p.category);
    _descCtl = TextEditingController(text: p.description);
    _priceCtl = TextEditingController(text: p.price.toString());
    _moqCtl = TextEditingController(text: p.moq.toString());
    _stockCtl = TextEditingController(text: p.stock.toString());
    _negotiable = p.negotiable;
    _images = List.from(p.images);
    _slabs = p.slabPricing.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _addSlab() =>
      setState(() => _slabs.add({"min": 1, "max": 1, "price": 0.0}));
  void _removeSlab(int idx) => setState(() => _slabs.removeAt(idx));

  Future<void> _save() async {
    final service = Provider.of<ProductService>(context, listen: false);
    final updated = widget.product.copyWith(
      name: _nameCtl.text.trim(),
      category: _categoryCtl.text.trim(),
      description: _descCtl.text.trim(),
      price: double.tryParse(_priceCtl.text.trim()) ?? widget.product.price,
      moq: int.tryParse(_moqCtl.text.trim()) ?? widget.product.moq,
      stock: int.tryParse(_stockCtl.text.trim()) ?? widget.product.stock,
      negotiable: _negotiable,
      images: _images,
      slabPricing: _slabs,
    );
    await service.updateProduct(updated);
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
      appBar: AppBar(title: Text("Edit product")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameCtl,
              decoration: InputDecoration(labelText: "Product name"),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _categoryCtl,
              decoration: InputDecoration(labelText: "Category"),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _descCtl,
              decoration: InputDecoration(labelText: "Description"),
              minLines: 3,
              maxLines: 5,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtl,
                    decoration: InputDecoration(labelText: "Price (₹)"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _moqCtl,
                    decoration: InputDecoration(labelText: "MOQ"),
                    keyboardType: TextInputType.number,
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
                              decoration: InputDecoration(labelText: "Min qty"),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  slab['min'] = int.tryParse(v) ?? slab['min'],
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: slab['max'].toString(),
                              decoration: InputDecoration(labelText: "Max qty"),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  slab['max'] = int.tryParse(v) ?? slab['max'],
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
                        onChanged: (v) =>
                            slab['price'] = double.tryParse(v) ?? slab['price'],
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
            SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _save,
              icon: Icon(Icons.save),
              label: Text("Update product"),
            ),
          ],
        ),
      ),
    );
  }
}
