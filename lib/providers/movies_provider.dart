import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas_app/helpers/debouncer.dart';
import '../models/models.dart';

class MoviesProvider extends ChangeNotifier {
  
  final String _baseUrl = 'api.themoviedb.org';
  final String _apiKey = '564c283060d4b4623f6f3050d0f6567e';
  final String _lang = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500), 
  );

  final StreamController<List<Movie>> _suggestionsStreamController = StreamController.broadcast();
  Stream<List<Movie>>  get suggestionsStream => _suggestionsStreamController.stream;


  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endPoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endPoint,
        {'api_key': _apiKey, 'language': _lang, 'page': '$page'});

    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('/3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromRawJson(jsonData);
    onDisplayMovies = [...nowPlayingResponse.results];
    notifyListeners(); // Avisa que hubieron cambios en la data
  }

  getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('/3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromRawJson(jsonData);
    popularMovies = [...popularMovies, ...popularResponse.results];

    notifyListeners();
  }

  Future<List<Cast>> getMovieCast( int movieId) async{
    if (moviesCast.containsKey(movieId))return moviesCast[movieId]!;
    final jsonData = await _getJsonData('/3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromRawJson(jsonData);
    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async{
    final url = Uri.https(_baseUrl, '/3/search/movie',
        {'api_key': _apiKey, 'language': _lang, 'query': query});

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromRawJson(response.body);

    return searchResponse.results;

  }

  void getSuggestionsByQuery(String query){
    debouncer.value = '';
    debouncer.onValue = (value) async{
      final results = await searchMovie(value);
      _suggestionsStreamController.add(results);
    };
    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) { 
      debouncer.value = query;
    });
    Future.delayed(const Duration(milliseconds: 301)).then((_) => timer.cancel());
  }


}
