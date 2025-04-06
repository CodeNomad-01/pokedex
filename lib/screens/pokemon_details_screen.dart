import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pokemon_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonDetailScreen extends StatelessWidget {
  final String url;
  const PokemonDetailScreen({super.key, required this.url});

  static const Map<String, Color> typeColors = {
    'normal': Colors.brown,
    'fire': Colors.orange,
    'water': Colors.blue,
    'electric': Colors.amber,
    'grass': Colors.green,
    'ice': Colors.cyan,
    'fighting': Colors.red,
    'poison': Colors.purple,
    'ground': Color(0xFFD7CCC8),
    'flying': Color(0xFF9FA8DA),
    'psychic': Colors.pink,
    'bug': Colors.lightGreen,
    'rock': Colors.grey,
    'ghost': Colors.indigo,
    'dragon': Colors.indigoAccent,
    'dark': Colors.black54,
    'steel': Colors.blueGrey,
    'fairy': Colors.pinkAccent,
  };

  Future<String?> _fetchFireRedDescription(int id) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id/'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final entries = data['flavor_text_entries'] as List;
      for (var entry in entries) {
        if (entry['version']['name'] == 'firered' &&
            entry['language']['name'] == 'en') {
          return (entry['flavor_text'] as String)
              .replaceAll('\n', ' ')
              .replaceAll('\f', ' ');
        }
      }
    }
    return null;
  }

  Future<Map<String, double>> _fetchDamageRelations(List<String> types) async {
    final Map<String, double> multipliers = {};

    for (final type in types) {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/type/$type'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final relations = data['damage_relations'];

        void applyMultiplier(String key, double multiplier) {
          for (var entry in relations[key]) {
            final name = entry['name'];
            multipliers[name] = (multipliers[name] ?? 1.0) * multiplier;
          }
        }

        applyMultiplier('double_damage_from', 2.0);
        applyMultiplier('half_damage_from', 0.5);
        applyMultiplier('no_damage_from', 0.0);
      }
    }

    return multipliers;
  }

  Future<Map<String, double>> _fetchOffensiveMultipliers(
    List<String> types,
  ) async {
    final Map<String, double> multipliers = {};

    for (final type in types) {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/type/$type'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final relations = data['damage_relations'];

        void applyMultiplier(String key, double multiplier) {
          for (var entry in relations[key]) {
            final name = entry['name'];
            multipliers[name] = (multipliers[name] ?? 1.0) * multiplier;
          }
        }

        applyMultiplier('double_damage_to', 2.0);
        applyMultiplier('half_damage_to', 0.5);
        applyMultiplier('no_damage_to', 0.0);
      }
    }

    return multipliers;
  }

  Future<String> _fetchEncounterArea(int id) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/$id/encounters'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        final firstLocation = data[0]['location_area']['name'];
        return firstLocation.toString().replaceAll('-', ' ').toUpperCase();
      }
    }
    return '???';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 217, 173),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('DETAIL', style: GoogleFonts.pressStart2p(fontSize: 14)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: PokemonService().fetchPokemonDetail(url),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return const Center(child: Text('Error'));
          }

          final data = snap.data!;
          final int id = data['id'];
          final String name = (data['name'] as String).toUpperCase();
          final String? img =
              data['sprites']['other']['official-artwork']['front_default'] ??
              data['sprites']['front_default'];
          final List<String> types =
              (data['types'] as List)
                  .map((e) => (e['type']['name'] as String))
                  .toList();
          final int height = data['height'];
          final int weight = data['weight'];
          final List<String> abilities =
              (data['abilities'] as List)
                  .map((e) => (e['ability']['name'] as String).toUpperCase())
                  .toList();
          final List<Map<String, dynamic>> stats =
              (data['stats'] as List)
                  .map(
                    (e) => {
                      'name': (e['stat']['name'] as String).toUpperCase(),
                      'value': e['base_stat'] as int,
                    },
                  )
                  .toList();

          Widget section(Widget child) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: child,
          );

          return FutureBuilder<String?>(
            future: _fetchFireRedDescription(id),
            builder: (context, descSnap) {
              final description = descSnap.data;

              return FutureBuilder<Map<String, double>>(
                future: _fetchDamageRelations(types),
                builder: (context, weakSnap) {
                  final weaknesses = weakSnap.data ?? {};

                  return FutureBuilder<Map<String, double>>(
                    future: _fetchOffensiveMultipliers(types),
                    builder: (context, strongSnap) {
                      final strengths = strongSnap.data ?? {};

                      return FutureBuilder<String>(
                        future: _fetchEncounterArea(id),
                        builder: (context, areaSnap) {
                          final area = areaSnap.data ?? '???';

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                section(
                                  Column(
                                    children: [
                                      Text(
                                        '#$id $name',
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (img != null)
                                        Image.network(
                                          img,
                                          height: 150,
                                          width: 150,
                                          filterQuality: FilterQuality.none,
                                        ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children:
                                            types.map((t) {
                                              final color =
                                                  typeColors[t.toLowerCase()] ??
                                                  Colors.grey;
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  t.toUpperCase(),
                                                  style:
                                                      GoogleFonts.pressStart2p(
                                                        fontSize: 8,
                                                      ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      if (description != null)
                                        Text(
                                          description,
                                          style: GoogleFonts.pressStart2p(
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'AREA: $area',
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                section(
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'HEIGHT: $height',
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        'WEIGHT: $weight',
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                section(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        abilities
                                            .map(
                                              (a) => Text(
                                                a,
                                                style: GoogleFonts.pressStart2p(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                                section(
                                  Column(
                                    children:
                                        stats.map((s) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    s['name'],
                                                    style:
                                                        GoogleFonts.pressStart2p(
                                                          fontSize: 8,
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child:
                                                      LinearProgressIndicator(
                                                        value:
                                                            (s['value']
                                                                as int) /
                                                            100,
                                                        color: Colors.red,
                                                        backgroundColor:
                                                            Colors.grey[300],
                                                        minHeight: 8,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${s['value']}',
                                                  style:
                                                      GoogleFonts.pressStart2p(
                                                        fontSize: 8,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                                if (weaknesses.isNotEmpty)
                                  section(
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'WEAK AGAINST:',
                                          style: GoogleFonts.pressStart2p(
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          children:
                                              weaknesses.entries
                                                  .where((e) => e.value > 1.0)
                                                  .map((entry) {
                                                    final color =
                                                        typeColors[entry.key
                                                            .toLowerCase()] ??
                                                        Colors.grey;
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        entry.key.toUpperCase(),
                                                        style:
                                                            GoogleFonts.pressStart2p(
                                                              fontSize: 8,
                                                            ),
                                                      ),
                                                    );
                                                  })
                                                  .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (strengths.isNotEmpty)
                                  section(
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'STRONG AGAINST:',
                                          style: GoogleFonts.pressStart2p(
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          children:
                                              strengths.entries
                                                  .where((e) => e.value > 1.0)
                                                  .map((entry) {
                                                    final color =
                                                        typeColors[entry.key
                                                            .toLowerCase()] ??
                                                        Colors.grey;
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        entry.key.toUpperCase(),
                                                        style:
                                                            GoogleFonts.pressStart2p(
                                                              fontSize: 8,
                                                            ),
                                                      ),
                                                    );
                                                  })
                                                  .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
