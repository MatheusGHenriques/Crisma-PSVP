import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import '/data/pdf.dart';
import '/main.dart';

class SchedulePage extends StatefulWidget {
  final Function(Pdf) onSendPdf;

  const SchedulePage({super.key, required this.onSendPdf});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Future<String?> _getPdf() async {
    Directory dir = await getApplicationDocumentsDirectory();
    if (pdfBox.isEmpty) {
      return null;
    }
    Pdf pdf = pdfBox.get("pdf");
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
      Pdf pdf = Pdf(title: 'Cronograma', type: 'Cronograma', base64String: base64String);
      widget.onSendPdf(pdf);
    }
  }

  void _checkToUpdatePdf() {
    ValueNotifier<bool> continueButtonEnabledNotifier = ValueNotifier(false);
    TextEditingController controller = TextEditingController();
    controller.addListener(() {
      if (controller.text == 'Atualizar PDF') {
        continueButtonEnabledNotifier.value = true;
      }
    });
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 5,
                children: [
                  const Text(
                    'Digite "Atualizar PDF" abaixo caso queira atualizar o Cronograma. Se nao, clique fora dessa caixa.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  TextField(controller: controller, textAlign: TextAlign.center, maxLength: 13),
                  ValueListenableBuilder(
                    valueListenable: continueButtonEnabledNotifier,
                    builder: (context, continueButtonEnabled, child) {
                      return FilledButton(
                        onPressed:
                            continueButtonEnabled
                                ? () {
                                  Navigator.pop(context);
                                  _pickAndStorePDF();
                                }
                                : null,
                        child: const Text("Atualizar Cronograma"),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updatedScheduleNotifier.value = false;
    });
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updatedScheduleNotifier.value = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              ValueListenableBuilder(
                valueListenable: pdfBox.listenable(keys: ['pdf']),
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
                          child: ValueListenableBuilder(
                            valueListenable: isDarkModeNotifier,
                            builder: (context, isDarkMode, child) {
                              return PDFView(
                                key: ValueKey(isDarkMode),
                                filePath: snapshot.data!,
                                nightMode: isDarkMode,
                              );
                            },
                          ),
                        );
                      } else {
                        return SizedBox(
                          height: constraints.maxHeight,
                          width: MediaQuery.of(context).size.width,
                          child: Align(alignment: Alignment.center, child: const Text("Sem Cronograma por enquanto")),
                        );
                      }
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: CustomThemes.mainColor(colorTheme),
                  onPressed: _checkToUpdatePdf,
                  child: const Icon(Icons.upload_rounded),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
