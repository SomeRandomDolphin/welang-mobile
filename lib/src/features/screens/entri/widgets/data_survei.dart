class Survei {
  final int? id;
  final double tinggi;
  final DateTime tanggalKejadian;
  final String? foto;
  final String? catatan;
  final double latitude;
  final double longitude;
  final int? userId;
  final String? userName; // from eager-loaded user relation

  Survei({
    this.id,
    required this.tinggi,
    required this.tanggalKejadian,
    this.foto,
    this.catatan,
    required this.latitude,
    required this.longitude,
    this.userId,
    this.userName,
  });

  factory Survei.fromJson(Map<String, dynamic> json) {
    return Survei(
      id: json['id'] as int?,
      tinggi: double.parse(json['tinggi'].toString()),
      tanggalKejadian: DateTime.parse(json['tanggal_kejadian']),
      foto: json['foto'] as String?,
      catatan: json['catatan'] as String?,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      userId: json['user_id'] as int?,
      userName: json['user'] != null ? json['user']['name'] as String? : null,
    );
  }

  Map<String, String> toFormFields() {
    return {
      'tinggi': tinggi.toString(),
      'tanggal_kejadian': tanggalKejadian.toIso8601String(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (catatan != null && catatan!.trim().isNotEmpty) 'catatan': catatan!.trim(),
    };
  }
}
