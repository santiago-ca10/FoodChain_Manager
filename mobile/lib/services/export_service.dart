import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/movimiento_model.dart';

class ExportService {
  // ── helpers ───────────────────────────────────────────────

  String _formatFecha(DateTime? f) {
    if (f == null) return '-';
    return '${f.day.toString().padLeft(2, '0')}/'
        '${f.month.toString().padLeft(2, '0')}/'
        '${f.year}';
  }

  String _formatMonto(double v) => '\$${v.toStringAsFixed(2)}';

  Future<Directory> get _dir async => getApplicationDocumentsDirectory();

  // ── PDF ───────────────────────────────────────────────────

  Future<void> exportarPDF(List<Movimiento> movimientos,
      {String titulo = 'Movimientos'}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'FoodChain Manager',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
            pw.Text(
              titulo,
              style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700),
            ),
            pw.Text(
              'Generado: ${_formatFecha(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.green800),
            pw.SizedBox(height: 4),
          ],
        ),
        build: (_) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(0.8),
              5: const pw.FlexColumnWidth(1.2),
              6: const pw.FlexColumnWidth(1.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green800),
                children: [
                  'Fecha', 'Tipo', 'Producto', 'Tercero',
                  'Cant.', 'P. Unit.', 'Total',
                ].map((h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6, vertical: 5),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                )).toList(),
              ),
              ...List.generate(movimientos.length, (i) {
                final m = movimientos[i];
                final bg = i.isEven ? PdfColors.white : PdfColors.grey50;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bg),
                  children: [
                    _celda(_formatFecha(m.fecha)),
                    _celdaTipo(m.tipo),
                    _celda(m.productoNombre ?? '-'),
                    _celda(m.terceroNombre ?? '-'),
                    _celda('${m.cantidad % 1 == 0 ? m.cantidad.toInt() : m.cantidad}'),
                    _celda(_formatMonto(m.precioUnitario)),
                    _celda(_formatMonto(m.totalCalculado)),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 12),
          _resumenPDF(movimientos),
        ],
      ),
    );

    final bytes = await pdf.save();
    final file = File(
        '${(await _dir).path}/movimientos_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: titulo,
    );
  }

  pw.Widget _celda(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
      );

  pw.Widget _celdaTipo(String tipo) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(
          tipo[0].toUpperCase() + tipo.substring(1),
          style: pw.TextStyle(
            fontSize: 8,
            color: tipo == 'compra' ? PdfColors.green700 : PdfColors.red700,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );

  pw.Widget _resumenPDF(List<Movimiento> movimientos) {
    final compras = movimientos.where((m) => m.tipo == 'compra');
    final ventas = movimientos.where((m) => m.tipo == 'venta');
    final totalCompras = compras.fold(0.0, (s, m) => s + m.totalCalculado);
    final totalVentas = ventas.fold(0.0, (s, m) => s + m.totalCalculado);

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _resumenItem('Total compras', _formatMonto(totalCompras), PdfColors.green700),
          _resumenItem('Total ventas', _formatMonto(totalVentas), PdfColors.red700),
          _resumenItem(
            'Ganancia',
            _formatMonto(totalVentas - totalCompras),
            totalVentas >= totalCompras ? PdfColors.green800 : PdfColors.red800,
          ),
          _resumenItem('Registros', '${movimientos.length}', PdfColors.grey700),
        ],
      ),
    );
  }

  pw.Widget _resumenItem(String label, String valor, PdfColor color) =>
      pw.Column(
        children: [
          pw.Text(label,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          pw.SizedBox(height: 2),
          pw.Text(valor,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: color)),
        ],
      );

  // ── Excel ─────────────────────────────────────────────────

  Future<void> exportarExcel(List<Movimiento> movimientos,
      {String titulo = 'Movimientos'}) async {
    final excel = Excel.createExcel();
    final sheet = excel['Movimientos'];

    final headers = [
      'Fecha', 'Tipo', 'Producto', 'Tercero',
      'Cantidad', 'Precio Unitario', 'Total',
    ];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1B5E20'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
    }

    for (var i = 0; i < movimientos.length; i++) {
      final m = movimientos[i];
      final row = i + 1;
      final valores = [
        _formatFecha(m.fecha),
        m.tipo[0].toUpperCase() + m.tipo.substring(1),
        m.productoNombre ?? '-',
        m.terceroNombre ?? '-',
        m.cantidad,
        m.precioUnitario,
        m.totalCalculado,
      ];
      for (var j = 0; j < valores.length; j++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row));
        final v = valores[j];
        if (v is double) {
          cell.value = DoubleCellValue(v);
        } else {
          cell.value = TextCellValue(v.toString());
        }
      }
    }

    sheet.setColumnWidth(0, 14);
    sheet.setColumnWidth(1, 12);
    sheet.setColumnWidth(2, 22);
    sheet.setColumnWidth(3, 22);
    sheet.setColumnWidth(4, 10);
    sheet.setColumnWidth(5, 14);
    sheet.setColumnWidth(6, 14);

    final resumenRow = movimientos.length + 2;
    final totalCompras = movimientos
        .where((m) => m.tipo == 'compra')
        .fold(0.0, (s, m) => s + m.totalCalculado);
    final totalVentas = movimientos
        .where((m) => m.tipo == 'venta')
        .fold(0.0, (s, m) => s + m.totalCalculado);

    void celdaResumen(int col, dynamic val) {
      final c = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: resumenRow));
      c.value = val is double
          ? DoubleCellValue(val)
          : TextCellValue(val.toString());
      c.cellStyle = CellStyle(bold: true);
    }

    celdaResumen(0, 'RESUMEN');
    celdaResumen(1, 'Compras:');
    celdaResumen(2, totalCompras);
    celdaResumen(3, 'Ventas:');
    celdaResumen(4, totalVentas);
    celdaResumen(5, 'Ganancia:');
    celdaResumen(6, totalVentas - totalCompras);

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Error al generar Excel');
    final file = File(
        '${(await _dir).path}/movimientos_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path,
          mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
      subject: titulo,
    );
  }

  // ── Imagen PNG ────────────────────────────────────────────

  Future<void> exportarImagen(List<Movimiento> movimientos,
      {String titulo = 'Movimientos'}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('FoodChain Manager',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800)),
            pw.Text(titulo,
                style: const pw.TextStyle(
                    fontSize: 12, color: PdfColors.grey700)),
            pw.Text('Generado: ${_formatFecha(DateTime.now())}',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey)),
            pw.SizedBox(height: 6),
            pw.Divider(color: PdfColors.green800),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(0.8),
                5: const pw.FlexColumnWidth(1.2),
                6: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.green800),
                  children: [
                    'Fecha', 'Tipo', 'Producto', 'Tercero',
                    'Cant.', 'P.Unit.', 'Total',
                  ].map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8)),
                  )).toList(),
                ),
                ...List.generate(movimientos.take(30).length, (i) {
                  final m = movimientos[i];
                  final bg = i.isEven ? PdfColors.white : PdfColors.grey50;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bg),
                    children: [
                      _celda(_formatFecha(m.fecha)),
                      _celdaTipo(m.tipo),
                      _celda(m.productoNombre ?? '-'),
                      _celda(m.terceroNombre ?? '-'),
                      _celda('${m.cantidad % 1 == 0 ? m.cantidad.toInt() : m.cantidad}'),
                      _celda(_formatMonto(m.precioUnitario)),
                      _celda(_formatMonto(m.totalCalculado)),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 10),
            _resumenPDF(movimientos),
          ],
        ),
      ),
    );

    final pdfBytes = await pdf.save();

    // Rasterizar primera página como PNG — Printing.raster devuelve Stream
    final page = await Printing.raster(pdfBytes, dpi: 150).first;
    final imgBytes = await page.toPng();

    final file = File(
        '${(await _dir).path}/movimientos_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imgBytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      subject: titulo,
    );
  }
}
