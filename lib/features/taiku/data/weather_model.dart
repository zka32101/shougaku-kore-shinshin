/// ③ きょうの空モード：天気・季節・警報連動
enum WeatherType { sunny, cloudy, rainy, snowy, stormy, unknown }

enum Season { spring, summer, autumn, winter }

class WeatherInfo {
  final WeatherType type;
  final int temperature;
  final Season season;
  final List<String> alerts; // ['heavy_rain', 'heat', 'wind', 'snow']
  final String cityName;
  final DateTime fetchedAt;

  const WeatherInfo({
    required this.type,
    required this.temperature,
    required this.season,
    this.alerts = const [],
    this.cityName = '',
    required this.fetchedAt,
  });

  static WeatherInfo get fallback => WeatherInfo(
        type: WeatherType.sunny,
        temperature: 20,
        season: _currentSeason(),
        fetchedAt: DateTime.now(),
      );

  bool get isOutdoorFriendly =>
      type == WeatherType.sunny ||
      (type == WeatherType.cloudy && temperature >= 10 && temperature <= 30);

  bool get hasAlerts => alerts.isNotEmpty;

  bool get isHotWeather => temperature >= 30;
  bool get isColdWeather => temperature <= 5;

  String get weatherEmoji {
    switch (type) {
      case WeatherType.sunny:
        return '☀️';
      case WeatherType.cloudy:
        return '☁️';
      case WeatherType.rainy:
        return '🌧️';
      case WeatherType.snowy:
        return '❄️';
      case WeatherType.stormy:
        return '⛈️';
      case WeatherType.unknown:
        return '🌤️';
    }
  }

  String get weatherLabel {
    switch (type) {
      case WeatherType.sunny:
        return 'はれ';
      case WeatherType.cloudy:
        return 'くもり';
      case WeatherType.rainy:
        return 'あめ';
      case WeatherType.snowy:
        return 'ゆき';
      case WeatherType.stormy:
        return 'あらし';
      case WeatherType.unknown:
        return 'よみこみ中';
    }
  }

  String get recommendMessage {
    if (hasAlerts) {
      return '⚠️ 警報が出ています。防災を学ぼう！';
    }
    if (isOutdoorFriendly) {
      return '$weatherEmojiいい天気！外でスポーツをしよう！';
    }
    if (type == WeatherType.rainy) {
      return '🌧️ 雨の日は室内で栄養や防災を学ぼう！';
    }
    if (isHotWeather) {
      return '🌡️ 暑い日は水分補給！熱中症を学ぼう！';
    }
    if (isColdWeather) {
      return '🧊 寒い日は室内でストレッチ！';
    }
    return '$weatherEmoji今日はどんな活動をしようかな？';
  }

  /// 天気に合わせた推奨テーマ
  List<String> get recommendedThemes {
    if (hasAlerts) return ['disaster'];
    if (isOutdoorFriendly) return ['sports', 'disaster'];
    if (type == WeatherType.rainy || type == WeatherType.stormy) {
      return ['nutrition', 'disaster', 'career'];
    }
    if (isHotWeather) return ['nutrition', 'disaster'];
    return ['nutrition', 'career', 'sports'];
  }

  static Season _currentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }
}
