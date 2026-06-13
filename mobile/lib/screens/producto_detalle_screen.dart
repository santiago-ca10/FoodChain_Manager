import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../models/movimiento_model.dart';
import '../services/api_service.dart';
import 'form_producto_screen.dart' show FormProductoScreen;

class ProductoDetalleScreen extends StatefulWidget {
  final Producto producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  late Producto _producto;
  late Future<List<Movimiento>> _futureMovimientos;

  @override
  void initState() {
    super.initState();
    _producto = widget.producto;
    _futureMovimientos = _cargarMovimientos();
  }

  Future<List<Movimiento>> _cargarMovimientos() async {
    final todos = await ApiService().getMovimientos();
    return todos.where((m) => m.productoId == _producto.id).toList();
  }

  void _reload() {
    setState(() {
      _futureMovimientos = _cargarMovimientos();
    });
  }

  Future<void> _editarProducto() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormProductoScreen(producto: _producto),
      ),
    );
    if (resultado == true) {
      final productos = await ApiService().getProductos();
      final actualizado = productos.firstWhere(
        (p) => p.id == _producto.id,
        orElse: () => _producto,
      );
      if (mounted) {
        setState(() {
          _producto = actualizado;
          _futureMovimientos = _cargarMovimientos();
        });
      }
    }
  }

  Color _colorStock() {
    if (_producto.stock <= 0) return Colors.red;
    if (_producto.stock < 10) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final colorStock = _colorStock();

    return Scaffold(
      appBar: AppBar(
        title: Text(_producto.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editarProducto,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Card info producto ──
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _producto.nombre,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorStock.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_producto.stock % 1 == 0 ? _producto.stock.toInt() : _producto.stock} ${_producto.unidad}',
                            style: TextStyle(
                              color: colorStock,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_producto.categoria != null && _producto.categoria!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _producto.categoria!,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                    const Divider(height: 24),
                    _buildInfoRow(Icons.attach_money, 'Precio sugerido',
                        '\$${_producto.precio.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      colorStock == Colors.red
                          ? Icons.warning_amber_rounded
                          : colorStock == Colors.orange
                              ? Icons.inventory_2_outlined
                              : Icons.inventory_2,
                      'Stock actual',
                      '${_producto.stock % 1 == 0 ? _producto.stock.toInt() : _producto.stock} ${_producto.unidad}',
                      valueColor: colorStock,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Historial movimientos ──
            Text(
              'Historial de movimientos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            FutureBuilder<List<Movimiento>>(
              future: _futureMovimientos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final movimientos = snapshot.data ?? [];

                if (movimientos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'Sin movimientos registrados',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Resumen rápido
                final compras = movimientos.where((m) => m.tipo == 'compra');
                final ventas = movimientos.where((m) => m.tipo == 'venta');
                final totalCompras = compras.fold(0.0, (s, m) => s + m.totalCalculado);
                final totalVentas = ventas.fold(0.0, (s, m) => s + m.totalCalculado);

                return Column(
                  children: [
                    // Resumen
                    Row(
                      children: [
                        Expanded(
                          child: _buildResumenCard(
                            'Compras',
                            '${compras.length}',
                            '\$${totalCompras.toStringAsFixed(0)}',
                            Colors.green,
                            Icons.arrow_downward,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildResumenCard(
                            'Ventas',
                            '${ventas.length}',
                            '\$${totalVentas.toStringAsFixed(0)}',
                            Colors.blue,
                            Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Lista
                    ...movimientos.map((m) {
                      final esCompra = m.tipo == 'compra';
                      final color = esCompra ? Colors.green : Colors.blue;
                      final icono = esCompra ? Icons.arrow_downward : Icons.arrow_upward;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Icon(icono, color: color, size: 16),
                          ),
                          title: Text(
                            m.tipo.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: color,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            '${m.cantidad % 1 == 0 ? m.cantidad.toInt() : m.cantidad} uds'
                            '${m.terceroNombre != null ? ' · ${m.terceroNombre}' : ''}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${m.totalCalculado.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 13,
                                ),
                              ),
                              if (m.fecha != null)
                                Text(
                                  '${m.fecha!.day}/${m.fecha!.month}/${m.fecha!.year}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icono, String label, String valor, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icono, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildResumenCard(
      String titulo, String cantidad, String total, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(color: color, fontSize: 12)),
              Text(
                cantidad,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(total, style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
