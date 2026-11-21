class BahanBakuDto {
  final String bahanId;
  final String namaBahan;
  final double stokSaatIni;
  final String satuan; // gram, kg, pcs, ml
  final double stokMinimum;

  BahanBakuDto({
    required this.bahanId,
    required this.namaBahan,
    required this.stokSaatIni,
    required this.satuan,
    required this.stokMinimum,
  });

  factory BahanBakuDto.fromJson(Map<String, dynamic> json) {
    return BahanBakuDto(
      bahanId: json['bahan_id'] ?? '',
      namaBahan: json['nama_bahan'] ?? '',
      stokSaatIni: (json['stok_saat_ini'] ?? 0).toDouble(),
      satuan: json['satuan'] ?? 'gram',
      stokMinimum: (json['stok_minimum'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'bahan_id': bahanId,
    'nama_bahan': namaBahan,
    'stok_saat_ini': stokSaatIni,
    'satuan': satuan,
    'stok_minimum': stokMinimum,
  };
}
