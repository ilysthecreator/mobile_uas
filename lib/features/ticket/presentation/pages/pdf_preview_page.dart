import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:project_mobile/features/ticket/data/models/ticket_model.dart';
import 'package:project_mobile/core/utils/pdf_generator.dart';
import 'package:project_mobile/core/theme/app_theme.dart';

class PdfPreviewPage extends StatelessWidget {
  final List<TicketModel> tickets;

  const PdfPreviewPage({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratinjau Laporan PDF'),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppTheme.primaryNavy),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0B1C30),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      body: PdfPreview(
        build: (format) => PdfGenerator.generatePdfBytes(tickets, format),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        pdfFileName: 'laporan_helpdesk_${DateTime.now().millisecondsSinceEpoch}.pdf',
        previewPageMargin: const EdgeInsets.all(16),
        loadingWidget: const Center(child: CircularProgressIndicator()),
        // Stylings for preview widget to match our theme
        pdfPreviewPageDecoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}
