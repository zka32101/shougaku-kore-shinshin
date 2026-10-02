import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../data/weather_model.dart';

/// ③ きょうの空モード：天気プロバイダー
/// OpenWeatherMap の API を使用（無料枠）
/// APIキーは設定画面で入力（デフォルトは「東京」の固定データ）
final weatherProvider =
    StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherInfo>>((ref) {
  return WeatherNotifier();
});

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherInfo>> {
  WeatherNotifier() : super(const AsyncValue.loading()) {
    fetch();
  }

  static const _apiKey = ''; // TODO: ユーザーが設定画面で入力
  static const _defaultCity = 'Tokyo';

  Future<void> fetch({String? city}) async {
    state = const AsyncValue.loading();
    try {
      final cityName = city ?? _defaultCity;

      if (_apiKey.isEmpty) {
        // APIキー未設定の場合はフォールバック（季節ベース）
        state = AsyncValue.data(_seasonalFallback());
        return;
      }

      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?q=$cityName&appid=$_apiKey&units=metric&lang=ja',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        state = AsyncValue.data(_parseResponse(data));
      } else {
        state = AsyncValue.data(_seasonalFallback());
      }
    } catch (_) {
      state = AsyncValue.data(_seasonalFallback());
    }
  }

  WeatherInfo _parseResponse(Map<String, dynamic> data) {
    final weatherList = data['weather'] as List<dynamic>;
    final main = data['main'] as Map<String, dynamic>;
    final weatherId = (weatherList.first as Map<String, dynamic>)['id'] as int;
    final temp = (main['temp'] as num).toInt();

    WeatherType type;
    if (weatherId >= 800) {
      type = weatherId == 800 ? WeatherType.sunny : WeatherType.cloudy;
    } else if (weatherId >= 700) {
      type = WeatherType.cloudy;
    } else if (weatherId >= 600) {
      type = WeatherType.snowy;
    } else if (weatherId >= 500) {
      type = WeatherType.rainy;
    } else if (weatherId >= 300) {
      type = WeatherType.rainy;
    } else if (weatherId >= 200) {
      type = WeatherType.stormy;
    } else {
      type = WeatherType.unknown;
    }

    // 警報判定（気温・天気IDベース）
    final alerts = <String>[];
    if (temp >= 35) alerts.add('heat');
    if (type == WeatherType.stormy) alerts.add('storm');
    if (type == WeatherType.snowy && temp <= -5) alerts.add('heavy_snow');

    return WeatherInfo(
      type: type,
      temperature: temp,
      season: _getSeason(),
      alerts: alerts,
      cityName: (data['name'] as String?) ?? '',
      fetchedAt: DateTime.now(),
    );
  }

  WeatherInfo _seasonalFallback() {
    final season = _getSeason();
    WeatherType type;
    int temp;
    switch (season) {
      case Season.spring:
        type = WeatherType.sunny;
        temp = 18;
      case Season.summer:
        type = WeatherType.sunny;
        temp = 30;
      case Season.autumn:
        type = WeatherType.cloudy;
        temp = 20;
      case Season.winter:
        type = WeatherType.cloudy;
        temp = 8;
    }
    return WeatherInfo(
      type: type,
      temperature: temp,
      season: season,
      fetchedAt: DateTime.now(),
    );
  }

  Season _getSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }
}
