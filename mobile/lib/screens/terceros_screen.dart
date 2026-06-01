import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/tercero_model.dart';

class TercerosScreen extends StatefulWidget {
  @override
  _TercerosScreenState createState() => _TercerosScreenState();
}

class _TercerosScreenState extends State<TercerosScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Tercero>> tercerosFuture;

  @override
  void initState() {
    super.initState();
    tercerosFuture = apiService.getTerceros(); // Llamamos al backend al iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Terceros (Clientes/Prov)')),
      body: FutureBuilder<List<Tercero>>(
        future: tercerosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Cargando...
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay terceros registrados.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tercero = snapshot.data![index];
              return ListTile(
                leading: Icon(tercero.tipo == 'proveedor' 
                    ? Icons.local_shipping 
                    : Icons.person),
                title: Text(tercero.nombre),
                subtitle: Text('Tipo: ${tercero.tipo}'),
                trailing: Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}