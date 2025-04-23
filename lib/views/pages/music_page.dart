import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '/data/notifiers.dart';
import '/views/widgets/create_new_cipher_widget.dart';
import '/data/pdf.dart';
import '/data/custom_themes.dart';
import '/main.dart';

class MusicPage extends StatefulWidget {
  final Function(Pdf) onSendPdf;

  const MusicPage({super.key, required this.onSendPdf});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newCiphersNotifier.value = 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Set<Pdf> ciphersSet = {};
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              SizedBox(
                height: constraints.maxHeight,
                width: MediaQuery.of(context).size.width,
                child: ValueListenableBuilder(
                  valueListenable: pdfBox.listenable(),
                  builder: (context, value, child) {
                    for (dynamic key in pdfBox.keys) {
                      if (key != 'pdf') ciphersSet.add(pdfBox.get(key));
                    }

                    List<Pdf> prayers = [], joyful = [], ciphers = ciphersSet.toList();
                    ciphers.sort((a, b) => a.title.compareTo(b.title));

                    for (Pdf pdf in ciphers) {
                      if (pdf.type == "Oração") {
                        prayers.add(pdf);
                      } else if (pdf.type == "Animação") {
                        joyful.add(pdf);
                      }
                    }

                    List<Map<String, List<Pdf>>> ciphersMenu = [
                      {'Animação (${joyful.length})': joyful},
                      {'Oração (${prayers.length})': prayers},
                    ];
                    return ListView(
                      children:
                          ciphersMenu.map((map) {
                            String title = map.keys.first;
                            List<Pdf> items = map[title]!;
                            return ExpansionTile(
                              initiallyExpanded: true,
                              title: Text(title),
                              shape: Border.all(color: Colors.transparent),
                              children: [
                                Wrap(
                                  spacing: 10,
                                  children: List.generate(items.length, (index) {
                                    return FilledButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              child: PDFView(
                                                nightMode: isDarkModeNotifier.value,
                                                pdfData: base64Decode(items.elementAt(index).base64String),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Text(items.elementAt(index).title),
                                    );
                                  }),
                                ),
                              ],
                            );
                          }).toList(),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 5,
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: CustomThemes.mainColor(colorTheme),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CreateNewCipherWidget(onSendPdf: widget.onSendPdf),
                    );
                  },
                  child: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
