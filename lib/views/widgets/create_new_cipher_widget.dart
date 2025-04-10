import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '/data/custom_themes.dart';
import '/main.dart';
import '/data/pdf.dart';

class CreateNewCipherWidget extends StatefulWidget {
  final Function(Pdf) onSendPdf;

  const CreateNewCipherWidget({super.key, required this.onSendPdf});

  @override
  State<CreateNewCipherWidget> createState() => _CreateNewCipherWidgetState();
}

class _CreateNewCipherWidgetState extends State<CreateNewCipherWidget> {
  final TextEditingController _cipherTitleController = TextEditingController();
  bool _hasTitle = false;
  bool _hasSelectedPdf = false;
  bool _isPrayer = false;
  late Pdf createdPdf;

  Future<void> _pickAndStorePDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);
      createdPdf = Pdf(title: '', type: '', base64String: base64String);
      setState(() {
        _hasSelectedPdf = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _cipherTitleController.addListener(() {
      setState(() {
        _hasTitle = _cipherTitleController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _cipherTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Nova Cifra", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              TextField(
                controller: _cipherTitleController,
                maxLines: 1,
                maxLength: 100,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "Título da Cifra",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: !_isPrayer ? Colors.white : CustomThemes.mainColor(colorTheme),
                      backgroundColor: !_isPrayer ? CustomThemes.mainColor(colorTheme) : null,
                      side: BorderSide(color: CustomThemes.mainColor(colorTheme), width: 2.0),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPrayer = false;
                      });
                    },
                    child: Text("Animação"),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isPrayer ? Colors.white : CustomThemes.mainColor(colorTheme),
                      backgroundColor: _isPrayer ? CustomThemes.mainColor(colorTheme) : null,
                      side: BorderSide(color: CustomThemes.mainColor(colorTheme), width: 2.0),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPrayer = true;
                      });
                    },
                    child: Text("Oração"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FilledButton(onPressed: _pickAndStorePDF, child: const Text("Selecionar PDF")),
              const SizedBox(height: 10),
              FilledButton(
                onPressed:
                    _hasTitle && _hasSelectedPdf
                        ? () {
                          createdPdf.title = _cipherTitleController.text;
                          createdPdf.type = _isPrayer ? 'Oração' : 'Animação';
                          widget.onSendPdf(createdPdf);
                          Navigator.pop(context);
                        }
                        : null,
                child: const Text("Criar Cifra"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
