import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';

class EditorScreen extends StatefulWidget {
  final String svgString;
  final Map<String, String> metadata;
  final Function(String) onSave;

  const EditorScreen({
    super.key,
    required this.svgString,
    required this.metadata,
    required this.onSave,
  });

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late XmlDocument svgDocument;
  late String updatedSvgString;
  Map<String, String> editableMetadata = {};
  Map<String, TextEditingController> textControllers = {};

  @override
  void initState() {
    super.initState();
    _parseSvg();
    _initializeControllers();
  }

  void _parseSvg() {
    svgDocument = XmlDocument.parse(widget.svgString);
    updatedSvgString = widget.svgString;
    editableMetadata = Map.from(widget.metadata);
  }

  void _initializeControllers() {
    for (var entry in editableMetadata.entries) {
      textControllers[entry.key] = TextEditingController(text: entry.value);
    }
  }

  void _updateMetadata(String key, String value) {
    setState(() {
      editableMetadata[key] = value;

      for (var element in svgDocument.findAllElements('path')) {
        if (element.getAttribute(key) != null) {
          element.setAttribute(key, value);
        }
      }

      updatedSvgString = svgDocument.toXmlString(pretty: true);
      print("String$updatedSvgString");
    });
  }
void _showAddMetadataDialog() {
  final keyController = TextEditingController();
  final valueController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Metadata'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: keyController,
            decoration: const InputDecoration(labelText: 'Key (without custom_)'),
          ),
          TextField(
            controller: valueController,
            decoration: const InputDecoration(labelText: 'Value'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final rawKey = keyController.text.trim();
            final value = valueController.text.trim();

            if (rawKey.isNotEmpty && value.isNotEmpty) {
              final key = "custom_$rawKey";

              //final value1 = value.replaceAll('"', "'"); // Prevent XML-breaking double quotes
              textControllers[key] = TextEditingController(text: value);
              setState(() {
                editableMetadata[key] = value;

                for (var element in svgDocument.findAllElements('path')) {
                  element.setAttribute(key, value); // Always set (adds new or updates existing)
                }

                updatedSvgString = svgDocument.toXmlString(pretty: true);
                print("printing");
                debugPrint(updatedSvgString, wrapWidth: 1024);
              });

              //print("Updated SVG:\n$updatedSvgString"); // Debug log
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}


  void _saveSvg() async {
    // print("nefore printing");
    //             debugPrint(updatedSvgString, wrapWidth: 1024);
    await Future.delayed(const Duration(milliseconds: 100));
    widget.onSave(updatedSvgString);
    if (mounted) {
      Navigator.pop(context, updatedSvgString);
    }
  }

  @override
  void dispose() {
    for (var controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit SVG Metadata")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: SvgPicture.string(updatedSvgString),
          ),
          Expanded(
            flex: 2,
            child: ListView(
              children: editableMetadata.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key, style: const TextStyle(color: Colors.blue)),
                  subtitle: TextField(
                    controller: textControllers[entry.key],
                    style: const TextStyle(color: Colors.green),
                    textDirection: TextDirection.ltr,
                    onChanged: (newValue) {
                      _updateMetadata(entry.key, newValue);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showAddMetadataDialog,
            icon: const Icon(Icons.add),
            label: const Text("Add Metadata"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveSvg,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Save"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
