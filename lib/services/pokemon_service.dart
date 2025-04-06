import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon?limit=151';

  Future<List<dynamic>> fetchPokemonsList() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    }
    throw Exception('Failed to load pokemons');
  }

  Future<Map<String, dynamic>> fetchPokemonDetail(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load pokemon detail');
  }
}
