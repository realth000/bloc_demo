import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http show Client;

import 'models/models.dart';

/// Http request failed when getting location info.
class LocationRequestFailure implements Exception {}

/// Provided location is not found.
class LocationNotFoundFailure implements Exception {}

/// Http request failed when getting weather info.
class WeatherRequestFailure implements Exception {}

/// Weather for provided location is not found.
class WeatherNotFountFailure implements Exception {}

class OpenMeteoApiClient {
  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrlWeather = 'api.open-metio.com';
  static const _baseUrlGeocoding = 'geocoding-api.open-meteo.com';

  final http.Client _httpClient;

  /// # Exception
  ///
  /// * [LocationRequestFailure]: Throw when http request to fetch location info failed.
  /// * [LocationNotFoundFailure]: Throw when no `results` key found or value is empty in location json data.
  Future<Location> locationSearch(String query) async {
    final req = Uri.https(
      _baseUrlGeocoding,
      '/v1/search',
      {
        'name': query,
        'count': '1',
      },
    );

    final resp = await _httpClient.get(req);

    if (resp.statusCode != HttpStatus.ok) {
      throw LocationRequestFailure();
    }

    final locationJson = jsonDecode(resp.body) as Map;
    if (!locationJson.containsKey('results')) {
      throw LocationNotFoundFailure();
    }

    final results = locationJson['results'] as List;
    if (results.isEmpty) {
      throw LocationNotFoundFailure();
    }

    return Location.fromJson(results.first as Map<String, dynamic>);
  }

  /// # Exception
  ///
  /// * [WeatherRequestFailure] throw when http request failed.
  /// * [WeatherNotFountFailure] throw when weather response does not contain key 'current_weather'.
  Future<Weather> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final req = Uri.https(_baseUrlWeather, 'v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
    });

    final resp = await _httpClient.get(req);

    if (resp.statusCode != HttpStatus.ok) {
      throw WeatherRequestFailure();
    }

    final bodyJson = jsonDecode(resp.body) as Map<String, dynamic>;

    if (!bodyJson.containsKey('current_weather')) {
      throw WeatherNotFountFailure();
    }

    final weatherJson = bodyJson['current_weather'] as Map<String, dynamic>;
    return Weather.fromJson(weatherJson);
  }
}
