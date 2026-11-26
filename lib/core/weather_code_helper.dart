import 'package:flutter/material.dart';

class WeatherCodeHelper {
  static String description(int code) {
    if (code == 0) return 'Cerah';
    if (code == 1) return 'Cerah berawan';
    if (code == 2) return 'Berawan sebagian';
    if (code == 3) return 'Mendung';
    if (code == 45 || code == 48) return 'Berkabut';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Gerimis';
    if ([61, 63, 65, 66, 67].contains(code)) return 'Hujan';
    if ([71, 73, 75, 77].contains(code)) return 'Salju';
    if ([80, 81, 82, 85, 86].contains(code)) return 'Hujan deras';
    if ([95, 96, 99].contains(code)) return 'Badai petir';
    return 'Kondisi cuaca tidak diketahui';
  }

  static IconData icon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if ([1, 2].contains(code)) return Icons.cloud_queue;
    if (code == 3) return Icons.cloud;
    if ([45, 48].contains(code)) return Icons.cloud_queue;
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return Icons.grain;
    }
    if ([71, 73, 75, 77, 85, 86].contains(code)) return Icons.ac_unit;
    if ([95, 96, 99].contains(code)) return Icons.flash_on;
    return Icons.cloud_queue;
  }
}
