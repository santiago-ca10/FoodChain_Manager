import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/movimiento_model.dart';
import '../models/producto_model.dart';
import '../models/tercero_model.dart';
import '../services/api_service.dart';

class FormMovimientoScreen extends StatefulWidget {
  final String tipoInicial;
  const FormMovimientoScreen({super.key, this.tipoInicial = 'compra'});

  @override
  State<FormMovimientoScreen> createState() => _FormMovimientoScreenState();
}

class _FormMovimientoScreenState extends State<FormMovimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  bool _loading = false;
  bool _loadingData = true;

  List<Producto> _productos = [];
  List<Tercero> _terceros = [];

  Producto? _productoSeleccionado;
  Tercero? _terceroSeleccionado;
  late String _tipo;

  final TextEditingController _cantidadCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();
  final TextEditingController _notasCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial;
    _cargarDatos();
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      final results = await Future.wait([
        _api.getProductos(),
        _api.getTerceros(),
      ]);
      setState(() {
        _productos = results[0] as List<Producto>;
        _terceros = results[1] as List<Tercero>;
        _loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando datos: $e')),
      );
      setState(() => _loadingData = false);
    }
  }

  void _onProductoSeleccionado(Producto? p) {
    setState(() {
      _productoSeleccionado = p;
      if (p != null && _precioCtrl.text.isEmpty) {
        _precioCtrl.text = p.precio.toStringAsFixed(2);
      }
    });
  }

  double get _total {
    final cant = int.tryParse(_cantidadCtrl.text) ?? 0;
    final precio = double.tryParse(_precioCtrl.text) ?? 0;
    return cant * precio;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_productoSeleccionado == null || _terceroSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona producto y tercero')),
      );
      return;
    }

    setState(() => _loading = true);

    final movimiento = Movimiento(
      tipo: _tipo,
      cantidad: double.parse(_cantidadCtrl.text.trim()),
      precioUnitario: double.parse(_precioCtrl.text.trim()),
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
      productoId: _productoSeleccionado!.id!,
      terceroId: _terceroSeleccionado!.id,
    );

    try {
      await _api.registrarMovimiento(movimiento);
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
    if (_loadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colorCompra = Colors.green.shade700;
    final colorVenta = Colors.red.shade700;
    final colorActivo = _tipo == 'compra' ? colorCompra : colorVenta;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar movimiento'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Selector tipo ──────────────────────────────
              Text('Tipo de movimiento',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TipoButton(
                      label: 'Compra',
                      icon: Icons.arrow_downward,
                      color: colorCompra,
                      selected: _tipo == 'compra',
                      onTap: () => setState(() => _tipo = 'compra'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TipoButton(
                      label: 'Venta',
                      icon: Icons.arrow_upward,
                      color: colorVenta,
                      selected: _tipo == 'venta',
                      onTap: () => setState(() => _tipo = 'venta'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Producto ───────────────────────────────────
              DropdownButtonFormField<Producto>(
                initialValue: _productoSeleccionado,  // era: value
                decoration: const InputDecoration(
                  labelText: 'Producto *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                items: _productos
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.nombre}  (stock: ${p.stock} ${p.unidad})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: _onProductoSeleccionado,
                validator: (v) => v == null ? 'Selecciona un producto' : null,
              ),
              const SizedBox(height: 16),

              // ── Tercero ────────────────────────────────────
              DropdownButtonFormField<Tercero>(
                initialValue: _terceroSeleccionado,  // era: value
                decoration: const InputDecoration(
                  labelText: 'Tercero *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: _terceros
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.nombre),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _terceroSeleccionado = v),
                validator: (v) => v == null ? 'Selecciona un tercero' : null,
              ),
              const SizedBox(height: 16),

              // ── Cantidad y Precio ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cantidadCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return 'Debe ser > 0';
                        if (_tipo == 'venta' &&
                            _productoSeleccionado != null &&
                            (double.tryParse(v) ?? 0) > _productoSeleccionado!.stock) {
                          return 'Stock insuficiente (${_productoSeleccionado!.stock})';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _precioCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Precio unitario *',
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
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'Precio inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Notas ──────────────────────────────────────
              TextFormField(
                controller: _notasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // ── Resumen total ──────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorActivo.withValues(alpha: 0.08),   // era: withOpacity
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorActivo.withValues(alpha: 0.3),  // era: withOpacity
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total $_tipo',   // era: '${_tipo}'
                      style: TextStyle(
                        color: colorActivo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${_total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: colorActivo,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorActivo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(_tipo == 'compra'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward),
                  label: Text(
                    'Registrar $_tipo',   // era: '${_tipo}'
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

class _TipoButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TipoButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
