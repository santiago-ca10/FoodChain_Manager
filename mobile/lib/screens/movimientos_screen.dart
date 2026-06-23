import 'package:flutter/material.dart';
import '../models/movimiento_model.dart';
import '../services/api_service.dart';
import '../services/export_service.dart';
import 'form_movimiento_screen.dart';

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  late Future<List<Movimiento>> _futureMovimientos;

  String _filtroTipo = 'todos';
  String _filtroFecha = 'todos';

  final _export = ExportService();
  bool _exportando = false;

  @override
  void initState() {
    super.initState();
    _futureMovimientos = ApiService().getMovimientos();
  }

  void _reload() {
    setState(() {
      _futureMovimientos = ApiService().getMovimientos();
    });
  }

  List<Movimiento> _aplicarFiltros(List<Movimiento> todos) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final inicioSemana = hoy.subtract(Duration(days: ahora.weekday - 1));
    final inicioMes = DateTime(ahora.year, ahora.month, 1);

    return todos.where((m) {
      if (_filtroTipo != 'todos' && m.tipo != _filtroTipo) return false;
      if (_filtroFecha != 'todos') {
        final fecha = m.fecha ?? DateTime(2000);
        final soloFecha = DateTime(fecha.year, fecha.month, fecha.day);
        if (_filtroFecha == 'hoy' && soloFecha != hoy) return false;
        if (_filtroFecha == 'semana' && soloFecha.isBefore(inicioSemana)) return false;
        if (_filtroFecha == 'mes' && soloFecha.isBefore(inicioMes)) return false;
      }
      return true;
    }).toList();
  }

  // ── Exportar ──────────────────────────────────────────────

  String _tituloExport() {
    final partes = <String>[];
    if (_filtroTipo != 'todos') partes.add(_filtroTipo[0].toUpperCase() + _filtroTipo.substring(1) + 's');
    if (_filtroFecha == 'hoy') partes.add('Hoy');
    if (_filtroFecha == 'semana') partes.add('Esta semana');
    if (_filtroFecha == 'mes') partes.add('Este mes');
    return partes.isEmpty ? 'Movimientos' : 'Movimientos — ${partes.join(' · ')}';
  }

  void _mostrarOpcionesExport(List<Movimiento> filtrados) {
    if (filtrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay movimientos para exportar')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Exportar ${filtrados.length} movimiento${filtrados.length != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _tituloExport(),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            _opcionExport(
              icono: Icons.picture_as_pdf_outlined,
              color: Colors.red.shade700,
              label: 'PDF',
              sublabel: 'Tabla completa con resumen',
              onTap: () => _ejecutarExport(
                  filtrados, 'pdf', () => _export.exportarPDF(filtrados, titulo: _tituloExport())),
            ),
            const SizedBox(height: 12),
            _opcionExport(
              icono: Icons.table_chart_outlined,
              color: Colors.green.shade700,
              label: 'Excel (.xlsx)',
              sublabel: 'Hoja de cálculo editable',
              onTap: () => _ejecutarExport(
                  filtrados, 'excel', () => _export.exportarExcel(filtrados, titulo: _tituloExport())),
            ),
            const SizedBox(height: 12),
            _opcionExport(
              icono: Icons.image_outlined,
              color: Colors.blue.shade700,
              label: 'Imagen (PNG)',
              sublabel: 'Captura de la tabla (máx. 30 filas)',
              onTap: () => _ejecutarExport(
                  filtrados, 'img', () => _export.exportarImagen(filtrados, titulo: _tituloExport())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcionExport({
    required IconData icono,
    required Color color,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(sublabel,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Future<void> _ejecutarExport(
      List<Movimiento> filtrados, String tipo, Future<void> Function() fn) async {
    Navigator.pop(context); // cierra bottom sheet
    setState(() => _exportando = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  // ── Eliminar ──────────────────────────────────────────────

  Future<void> _eliminar(Movimiento m) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: Text(
          '¿Eliminar ${m.tipo.toUpperCase()} de ${m.cantidad} unidades?\n'
          'Se revertirá el stock del producto.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        await ApiService().deleteMovimiento(m.id!);
        _reload();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  // ── Chips ─────────────────────────────────────────────────

  Widget _buildChipTipo(String valor, String label) {
    final seleccionado = _filtroTipo == valor;
    Color? color;
    if (valor == 'compra') color = Colors.green;
    if (valor == 'venta') color = Colors.blue;

    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      selectedColor:
          (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.2),
      checkmarkColor: color ?? Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: seleccionado
            ? (color ?? Theme.of(context).colorScheme.primary)
            : null,
        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _filtroTipo = valor),
    );
  }

  Widget _buildChipFecha(String valor, String label) {
    final seleccionado = _filtroFecha == valor;
    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      selectedColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: seleccionado ? Theme.of(context).colorScheme.primary : null,
        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _filtroFecha = valor),
    );
  }

  Widget _buildFiltros() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Tipo:',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                _buildChipTipo('todos', 'Todos'),
                const SizedBox(width: 6),
                _buildChipTipo('compra', 'Compra'),
                const SizedBox(width: 6),
                _buildChipTipo('venta', 'Venta'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Fecha:',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                _buildChipFecha('todos', 'Todos'),
                const SizedBox(width: 6),
                _buildChipFecha('hoy', 'Hoy'),
                const SizedBox(width: 6),
                _buildChipFecha('semana', 'Esta semana'),
                const SizedBox(width: 6),
                _buildChipFecha('mes', 'Este mes'),
              ],
            ),
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        actions: [
          if (_exportando)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            FutureBuilder<List<Movimiento>>(
              future: _futureMovimientos,
              builder: (context, snapshot) {
                final filtrados =
                    _aplicarFiltros(snapshot.data ?? []);
                return IconButton(
                  icon: const Icon(Icons.ios_share_outlined),
                  tooltip: 'Exportar',
                  onPressed: snapshot.hasData
                      ? () => _mostrarOpcionesExport(filtrados)
                      : null,
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(
            child: FutureBuilder<List<Movimiento>>(
              future: _futureMovimientos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final todos = snapshot.data ?? [];
                final filtrados = _aplicarFiltros(todos);

                if (filtrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          todos.isEmpty
                              ? 'No hay movimientos registrados'
                              : 'Sin resultados para los filtros aplicados',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        if (todos.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() {
                              _filtroTipo = 'todos';
                              _filtroFecha = 'todos';
                            }),
                            child: const Text('Limpiar filtros'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.builder(
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final m = filtrados[index];
                      final esCompra = m.tipo == 'compra';
                      final color =
                          esCompra ? Colors.green : Colors.blue;
                      final icono = esCompra
                          ? Icons.arrow_downward
                          : Icons.arrow_upward;

                      return Dismissible(
                        key: ValueKey<String>(m.id!),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          await _eliminar(m);
                          return false;
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                color.withValues(alpha: 0.15),
                            child:
                                Icon(icono, color: color, size: 20),
                          ),
                          title: Text(
                            m.productoNombre ?? m.productoId,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${m.tipo.toUpperCase()} · ${m.cantidad % 1 == 0 ? m.cantidad.toInt() : m.cantidad} uds'
                            '${m.terceroNombre != null ? ' · ${m.terceroNombre}' : ''}',
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
                                ),
                              ),
                              if (m.fecha != null)
                                Text(
                                  '${m.fecha!.day}/${m.fecha!.month}/${m.fecha!.year}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const FormMovimientoScreen()),
          );
          _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
