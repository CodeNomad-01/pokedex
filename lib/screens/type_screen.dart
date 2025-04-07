import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final Map<String, Color> _typeColors = {
  'normal': Colors.brown,
  'fire': Colors.orange,
  'water': Colors.blue,
  'electric': Colors.amber,
  'grass': Colors.green,
  'ice': Colors.cyan,
  'fighting': Colors.red,
  'poison': Colors.purple,
  'ground': Colors.brown[300]!,
  'flying': Colors.indigo[200]!,
  'psychic': Colors.pink,
  'bug': Colors.lightGreen,
  'rock': Colors.grey,
  'ghost': Colors.indigo,
  'dragon': Colors.indigoAccent,
  'dark': Colors.black54,
  'steel': Colors.blueGrey,
  'fairy': Colors.pinkAccent,
};

class TypesScreen extends StatefulWidget {
  const TypesScreen({super.key});
  @override
  State<TypesScreen> createState() => _TypesScreenState();
}

class _TypesScreenState extends State<TypesScreen> {
  late Future<List<Map<String, dynamic>>> _typeEffectiveness;

  @override
  void initState() {
    super.initState();
    _typeEffectiveness = _fetchTypeEffectiveness();
  }

  Future<List<Map<String, dynamic>>> _fetchTypeEffectiveness() async {
    final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/type'));
    if (res.statusCode != 200) throw Exception('Failed to load types');
    final data = json.decode(res.body);
    final List results = data['results'];
    final list = <Map<String, dynamic>>[];
    for (var t in results) {
      final name = t['name'] as String;
      if (name == 'shadow' || name == 'unknown' || name == 'stellar') continue;
      final detailRes = await http.get(Uri.parse(t['url']));
      if (detailRes.statusCode != 200) continue;
      final detailData = json.decode(detailRes.body);
      final effectiveList =
          detailData['damage_relations']['double_damage_to'] as List;
      final effectiveMap = <String, double>{};
      for (var e in effectiveList) {
        final typeName = e['name'] as String;
        effectiveMap[typeName] = 2.0;
      }
      list.add({'type': name, 'effective': effectiveMap});
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 217, 173),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'TYPE EFFECTIVITY',
          style: GoogleFonts.pressStart2p(fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _typeEffectiveness,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final list = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final entry = list[index];
              final type = entry['type'] as String;
              final effective = entry['effective'] as Map<String, double>;
              final valid =
                  effective.entries
                      .where((e) => _typeColors.containsKey(e.key))
                      .toList();
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        type.toUpperCase(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 12,
                          color: _typeColors[type] ?? Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            valid.isEmpty
                                ? [
                                  Text(
                                    'NONE',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 8,
                                    ),
                                  ),
                                ]
                                : valid.map((e) {
                                  final color =
                                      _typeColors[e.key.toLowerCase()]!;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${e.key.toUpperCase()} (×${e.value.toInt()})',
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: 8,
                                      ),
                                    ),
                                  );
                                }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
