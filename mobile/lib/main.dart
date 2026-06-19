import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/movimientos_screen.dart';
import 'screens/productos_screen.dart';
import 'screens/terceros_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/sync_service.dart';
import 'services/local_database.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase().db;
  runApp(const FoodChainApp());
}

class FoodChainApp extends StatelessWidget {
  const FoodChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodChain Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ── Splash ─────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarAuth();
  }

  Future<void> _verificarAuth() async {
    final autenticado = await AuthService.estaAutenticado();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => autenticado ? const MainScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.local_shipping_outlined,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// ── MainScreen ─────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _online = true;
  int _pendientes = 0;
  int _stockBajo = 0;

  final _sync = SyncService();
  final _local = LocalDatabase();
  final _api = ApiService();

  final List<Widget> _screens = const [
    DashboardScreen(),
    MovimientosScreen(),
    ProductosScreen(),
    TercerosScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initConectividad();
    _cargarStockBajo();
  }

  void _initConectividad() {
    _sync.hayConexion().then((online) async {
      if (online) await _sync.sincronizarPendientes();
      final p = await _local.countPendientes();
      if (mounted) setState(() { _online = online; _pendientes = p; });
    });

    _sync.conectividadStream.listen((online) async {
      if (online) {
        await _sync.sincronizarPendientes();
        _cargarStockBajo(); // refresca badge tras sincronizar
      }
      final p = await _local.countPendientes();
      if (mounted) setState(() { _online = online; _pendientes = p; });
    });
  }

  Future<void> _cargarStockBajo() async {
    try {
      final productos = await _api.getProductos();
      final bajo = productos.where((p) => p.stock < 10).length;
      if (mounted) setState(() => _stockBajo = bajo);
    } catch (_) {}
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que querés salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await AuthService.cerrarSesion();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!_online)
            Material(
              color: Colors.orange.shade700,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4,
                  bottom: 6,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _pendientes > 0
                            ? 'Sin conexión · $_pendientes operación${_pendientes > 1 ? 'es' : ''} pendiente${_pendientes > 1 ? 's' : ''}'
                            : 'Sin conexión · Mostrando datos locales',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          // Al navegar a Productos, refrescar el badge
          if (i == 2) _cargarStockBajo();
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Movimientos',
          ),
          NavigationDestination(
            icon: _stockBajo > 0
                ? Badge(
                    label: Text('$_stockBajo'),
                    child: const Icon(Icons.inventory_2_outlined),
                  )
                : const Icon(Icons.inventory_2_outlined),
            selectedIcon: _stockBajo > 0
                ? Badge(
                    label: Text('$_stockBajo'),
                    child: const Icon(Icons.inventory_2),
                  )
                : const Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Terceros',
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<String?>(
          future: AuthService.getNombre(),
          builder: (context, snapshot) {
            final nombre = snapshot.data ?? '';
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        child: Text(
                          nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      FutureBuilder<String?>(
                        future: AuthService.getEmail(),
                        builder: (_, snap) => Text(
                          snap.data ?? '',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ),
                      if (!_online) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Offline · $_pendientes pendiente${_pendientes != 1 ? 's' : ''}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_stockBajo > 0)
                  ListTile(
                    leading: const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange),
                    title: Text(
                        '$_stockBajo producto${_stockBajo != 1 ? 's' : ''} con stock bajo'),
                    subtitle: const Text('Revisá la sección Productos'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    },
                  ),
                if (_pendientes > 0)
                  ListTile(
                    leading: const Icon(Icons.sync, color: Colors.orange),
                    title: Text(
                        '$_pendientes pendiente${_pendientes != 1 ? 's' : ''} por sincronizar'),
                    subtitle:
                        const Text('Se sincronizará al recuperar conexión'),
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar sesión',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
