import 'dart:convert';
import 'dart:io';

import 'package:crisma/data/pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

class SchedulePage extends StatefulWidget {
  final Function(Pdf) onSendPdf;

  const SchedulePage({super.key, required this.onSendPdf});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final Box _pdfBox = Hive.box("pdfBox");

  Future<String> _getPdf() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Pdf pdf = _pdfBox.get("pdf");
    List<int> fileBytes = base64Decode(pdf.base64String);
    String pdfPath = "${dir.path}/cronograma_retiro_app.pdf";
    File pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(fileBytes);
    return pdfPath;
  }

  Future<void> _pickAndStorePDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);
      await _pdfBox.put("pdf", Pdf(base64String: base64String));
      widget.onSendPdf(_pdfBox.values.single);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _pdfBox.listenable(),
                    builder: (context, box, child) {
                      return FutureBuilder<String?>(
                        future: _getPdf(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasData && snapshot.data != null) {
                            return SizedBox(
                              height: constraints.maxHeight,
                              width: MediaQuery.of(context).size.width,
                              child: PDFView(filePath: snapshot.data!),
                            );
                          } else {
                            return SizedBox(
                              height: constraints.maxHeight,
                              width: MediaQuery.of(context).size.width,
                              child: Align(alignment: Alignment.center, child: Text("Nenhum PDF por enquanto")),
                            );
                          }
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: FloatingActionButton(
                      backgroundColor: Colors.redAccent,
                      onPressed: _pickAndStorePDF,
                      child: Icon(Icons.upload_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
