import 'package:flutter/material.dart';
import '../models/tercero_model.dart';
import '../services/api_service.dart';

class FormTerceroScreen extends StatefulWidget {
  final Tercero? tercero;

  const FormTerceroScreen({super.key, this.tercero});

  @override
  State<FormTerceroScreen> createState() => _FormTerceroScreenState();
}

class _FormTerceroScreenState extends State<FormTerceroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _direccionCtrl;
  String _tipo = 'cliente';
  bool _loading = false;

  bool get _esEdicion => widget.tercero != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tercero;
    _nombreCtrl   = TextEditingController(text: t?.nombre ?? '');
    _telefonoCtrl = TextEditingController(text: t?.telefono ?? '');
    _direccionCtrl = TextEditingController(text: t?.direccion ?? '');
    if (t != null) _tipo = t.tipo;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final datos = {
      'nombre':    _nombreCtrl.text.trim(),
      'tipo':      _tipo,
      'telefono':  _telefonoCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim(),
    };

    try {
      if (_esEdicion) {
        await _api.actualizarTercero(widget.tercero!.id, datos);
      } else {
        await _api.crearTercero(datos);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar tercero' : 'Nuevo tercero'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'cliente',   child: Text('Cliente')),
                  DropdownMenuItem(value: 'proveedor', child: Text('Proveedor')),
                  DropdownMenuItem(value: 'ambos',     child: Text('Ambos')),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'cliente'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _guardar,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_esEdicion ? 'Guardar cambios' : 'Crear tercero'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}