import 'package:adhan/adhan.dart';

/// Model for a city with prayer time calculation parameters
class PrayerCity {
  final String id;
  final String nameEn;
  final String nameTr;
  final String nameFi;
  final String country;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String timezone;
  final CalculationMethod calculationMethod;

  const PrayerCity({
    required this.id,
    required this.nameEn,
    required this.nameTr,
    required this.nameFi,
    required this.country,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.calculationMethod,
  });

  /// Get localized name
  String getName(String lang) {
    switch (lang) {
      case 'tr':
        return nameTr;
      case 'fi':
        return nameFi;
      default:
        return nameEn;
    }
  }

  /// Get coordinates for adhan calculation
  Coordinates get coordinates => Coordinates(latitude, longitude);

  /// Get calculation parameters
  CalculationParameters get calculationParameters => calculationMethod.getParameters();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {'id': id};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerCity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Predefined cities organized by country
class PrayerCities {
  PrayerCities._();

  // Finland
  static const helsinki = PrayerCity(
    id: 'helsinki',
    nameEn: 'Helsinki / Espoo / Vantaa',
    nameTr: 'Helsinki / Espoo / Vantaa',
    nameFi: 'Helsinki / Espoo / Vantaa',
    country: 'Finland',
    countryCode: 'FI',
    latitude: 60.1699,
    longitude: 24.9384,
    timezone: 'Europe/Helsinki',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  static const tampere = PrayerCity(
    id: 'tampere',
    nameEn: 'Tampere',
    nameTr: 'Tampere',
    nameFi: 'Tampere',
    country: 'Finland',
    countryCode: 'FI',
    latitude: 61.4978,
    longitude: 23.7610,
    timezone: 'Europe/Helsinki',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  static const turku = PrayerCity(
    id: 'turku',
    nameEn: 'Turku',
    nameTr: 'Turku',
    nameFi: 'Turku',
    country: 'Finland',
    countryCode: 'FI',
    latitude: 60.4518,
    longitude: 22.2666,
    timezone: 'Europe/Helsinki',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  // Turkey
  static const istanbul = PrayerCity(
    id: 'istanbul',
    nameEn: 'Istanbul',
    nameTr: 'İstanbul',
    nameFi: 'Istanbul',
    country: 'Turkey',
    countryCode: 'TR',
    latitude: 41.0082,
    longitude: 28.9784,
    timezone: 'Europe/Istanbul',
    calculationMethod: CalculationMethod.turkey,
  );

  static const ankara = PrayerCity(
    id: 'ankara',
    nameEn: 'Ankara',
    nameTr: 'Ankara',
    nameFi: 'Ankara',
    country: 'Turkey',
    countryCode: 'TR',
    latitude: 39.9334,
    longitude: 32.8597,
    timezone: 'Europe/Istanbul',
    calculationMethod: CalculationMethod.turkey,
  );

  static const izmir = PrayerCity(
    id: 'izmir',
    nameEn: 'Izmir',
    nameTr: 'İzmir',
    nameFi: 'Izmir',
    country: 'Turkey',
    countryCode: 'TR',
    latitude: 38.4237,
    longitude: 27.1428,
    timezone: 'Europe/Istanbul',
    calculationMethod: CalculationMethod.turkey,
  );

  static const bursa = PrayerCity(
    id: 'bursa',
    nameEn: 'Bursa',
    nameTr: 'Bursa',
    nameFi: 'Bursa',
    country: 'Turkey',
    countryCode: 'TR',
    latitude: 40.1885,
    longitude: 29.0610,
    timezone: 'Europe/Istanbul',
    calculationMethod: CalculationMethod.turkey,
  );

  static const antalya = PrayerCity(
    id: 'antalya',
    nameEn: 'Antalya',
    nameTr: 'Antalya',
    nameFi: 'Antalya',
    country: 'Turkey',
    countryCode: 'TR',
    latitude: 36.8969,
    longitude: 30.7133,
    timezone: 'Europe/Istanbul',
    calculationMethod: CalculationMethod.turkey,
  );

  // Germany
  static const berlin = PrayerCity(
    id: 'berlin',
    nameEn: 'Berlin',
    nameTr: 'Berlin',
    nameFi: 'Berliini',
    country: 'Germany',
    countryCode: 'DE',
    latitude: 52.5200,
    longitude: 13.4050,
    timezone: 'Europe/Berlin',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  static const munich = PrayerCity(
    id: 'munich',
    nameEn: 'Munich',
    nameTr: 'Münih',
    nameFi: 'München',
    country: 'Germany',
    countryCode: 'DE',
    latitude: 48.1351,
    longitude: 11.5820,
    timezone: 'Europe/Berlin',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  static const frankfurt = PrayerCity(
    id: 'frankfurt',
    nameEn: 'Frankfurt',
    nameTr: 'Frankfurt',
    nameFi: 'Frankfurt',
    country: 'Germany',
    countryCode: 'DE',
    latitude: 50.1109,
    longitude: 8.6821,
    timezone: 'Europe/Berlin',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  static const cologne = PrayerCity(
    id: 'cologne',
    nameEn: 'Cologne',
    nameTr: 'Köln',
    nameFi: 'Köln',
    country: 'Germany',
    countryCode: 'DE',
    latitude: 50.9375,
    longitude: 6.9603,
    timezone: 'Europe/Berlin',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  // Netherlands
  static const amsterdam = PrayerCity(
    id: 'amsterdam',
    nameEn: 'Amsterdam',
    nameTr: 'Amsterdam',
    nameFi: 'Amsterdam',
    country: 'Netherlands',
    countryCode: 'NL',
    latitude: 52.3676,
    longitude: 4.9041,
    timezone: 'Europe/Amsterdam',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  static const rotterdam = PrayerCity(
    id: 'rotterdam',
    nameEn: 'Rotterdam',
    nameTr: 'Rotterdam',
    nameFi: 'Rotterdam',
    country: 'Netherlands',
    countryCode: 'NL',
    latitude: 51.9244,
    longitude: 4.4777,
    timezone: 'Europe/Amsterdam',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  static const theHague = PrayerCity(
    id: 'the_hague',
    nameEn: 'The Hague',
    nameTr: 'Lahey',
    nameFi: 'Haag',
    country: 'Netherlands',
    countryCode: 'NL',
    latitude: 52.0705,
    longitude: 4.3007,
    timezone: 'Europe/Amsterdam',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  // Latvia
  static const riga = PrayerCity(
    id: 'riga',
    nameEn: 'Riga',
    nameTr: 'Riga',
    nameFi: 'Riika',
    country: 'Latvia',
    countryCode: 'LV',
    latitude: 56.9496,
    longitude: 24.1052,
    timezone: 'Europe/Riga',
    calculationMethod: CalculationMethod.muslim_world_league,
  );

  // USA
  static const newYork = PrayerCity(
    id: 'new_york',
    nameEn: 'New York',
    nameTr: 'New York',
    nameFi: 'New York',
    country: 'USA',
    countryCode: 'US',
    latitude: 40.7128,
    longitude: -74.0060,
    timezone: 'America/New_York',
    calculationMethod: CalculationMethod.north_america,
  );

  static const losAngeles = PrayerCity(
    id: 'los_angeles',
    nameEn: 'Los Angeles',
    nameTr: 'Los Angeles',
    nameFi: 'Los Angeles',
    country: 'USA',
    countryCode: 'US',
    latitude: 34.0522,
    longitude: -118.2437,
    timezone: 'America/Los_Angeles',
    calculationMethod: CalculationMethod.north_america,
  );

  static const chicago = PrayerCity(
    id: 'chicago',
    nameEn: 'Chicago',
    nameTr: 'Chicago',
    nameFi: 'Chicago',
    country: 'USA',
    countryCode: 'US',
    latitude: 41.8781,
    longitude: -87.6298,
    timezone: 'America/Chicago',
    calculationMethod: CalculationMethod.north_america,
  );

  static const houston = PrayerCity(
    id: 'houston',
    nameEn: 'Houston',
    nameTr: 'Houston',
    nameFi: 'Houston',
    country: 'USA',
    countryCode: 'US',
    latitude: 29.7604,
    longitude: -95.3698,
    timezone: 'America/Chicago',
    calculationMethod: CalculationMethod.north_america,
  );

  /// All available cities grouped by country
  static Map<String, List<PrayerCity>> get byCountry => {
        'Finland': [helsinki, tampere, turku],
        'Turkey': [istanbul, ankara, izmir, bursa, antalya],
        'Germany': [berlin, munich, frankfurt, cologne],
        'Netherlands': [amsterdam, rotterdam, theHague],
        'Latvia': [riga],
        'USA': [newYork, losAngeles, chicago, houston],
      };

  /// All cities as a flat list
  static List<PrayerCity> get all => byCountry.values.expand((c) => c).toList();

  /// Find city by ID
  static PrayerCity? findById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Default city
  static PrayerCity get defaultCity => helsinki;
}
