import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/tercero_model.dart';
import 'form_tercero_screen.dart';

class TercerosScreen extends StatefulWidget {
  const TercerosScreen({super.key});

  @override
  State<TercerosScreen> createState() => _TercerosScreenState();
}

class _TercerosScreenState extends State<TercerosScreen> {
  final ApiService _api = ApiService();
  late Future<List<Tercero>> _tercerosFuture;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    final future = _api.getTerceros();
    setState(() => _tercerosFuture = future);
  }

  Future<void> _abrirFormulario() async {
    // Si el formulario devuelve true, recargamos la lista
    final creado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FormTerceroScreen()),
    );
    if (creado == true) _cargar();
  }

  Future<void> _eliminar(Tercero tercero) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar tercero?'),
        content: Text('Se eliminará "${tercero.nombre}" permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _api.eliminarTercero(tercero.id);
      _cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terceros')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Tercero>>(
        future: _tercerosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay terceros registrados.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tercero = snapshot.data![index];
              return Dismissible(
                // Swipe izquierda para eliminar
                key: Key(tercero.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  await _eliminar(tercero);
                  return false; // El _cargar() ya actualiza la lista
                },
                child: ListTile(
                  leading: Icon(
                    tercero.tipo == 'proveedor'
                        ? Icons.local_shipping
                        : Icons.person,
                  ),
                  title: Text(tercero.nombre),
                  subtitle: Text('Tipo: ${tercero.tipo}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
