import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/note.dart';

class ExportService {
  Future<void> exportNoteToPdf(Note note) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                note.title.isEmpty ? 'Untitled' : note.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Last Updated: ${note.updatedAt.toString()}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Note content will be expanded here (Delta to PDF conversion planned)',
                style: const pw.TextStyle(fontSize: 12),
              ),
              if (note.tags.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text('Tags: ${note.tags.join(", ")}'),
              ],
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
