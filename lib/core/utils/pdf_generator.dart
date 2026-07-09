import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:project_mobile/features/ticket/data/models/ticket_model.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<Uint8List> generatePdfBytes(List<TicketModel> tickets, PdfPageFormat format) async {
    final pdf = pw.Document();

    // Calculate statistics
    final total = tickets.length;
    final open = tickets.where((t) => t.status == 'Open').length;
    final assigned = tickets.where((t) => t.status == 'Assigned').length;
    final progress = tickets.where((t) => t.status == 'In Progress').length;
    final closed = tickets.where((t) => t.status == 'Closed').length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Title Header (Black & White Theme)
            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1.5)),
              ),
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('HELPDESK CENTRAL',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.black)),
                      pw.SizedBox(height: 2),
                      pw.Text('System Tickets & Performance Report',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ),
                  pw.Text(
                    'Exported: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Statistics Grid Row (Black & White style)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBox('Total Tickets', total.toString()),
                _buildStatBox('Open', open.toString()),
                _buildStatBox('Assigned', assigned.toString()),
                _buildStatBox('In Progress', progress.toString()),
                _buildStatBox('Closed', closed.toString()),
              ],
            ),
            pw.SizedBox(height: 24),

            // Section Title
            pw.Text('ALL SYSTEM TICKETS',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black)),
            pw.SizedBox(height: 8),

            // Tickets Table (Black & White Style)
            pw.TableHelper.fromTextArray(
              headers: ['Ticket ID', 'Title', 'Creator Name', 'Category', 'Priority', 'Status'],
              data: tickets.map((t) {
                return [
                  t.id,
                  t.title.length > 25 ? '${t.title.substring(0, 22)}...' : t.title,
                  t.creatorName,
                  t.category,
                  t.priority,
                  t.status,
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              cellStyle: const pw.TextStyle(fontSize: 8, color: PdfColors.black),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                0: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> generateAndPrintReport(List<TicketModel> tickets) async {
    // Save and layout PDF using native printing dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => generatePdfBytes(tickets, format),
      name: 'helpdesk_system_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildStatBox(String title, String value) {
    return pw.Container(
      width: 95,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        color: PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title.toUpperCase(),
              style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800)),
          pw.SizedBox(height: 6),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black)),
        ],
      ),
    );
  }
}
