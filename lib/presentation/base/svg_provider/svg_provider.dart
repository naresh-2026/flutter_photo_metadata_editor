import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

class SVGNotifier extends StateNotifier<List<String>> {
  late Box<String> _box;

  SVGNotifier() : super([]) {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _box = await Hive.openBox<String>('svgBox');
    _loadSVGThumbnails();
  }

  Future<void> _loadSVGThumbnails() async {
    final thumbnails = _box.values.toList();
    state = thumbnails;
  }

  Future<void> addSVG(String svgString) async {
    await _box.add(svgString);
    _loadSVGThumbnails();
  }

  Future<void> updateSvg(String oldSvg, String newSvg) async {
  int index = state.indexOf(oldSvg);
  if (index != -1) {
    print("updating the metadata");
    await _box.putAt(index, newSvg); // Save to Hive
    state = _box.values.toList();
    //await _loadSVGThumbnails(); // Reload UI
    }
    print("done");
  }
}

final svgProvider = StateNotifierProvider<SVGNotifier, List<String>>((ref) {
  return SVGNotifier();
});
