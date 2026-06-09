import 'package:flutter/material.dart';
import '../models/movimiento_model.dart';
import '../models/producto_model.dart';
import '../services/api_service.dart';
import 'form_movimiento_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  late Future<_DashboardData> _futureDatos;

  static const double _umbralStockBajo = 10.0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _futureDatos = _cargarDatos();
    });
  }

  Future<_DashboardData> _cargarDatos() async {
    final results = await Future.wait([
      _api.getMovimientos(),
      _api.getProductos(),
    ]);
    final movimientos = results[0] as List<Movimiento>;
    final productos = results[1] as List<Producto>;
    return _DashboardData(movimientos: movimientos, productos: productos);
  }

  void _irARegistrar(String tipo) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMovimientoScreen(tipoInicial: tipo),
      ),
    );
    if (resultado == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: FutureBuilder<_DashboardData>(
        future: _futureDatos,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              // ── AppBar ─────────────────────────────────────
              SliverAppBar(
                expandedHeight: 110,
                floating: true,
                pinned: true,
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.only(left: 20, bottom: 14),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FoodChain Manager',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _fechaHoy(),
                        style: TextStyle(
                          color: cs.onPrimary.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cs.primary, cs.secondary],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_outlined),
                    onPressed: _cargar,
                    tooltip: 'Actualizar',
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: _ErrorView(
                    mensaje: snapshot.error.toString(),
                    onRetry: _cargar,
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── KPIs hoy ─────────────────────────
                      _SeccionTitulo(titulo: 'Hoy'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _KpiCard(
                              titulo: 'Compras',
                              valor: snapshot.data!.comprasHoy,
                              total: snapshot.data!.totalComprasHoy,
                              icono: Icons.arrow_downward,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _KpiCard(
                              titulo: 'Ventas',
                              valor: snapshot.data!.ventasHoy,
                              total: snapshot.data!.totalVentasHoy,
                              icono: Icons.arrow_upward,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),

                      // ── KPIs semana ───────────────────────
                      const SizedBox(height: 20),
                      _SeccionTitulo(titulo: 'Esta semana'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _KpiCard(
                              titulo: 'Compras',
                              valor: snapshot.data!.comprasSemana,
                              total: snapshot.data!.totalComprasSemana,
                              icono: Icons.arrow_downward,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _KpiCard(
                              titulo: 'Ventas',
                              valor: snapshot.data!.ventasSemana,
                              total: snapshot.data!.totalVentasSemana,
                              icono: Icons.arrow_upward,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),

                      // ── Ganancia estimada ─────────────────
                      const SizedBox(height: 12),
                      _GananciaCard(
                        ganancia: snapshot.data!.gananciaSemana,
                      ),

                      // ── Stock crítico ─────────────────────
                      const SizedBox(height: 20),
                      _SeccionTitulo(titulo: 'Alertas de stock'),
                      const SizedBox(height: 10),
                      if (snapshot.data!.stockCritico.isEmpty)
                        _StockOkCard()
                      else
                        ...snapshot.data!.stockCritico
                            .map((p) => _StockAlertaItem(
                                  producto: p,
                                  umbral: _umbralStockBajo,
                                )),

                      // ── Accesos rápidos ───────────────────
                      const SizedBox(height: 20),
                      _SeccionTitulo(titulo: 'Accesos rápidos'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _AccesoRapido(
                              label: 'Nueva compra',
                              icono: Icons.add_shopping_cart,
                              color: Colors.green.shade700,
                              onTap: () => _irARegistrar('compra'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AccesoRapido(
                              label: 'Nueva venta',
                              icono: Icons.point_of_sale,
                              color: Colors.red.shade700,
                              onTap: () => _irARegistrar('venta'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _fechaHoy() {
    final now = DateTime.now();
    const meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${now.day} de ${meses[now.month]} de ${now.year}';
  }
}

// ── Modelo de datos del dashboard ─────────────────────────────

class _DashboardData {
  final List<Movimiento> movimientos;
  final List<Producto> productos;

  _DashboardData({required this.movimientos, required this.productos});

  static const double _umbral = 10.0;

  bool _esHoy(DateTime? fecha) {
    if (fecha == null) return false;
    final now = DateTime.now();
    return fecha.year == now.year &&
        fecha.month == now.month &&
        fecha.day == now.day;
  }

  bool _esSemana(DateTime? fecha) {
    if (fecha == null) return false;
    final now = DateTime.now();
    final inicioSemana = now.subtract(Duration(days: now.weekday - 1));
    final inicio = DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day);
    return fecha.isAfter(inicio.subtract(const Duration(seconds: 1)));
  }

  List<Movimiento> get _comprasHoy => movimientos
      .where((m) => m.tipo == 'compra' && _esHoy(m.fecha))
      .toList();

  List<Movimiento> get _ventasHoy => movimientos
      .where((m) => m.tipo == 'venta' && _esHoy(m.fecha))
      .toList();

  List<Movimiento> get _comprasSemana => movimientos
      .where((m) => m.tipo == 'compra' && _esSemana(m.fecha))
      .toList();

  List<Movimiento> get _ventasSemana => movimientos
      .where((m) => m.tipo == 'venta' && _esSemana(m.fecha))
      .toList();

  int get comprasHoy => _comprasHoy.length;
  int get ventasHoy => _ventasHoy.length;
  int get comprasSemana => _comprasSemana.length;
  int get ventasSemana => _ventasSemana.length;

  double get totalComprasHoy =>
      _comprasHoy.fold(0, (s, m) => s + m.totalCalculado);
  double get totalVentasHoy =>
      _ventasHoy.fold(0, (s, m) => s + m.totalCalculado);
  double get totalComprasSemana =>
      _comprasSemana.fold(0, (s, m) => s + m.totalCalculado);
  double get totalVentasSemana =>
      _ventasSemana.fold(0, (s, m) => s + m.totalCalculado);
  double get gananciaSemana => totalVentasSemana - totalComprasSemana;

  List<Producto> get stockCritico =>
      productos.where((p) => p.stock < _umbral).toList();
}

// ── Widgets ───────────────────────────────────────────────────

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String titulo;
  final int valor;
  final double total;
  final IconData icono;
  final Color color;

  const _KpiCard({
    required this.titulo,
    required this.valor,
    required this.total,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(titulo,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$valor',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              '\$${_formatear(total)}',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  String _formatear(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class _GananciaCard extends StatelessWidget {
  final double ganancia;
  const _GananciaCard({required this.ganancia});

  @override
  Widget build(BuildContext context) {
    final positivo = ganancia >= 0;
    final color = positivo ? Colors.green.shade700 : Colors.red.shade700;
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  positivo ? Icons.trending_up : Icons.trending_down,
                  color: color,
                ),
                const SizedBox(width: 10),
                Text(
                  'Ganancia estimada\nesta semana',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface),
                ),
              ],
            ),
            Text(
              '${positivo ? '+' : ''}\$${_formatear(ganancia)}',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _formatear(double v) {
    final abs = v.abs();
    if (abs >= 1000000) return '${(abs / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '${(abs / 1000).toStringAsFixed(1)}k';
    return abs.toStringAsFixed(0);
  }
}

class _StockOkCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green.shade600),
            const SizedBox(width: 12),
            const Text('Todos los productos tienen stock suficiente'),
          ],
        ),
      ),
    );
  }
}

class _StockAlertaItem extends StatelessWidget {
  final Producto producto;
  final double umbral;
  const _StockAlertaItem({required this.producto, required this.umbral});

  @override
  Widget build(BuildContext context) {
    final critico = producto.stock <= 0;
    final color = critico ? Colors.red.shade700 : Colors.orange.shade700;
    final label = critico ? 'AGOTADO' : 'BAJO';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        leading: Icon(
          critico ? Icons.remove_circle_outline : Icons.warning_amber_outlined,
          color: color,
        ),
        title: Text(producto.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            'Stock: ${producto.stock.toStringAsFixed(1)} ${producto.unidad}'),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _AccesoRapido extends StatelessWidget {
  final String label;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _AccesoRapido({
    required this.label,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;
  const _ErrorView({required this.mensaje, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No se pudo conectar al servidor',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(mensaje,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
