import 'package:flutter/material.dart';
import '../models/movimiento_model.dart';
import '../services/api_service.dart';
import 'form_movimiento_screen.dart';

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  late Future<List<Movimiento>> _futureMovimientos;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _futureMovimientos = _api.getMovimientos();
    });
  }

  Future<void> _eliminar(String id) async {
    try {
      await _api.deleteMovimiento(id);
      _cargar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Movimiento eliminado y stock revertido'),
          backgroundColor: Colors.orange,
        ),
      );
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
            title: const Text('Revertir movimiento'),
            content: const Text(
                'El stock del producto será ajustado automáticamente. ¿Continuar?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Revertir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _irAFormulario() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FormMovimientoScreen()),
    );
    if (resultado == true) _cargar();
  }

  Color _colorTipo(String tipo) =>
      tipo == 'compra' ? Colors.green.shade700 : Colors.red.shade700;

  IconData _iconoTipo(String tipo) =>
      tipo == 'compra' ? Icons.arrow_downward : Icons.arrow_upward;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Movimiento>>(
        future: _futureMovimientos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final movimientos = snapshot.data ?? [];
          if (movimientos.isEmpty) {
            return const Center(child: Text('No hay movimientos registrados.'));
          }
          return ListView.builder(
            itemCount: movimientos.length,
            itemBuilder: (context, index) {
              final m = movimientos[index];
              final color = _colorTipo(m.tipo);
              return Dismissible(
                key: ValueKey(m.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmarEliminar(context),
                onDismissed: (_) => _eliminar(m.id!),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.orange,
                  child: const Icon(Icons.undo, color: Colors.white, size: 28),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(_iconoTipo(m.tipo), color: color, size: 20),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m.tipo.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            m.productoNombre ?? 'Producto #${m.productoId}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${m.terceroNombre ?? 'Tercero #${m.terceroId}'}  •  '
                      'Cant: ${m.cantidad}  •  '
                      'Total: \$${m.totalCalculado.toStringAsFixed(2)}',
                    ),
                    trailing: m.fecha != null
                        ? Text(
                            '${m.fecha!.day}/${m.fecha!.month}',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12),
                          )
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irAFormulario,
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Registrar'),
      ),
    );
  }
}
