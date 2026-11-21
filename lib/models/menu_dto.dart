class MenuDto {
  final String menuId;
  final String namaMenu;
  final String kategori; // Makanan Utama, Minuman, Sisi/Cemilan
  final int harga;
  final String gambarUrl;
  final bool statusTersedia;

  MenuDto({
    required this.menuId,
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    required this.gambarUrl,
    required this.statusTersedia,
  });

  factory MenuDto.fromJson(Map<String, dynamic> json) {
    return MenuDto(
      menuId: json['menu_id'] ?? '',
      namaMenu: json['nama_menu'] ?? '',
      kategori: json['kategori'] ?? 'Makanan Utama',
      harga: json['harga'] ?? 0,
      gambarUrl: json['gambar_url'] ?? '',
      statusTersedia: json['status_tersedia'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'menu_id': menuId,
    'nama_menu': namaMenu,
    'kategori': kategori,
    'harga': harga,
    'gambar_url': gambarUrl,
    'status_tersedia': statusTersedia,
  };
}
