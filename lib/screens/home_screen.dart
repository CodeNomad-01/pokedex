import 'package:flutter/material.dart';
import '../services/pokemon_service.dart';
import '../screens/pokemon_details_screen.dart';
import '../screens/type_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = PokemonService();
  late Future<List<dynamic>> _list;
  List<dynamic> _allPokemons = [];
  List<dynamic> _filteredPokemons = [];
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _list = _service.fetchPokemonsList();
    _list.then((value) {
      setState(() {
        _allPokemons = value;
        _filteredPokemons = value;
      });
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredPokemons =
          _allPokemons.where((p) {
            final name = p['name'].toString().toLowerCase();
            final url = p['url'] as String;
            final id = url.split('/')[url.split('/').length - 2];
            return name.contains(query) || id == query;
          }).toList();
    });
  }

  Future<List<String>> _fetchTypes(String url) async {
    final data = await _service.fetchPokemonDetail(url);
    final types = data['types'] as List;
    return types.map<String>((t) => t['type']['name'] as String).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 217, 173),
      appBar: AppBar(
        title: const Text('POKEDEX'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TypesScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body:
          _filteredPokemons.isEmpty
              ? const Center(child: Text('No se encontraron Pokémon'))
              : GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _filteredPokemons.length,
                itemBuilder: (context, i) {
                  final p = _filteredPokemons[i];
                  final name = p['name'] as String;
                  final url = p['url'] as String;
                  final id = url.split('/')[url.split('/').length - 2];
                  final img =
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

                  return FutureBuilder<List<String>>(
                    future: _fetchTypes(url),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 1),
                        );
                      }
                      final types = snapshot.data!;
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
                            color: const Color.fromARGB(255, 255, 195, 105),
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Image.network(
                                  img,
                                  height: 50,
                                  width: 50,
                                  filterQuality: FilterQuality.none,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#${id.padLeft(3, '0')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  name.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'press-start',
                                    color: Colors.white,
                                    fontSize: 7,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 2,
                                runSpacing: 2,
                                alignment: WrapAlignment.center,
                                children:
                                    types.map((type) {
                                      final color =
                                          _typeColors[type.toLowerCase()] ??
                                          Colors.white;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          type.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }).toList(),
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
