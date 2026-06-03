import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FormTerceroScreen extends StatefulWidget {
  const FormTerceroScreen({super.key});

  @override
  State<FormTerceroScreen> createState() => _FormTerceroScreenState();
}

class _FormTerceroScreenState extends State<FormTerceroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  String _tipoSeleccionado = 'cliente';
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      await ApiService().crearTercero({
        'nombre': _nombreController.text.trim(),
        'tipo': _tipoSeleccionado,
        'telefono': _telefonoController.text.trim(),
        'direccion': _direccionController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo tercero')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _tipoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'cliente',   child: Text('Cliente')),
                DropdownMenuItem(value: 'proveedor', child: Text('Proveedor')),
                DropdownMenuItem(value: 'ambos',     child: Text('Ambos')),
              ],
              onChanged: (v) => setState(() => _tipoSeleccionado = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}