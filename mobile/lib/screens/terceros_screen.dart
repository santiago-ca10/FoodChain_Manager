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

  // Filtros
  String _busqueda = '';
  String? _tipoFiltro; // null = todos
  final _searchCtrl = TextEditingController();

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
      _tercerosFuture = _api.getTerceros();
    });
  }

  List<Tercero> _filtrar(List<Tercero> lista) {
    return lista.where((t) {
      final matchBusqueda = _busqueda.isEmpty ||
          t.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          (t.telefono?.toLowerCase().contains(_busqueda.toLowerCase()) ?? false);
      final matchTipo = _tipoFiltro == null || t.tipo == _tipoFiltro;
      return matchBusqueda && matchTipo;
    }).toList();
  }

  Future<void> _abrirFormulario({Tercero? tercero}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormTerceroScreen(tercero: tercero),
      ),
    );
    if (resultado == true) _cargar();
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
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o teléfono...',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),

          // ── Chips de tipo ──────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _chip('Todos', null),
                _chip('Clientes', 'cliente'),
                _chip('Proveedores', 'proveedor'),
                _chip('Ambos', 'ambos'),
              ],
            ),
          ),

          // ── Lista ──────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Tercero>>(
              future: _tercerosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final todos = snapshot.data ?? [];
                final terceros = _filtrar(todos);

                if (todos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No hay terceros registrados.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                if (terceros.isEmpty) {
                  return Center(
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
                              _tipoFiltro = null;
                            });
                          },
                          child: const Text('Limpiar filtros'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _cargar(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: terceros.length,
                    itemBuilder: (context, index) {
                      final t = terceros[index];
                      return Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child:
                              const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          await _eliminar(t);
                          return false;
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _colorTipo(t.tipo)
                                .withValues(alpha: 0.15),
                            child: Icon(_iconTipo(t.tipo),
                                color: _colorTipo(t.tipo), size: 20),
                          ),
                          title: Text(t.nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            [
                              _labelTipo(t.tipo),
                              if (t.telefono != null &&
                                  t.telefono!.isNotEmpty)
                                t.telefono!,
                            ].join(' · '),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Editar',
                            onPressed: () => _abrirFormulario(tercero: t),
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
    );
  }

  Widget _chip(String label, String? valor) {
    final seleccionado = _tipoFiltro == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: seleccionado,
        onSelected: (_) => setState(() => _tipoFiltro = valor),
      ),
    );
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'cliente':
        return Colors.blue;
      case 'proveedor':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _iconTipo(String tipo) {
    switch (tipo) {
      case 'proveedor':
        return Icons.local_shipping;
      case 'ambos':
        return Icons.people;
      default:
        return Icons.person;
    }
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'cliente':
        return 'Cliente';
      case 'proveedor':
        return 'Proveedor';
      default:
        return 'Ambos';
    }
  }
}
