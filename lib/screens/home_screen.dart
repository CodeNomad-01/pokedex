import 'package:flutter/material.dart';
import '../services/pokemon_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenState();
  }
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
      appBar: AppBar(title: const Text('Pokédex')),
      body: FutureBuilder<List<dynamic>>(
        future: _pokemonList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else {
            final pokemonList = snapshot.data!;
            return ListView.builder(
              itemCount: pokemonList,
              itemBuilder: (context, index) {
                final pokemon = pokemonList[index];
                return ListTilte(
                  title: Text(pokemon['name'].toString().toUpperCase()),
                  onTap: () {},
                );
              },
            );
          }
        },
      ),
    );
  }
}
