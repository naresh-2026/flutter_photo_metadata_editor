import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';

class EditorScreen extends StatefulWidget {
  final String svgString;
  final Map<String, String> metadata; // Receive metadata
  final Function(String) onSave; // Callback function to save edited SVG

  const EditorScreen({super.key, required this.svgString, required this.metadata,required this.onSave});

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late XmlDocument svgDocument;
  late String updatedSvgString;
  Map<String, String> editableMetadata = {};
    Map<String, TextEditingController> textControllers = {}; // Store controllers

  @override
  void initState() {
    super.initState();
    _parseSvg();
    _initializeControllers();
  }

  void _parseSvg() {
    svgDocument = XmlDocument.parse(widget.svgString);
    updatedSvgString = widget.svgString;
    editableMetadata = Map.from(widget.metadata); // Make a copy for editing

    // final rootElement = svgDocument.rootElement;
    // final attributes = rootElement.attributes;

    // for (var attr in attributes) {
    //   if (attr.name.toString().startsWith("custom_")) {
    //     editableMetadata[attr.name.toString()] = attr.value;
    //   }
    // }
  }
  
  void _initializeControllers() {
    for (var entry in editableMetadata.entries) {
      textControllers[entry.key] = TextEditingController(text: entry.value);
    }
  }
  void _updateMetadata(String key, String value) {
    setState(() {
      editableMetadata[key] = value;

      // Update the SVG XML
    //   final rootElement = svgDocument.rootElement;
    //   rootElement.setAttribute(key, value);
    // Update the XML document with new values
      for (var element in svgDocument.findAllElements('path')) {
        for (var attribute in element.attributes) {
          if (attribute.name.toString() == "custom_$key") {
            element.setAttribute("custom_$key", value);
          }
        }
      }
      updatedSvgString = svgDocument.toXmlString(pretty: true);
    });
  }

  @override
  void dispose() {
    // Dispose of all controllers to prevent memory leaks
    for (var controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

//   void _saveSvg() {
//     widget.onSave(updatedSvgString);
//     Navigator.pop(context); // Go back after saving
//   }
   void _saveSvg() async {
    await Future.delayed(Duration(milliseconds: 100)); // Ensure UI update
    widget.onSave(updatedSvgString);
    if (mounted) {
      Navigator.pop(context, updatedSvgString); // Close only after sending data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit SVG Metadata")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: SvgPicture.string(updatedSvgString), // SVG Updates Dynamically
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
                    textDirection: TextDirection.ltr, // Force Left-to-Right
                    onChanged: (newValue) {
                      _updateMetadata(entry.key, newValue);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: _saveSvg,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set background color to blue
              ),
            child: const Text("Save"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
