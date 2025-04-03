import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  Future<List<dynamic>> fetchPokemonsList() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load pokemons');
    }
  }
}
