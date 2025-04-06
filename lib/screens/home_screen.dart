import 'package:flutter/material.dart';
import '../services/pokemon_service.dart';
import '../screens/pokemon_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = PokemonService();
  late Future<List<dynamic>> _list;

  @override
  void initState() {
    super.initState();
    _list = _service.fetchPokemonsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex'), backgroundColor: Colors.red),
      body: FutureBuilder<List<dynamic>>(
        future: _list,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          final list = snap.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final p = list[i];
              final name = p['name'];
              final url = p['url'];
              final id = url.split('/')[url.split('/').length - 2];
              final img =
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
              return GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PokemonDetailScreen(url: url),
                      ),
                    ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFcc0000),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        img,
                        height: 60,
                        width: 60,
                        filterQuality: FilterQuality.none,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '#$id',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        name.toString().toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'press-start',
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
