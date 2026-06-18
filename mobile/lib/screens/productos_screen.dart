import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/api_service.dart';
import 'form_producto_screen.dart';
import 'producto_detalle_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  late Future<List<Producto>> _futureProductos;
  final ApiService _api = ApiService();
  final _searchCtrl = TextEditingController();

  String _busqueda = '';
  String? _categoriaFiltro; // null = todas
  bool _soloStockBajo = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _cargar() {
    setState(() {
      _futureProductos = _api.getProductos();
    });
  }

  List<Producto> _filtrar(List<Producto> lista) {
    return lista.where((p) {
      final matchBusqueda = _busqueda.isEmpty ||
          p.nombre.toLowerCase().contains(_busqueda.toLowerCase());
      final matchCategoria = _categoriaFiltro == null ||
          (p.categoria?.toLowerCase() == _categoriaFiltro!.toLowerCase());
      final matchStock = !_soloStockBajo || p.stock < 10;
      return matchBusqueda && matchCategoria && matchStock;
    }).toList();
  }

  List<String> _categorias(List<Producto> lista) {
    final cats = lista
        .map((p) => p.categoria)
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return cats;
  }

  Future<void> _eliminar(String id) async {
    try {
      await _api.deleteProducto(id);
      _cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar producto'),
            content: const Text(
                'Se revertirán los movimientos asociados. ¿Continuar?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _irADetalle(Producto producto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoDetalleScreen(producto: producto),
      ),
    );
    _cargar();
  }

  void _irAFormulario() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FormProductoScreen()),
    );
    if (resultado == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Producto>>(
        future: _futureProductos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final todos = snapshot.data ?? [];
          final categorias = _categorias(todos);
          final productos = _filtrar(todos);

          if (todos.isEmpty) {
            return const Center(
                child: Text('No hay productos registrados.'));
          }

          return Column(
            children: [
              // ── Barra de búsqueda ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _busqueda = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),

              // ── Chips de filtro ──────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    // Stock bajo
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Stock bajo'),
                        selected: _soloStockBajo,
                        selectedColor: Colors.orange.withValues(alpha: 0.2),
                        avatar: const Icon(Icons.warning_amber_rounded,
                            size: 16),
                        onSelected: (v) =>
                            setState(() => _soloStockBajo = v),
                      ),
                    ),
                    // Separador visual
                    if (categorias.isNotEmpty)
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey.withValues(alpha: 0.4),
                        margin: const EdgeInsets.only(right: 8),
                      ),
                    // Todas las categorías
                    if (categorias.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('Todas'),
                          selected: _categoriaFiltro == null,
                          onSelected: (_) =>
                              setState(() => _categoriaFiltro = null),
                        ),
                      ),
                    // Una por categoría
                    ...categorias.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: _categoriaFiltro == cat,
                          onSelected: (_) =>
                              setState(() => _categoriaFiltro = cat),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Lista ────────────────────────────────────
              Expanded(
                child: productos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text('Sin resultados',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _busqueda = '';
                                  _categoriaFiltro = null;
                                  _soloStockBajo = false;
                                });
                              },
                              child: const Text('Limpiar filtros'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _cargar(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            final p = productos[index];
                            final stockBajo = p.stock < 10;
                            return Dismissible(
                              key: ValueKey(p.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) =>
                                  _confirmarEliminar(context),
                              onDismissed: (_) => _eliminar(p.id!),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(Icons.delete,
                                    color: Colors.white, size: 28),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Text(
                                    p.nombre[0].toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(p.nombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  'Stock: ${p.stock % 1 == 0 ? p.stock.toInt() : p.stock} ${p.unidad}  •  \$${p.precio.toStringAsFixed(2)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (stockBajo)
                                      Icon(
                                          Icons.warning_amber_rounded,
                                          color: p.stock <= 0
                                              ? Colors.red
                                              : Colors.orange,
                                          size: 18),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                                onTap: () => _irADetalle(p),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irAFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
    );
  }
}
