# FoodChain Manager — Mobile

Aplicación Flutter para gestión de inventarios, compras y ventas. Consume la API REST del backend Node.js.

## Stack

- **Framework:** Flutter (multi-plataforma: Android, iOS, Web, Windows)
- **HTTP:** paquete `http`
- **Estado:** `StatefulWidget` + `FutureBuilder`
- **Mínimo SDK Android:** definido en `build.gradle`

## Estructura

```
mobile/lib/
├── config/
│   └── app_config.dart         # URL base de la API (centralizada)
├── models/
│   ├── tercero_model.dart
│   ├── producto_model.dart
│   └── movimiento_model.dart
├── screens/
│   ├── terceros_screen.dart    # Lista con swipe para eliminar
│   ├── form_tercero_screen.dart
│   ├── productos_screen.dart
│   ├── form_producto_screen.dart
│   ├── movimientos_screen.dart
│   └── form_movimiento_screen.dart
├── services/
│   └── api_service.dart        # Todos los métodos HTTP centralizados
└── main.dart                   # NavigationBar con IndexedStack
```

## Configuración

Editar `lib/config/app_config.dart` con la IP del servidor:

```dart
class AppConfig {
  static const String baseUrl = 'http://192.168.x.x:3000/api';
}
```

> En desarrollo web (`flutter run -d chrome`) usar `http://localhost:3000/api`.

## Instalación

```bash
cd mobile
flutter pub get
flutter run
```

## Modelos

Los modelos mapean los campos del backend (snake_case) a nombres Dart (camelCase):

| Backend            | Flutter (Producto) |
|--------------------|--------------------|
| `unidad_medida`    | `unidad`           |
| `precio_sugerido`  | `precio`           |
| `stock_actual`     | `stock`            |

| Backend            | Flutter (Movimiento) |
|--------------------|----------------------|
| `precio_unitario`  | `precioUnitario`     |

Todos los `id` son `String` (UUID v4 generado por el backend).

## Pantallas

### Terceros
- Lista todos los terceros (clientes, proveedores, ambos)
- Swipe izquierda para eliminar con confirmación
- FAB para crear nuevo tercero
- Campos: nombre, tipo, teléfono, dirección

### Productos
- Lista con stock y precio visibles
- Swipe para eliminar, tap para editar
- FAB para crear nuevo producto
- Campos: nombre, categoría, unidad de medida, precio sugerido, stock inicial

### Movimientos
- Historial ordenado por fecha (más reciente primero)
- Badge de color por tipo: verde = compra, rojo = venta
- Swipe para eliminar (revierte stock en el backend)
- Botón "Registrar" abre formulario de compra/venta

### Formulario de movimiento
- Selector visual compra/venta (cambia color del formulario)
- Dropdown de productos (muestra stock disponible)
- Dropdown de terceros
- Precio se pre-llena con el precio sugerido del producto
- Validación de stock insuficiente en ventas en tiempo real
- Resumen de total animado antes de confirmar

## Patrones establecidos

- `ApiService` centraliza todos los métodos HTTP; las pantallas no llaman a `http` directamente.
- `FutureBuilder` para carga asíncrona con estados de loading/error/data.
- `Dismissible` con `confirmDismiss` para eliminar con diálogo de confirmación.
- `IndexedStack` en `MainScreen` preserva el estado de cada tab al navegar.
- `Navigator.pop(context, true)` en formularios para indicar éxito y disparar recarga en la pantalla anterior.

## API Service — métodos disponibles

```dart
// Terceros
getTerceros()
crearTercero(Map datos)
eliminarTercero(String id)

// Productos
getProductos()
createProducto(Producto p)
updateProducto(String id, Producto p)
deleteProducto(String id)

// Movimientos
getMovimientos()
registrarMovimiento(Movimiento m)
deleteMovimiento(String id)
```