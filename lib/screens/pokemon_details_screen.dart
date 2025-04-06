import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pokemon_service.dart';

class PokemonDetailScreen extends StatelessWidget {
  final String url;
  const PokemonDetailScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFd8d8d8),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('DETALLE', style: GoogleFonts.pressStart2p(fontSize: 14)),
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
          final d = snap.data!;
          final id = d['id'];
          final name = d['name'].toString().toUpperCase();
          final img =
              d['sprites']['other']['official-artwork']['front_default'] ??
              d['sprites']['front_default'];
          final types =
              (d['types'] as List)
                  .map((e) => e['type']['name'] as String)
                  .toList();
          final height = d['height'];
          final weight = d['weight'];
          final abilities =
              (d['abilities'] as List)
                  .map((e) => e['ability']['name'] as String)
                  .toList();
          final stats =
              (d['stats'] as List)
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

          return SingleChildScrollView(
            child: Column(
              children: [
                section(
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '#$id',
                            style: GoogleFonts.pressStart2p(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: GoogleFonts.pressStart2p(fontSize: 16),
                          ),
                          const Spacer(),
                          Row(
                            children:
                                types
                                    .map(
                                      (t) => Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          t.toUpperCase(),
                                          style: GoogleFonts.pressStart2p(
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Image.network(
                        img,
                        height: 150,
                        width: 150,
                        filterQuality: FilterQuality.none,
                      ),
                    ],
                  ),
                ),
                section(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HEIGHT: $height',
                        style: GoogleFonts.pressStart2p(fontSize: 10),
                      ),
                      Text(
                        'WEIGHT: $weight',
                        style: GoogleFonts.pressStart2p(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                section(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        abilities
                            .map(
                              (a) => Text(
                                a.toUpperCase(),
                                style: GoogleFonts.pressStart2p(fontSize: 10),
                              ),
                            )
                            .toList(),
                  ),
                ),
                section(
                  Column(
                    children:
                        stats
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        s['name'] as String,
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: (s['value'] as int) / 100,
                                        color: Colors.red,
                                        backgroundColor: Colors.grey[300],
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${s['value']}',
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
