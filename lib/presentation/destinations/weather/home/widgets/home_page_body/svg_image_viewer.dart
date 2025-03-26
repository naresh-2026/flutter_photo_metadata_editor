import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'editor_screen.dart'; // Import the editor screen
import 'package:xml/xml.dart';

class ImageViewer extends StatelessWidget {
  final String svgString;

  const ImageViewer({super.key, required this.svgString});

  @override
  Widget build(BuildContext context) {
    final metadata = extractMetadata(svgString); // Extract custom metadata

    return Scaffold(
      appBar: AppBar(
        title: const Text("SVG Viewer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedSvg = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditorScreen(svgString: svgString,metadata:metadata,
                  onSave: (modifiedSvg) {
                      Navigator.pop(context, modifiedSvg); // Return the modified SVG
                    },
                  ),
                ),
              );
              if (updatedSvg != null) {
                //onUpdateSvg(updatedSvg);
                print("successfully returned");
                //Navigator.pop(context, updatedSvg);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // SVG Image
          Center(
            child: SvgPicture.string(svgString),
          ),

          // Bottom Sheet for Metadata
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
                ),
                child: ListView(
                  controller: scrollController,
                  children: metadata.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key,style: TextStyle(color: Colors.black26), ),
                      subtitle: Text(entry.value,style: TextStyle(color: Colors.black), ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

   
   Map<String, String> extractMetadata(String svgString) {
  final document = XmlDocument.parse(svgString);
  final renderingMetadata = <String, String>{};

  for (var element in document.findAllElements('path')) {
    for (var attribute in element.attributes) {
      final name = attribute.name.toString();

      // Only consider attributes that start with "custom_" and affect rendering
      if (name.startsWith('custom_')) {
        final key = name.replaceFirst('custom_', '');
        if (_isRenderingAttribute(key)) {
          renderingMetadata[key] = attribute.value;
        }
      }
    }
  }

  return renderingMetadata;
}

/// Determines whether an attribute affects the image rendering.
bool _isRenderingAttribute(String attribute) {
  final renderingAttributes = {
    'fill', 'stroke', 'stroke-width', 'opacity', 'transform',
    'scale', 'rotate', 'translate', 'skewX', 'skewY'
  };

  return renderingAttributes.contains(attribute);
}

  // Extracts metadata attributes starting with 'custom_'
//   Map<String, String> extractMetadata(String svg) {
//     final RegExp regex = RegExp(r'custom_([\w-]+)="([^"]+)"');
//     final matches = regex.allMatches(svg);
//     return {for (var match in matches) match.group(1)!: match.group(2)!};
//   }
}
