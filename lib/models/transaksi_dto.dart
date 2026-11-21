class DetailTransaksiDto {
  final String menuId;
  final String namaMenu;
  final int jumlahPorsi;
  final int subtotal;

  DetailTransaksiDto({
    required this.menuId,
    required this.namaMenu,
    required this.jumlahPorsi,
    required this.subtotal,
  });

  factory DetailTransaksiDto.fromJson(Map<String, dynamic> json) =>
      DetailTransaksiDto(
        menuId: json['menu_id'] ?? '',
        namaMenu: json['nama_menu'] ?? '',
        jumlahPorsi: json['jumlah_porsi'] ?? 1,
        subtotal: json['subtotal'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'menu_id': menuId,
    'nama_menu': namaMenu,
    'jumlah_porsi': jumlahPorsi,
    'subtotal': subtotal,
  };
}

class TransaksiDto {
  final String transaksiId;
  final String kodeTransaksi;
  final String tanggalTransaksi;
  final int totalBayar;
  final String metodePembayaran; // 'Cash' atau 'QRIS'
  final String kasirId;
  final List<DetailTransaksiDto> items;

  TransaksiDto({
    required this.transaksiId,
    required this.kodeTransaksi,
    required this.tanggalTransaksi,
    required this.totalBayar,
    required this.metodePembayaran,
    required this.kasirId,
    required this.items,
  });

  factory TransaksiDto.fromJson(Map<String, dynamic> json) => TransaksiDto(
    transaksiId: json['transaksi_id'] ?? '',
    kodeTransaksi: json['kode_transaksi'] ?? '',
    tanggalTransaksi: json['tanggal_transaksi'] ?? '',
    totalBayar: json['total_bayar'] ?? 0,
    metodePembayaran: json['metode_pembayaran'] ?? 'Cash',
    kasirId: json['kasir_id'] ?? '',
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => DetailTransaksiDto.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'transaksi_id': transaksiId,
    'kode_transaksi': kodeTransaksi,
    'tanggal_transaksi': tanggalTransaksi,
    'total_bayar': totalBayar,
    'metode_pembayaran': metodePembayaran,
    'kasir_id': kasirId,
    'items': items.map((e) => e.toJson()).toList(),
  };
}
