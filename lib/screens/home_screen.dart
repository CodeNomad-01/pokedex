import 'package:flutter/material.dart';
import '../services/pokemon_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokemonService _pokemonService = PokemonService();
  late Future<List<dynamic>> _pokemonList;

  @override
  void initState() {
    super.initState();
    _pokemonList = _pokemonService.fetchPokemonsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex'), backgroundColor: Colors.red),
      body: FutureBuilder<List<dynamic>>(
        future: _pokemonList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else {
            final pokemonList = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = pokemonList[index];
                final name = pokemon['name'];
                final url = pokemon['url'];
                final id = url.split('/')[url.split('/').length - 2];
                final imageUrl =
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

                return GestureDetector(
                  onTap: () {
                    // Aquí luego llevaremos al detalle
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFcc0000), // rojo Pokédex
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(
                        0,
                      ), // cuadrado = retro
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
                          imageUrl,
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
          }
        },
      ),
    );
  }
}
