import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto_model.dart';
import '../services/api_service.dart';

class FormProductoScreen extends StatefulWidget {
  final Producto? producto;
  const FormProductoScreen({super.key, this.producto});

  @override
  State<FormProductoScreen> createState() => _FormProductoScreenState();
}

class _FormProductoScreenState extends State<FormProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  bool _loading = false;
  bool get _esEdicion => widget.producto != null;

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _categoriaCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _unidadCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _categoriaCtrl = TextEditingController(text: p?.categoria ?? '');
    _precioCtrl = TextEditingController(
        text: p != null ? p.precio.toStringAsFixed(2) : '');
    _stockCtrl = TextEditingController(
        text: p != null ? p.stock.toStringAsFixed(2) : '0');
    _unidadCtrl = TextEditingController(text: p?.unidad ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _categoriaCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _unidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final producto = Producto(
      id: widget.producto?.id,
      nombre: _nombreCtrl.text.trim(),
      categoria: _categoriaCtrl.text.trim().isEmpty
          ? null
          : _categoriaCtrl.text.trim(),
      precio: double.parse(_precioCtrl.text.trim()),
      stock: double.parse(_stockCtrl.text.trim()),
      unidad: _unidadCtrl.text.trim(),
    );

    try {
      if (_esEdicion) {
        await _api.updateProducto(widget.producto!.id!, producto);
      } else {
        await _api.createProducto(producto);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                  hintText: 'ej: Lácteo, Insumo, Herramienta',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Precio sugerido *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        final n = double.tryParse(v);
                        if (n == null || n < 0) return 'Precio inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Stock inicial *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.layers_outlined),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        final n = double.tryParse(v);
                        if (n == null || n < 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unidadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Unidad de medida *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten_outlined),
                  hintText: 'ej: Litros, Kilos, Unidades',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _guardar,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_esEdicion ? Icons.save_outlined : Icons.add),
                  label:
                      Text(_esEdicion ? 'Guardar cambios' : 'Crear producto'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
