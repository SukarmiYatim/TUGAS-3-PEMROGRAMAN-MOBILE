// SISTEM MANAJEMEN TOKO ONLINE
// Materi: OOP, Inheritance, dan Mixin

// 1. ABSTRACT CLASS PRODUK
abstract class Produk {
  final String id;
  final String nama;
  final double harga;
  int stok;

  Produk({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
  });

  String deskripsi(); // Abstract method
}

// 2. CLASS PRODUK DIGITAL
class ProdukDigital extends Produk {
  final double ukuranMB;
  final String formatFile;

  ProdukDigital({
    required super.id,
    required super.nama,
    required super.harga,
    required super.stok,
    required this.ukuranMB,
    required this.formatFile,
  });

  @override
  String deskripsi() {
    return 'Produk Digital: $nama | '
        'Ukuran: ${ukuranMB}MB | Format: $formatFile';
  }
}

// 3. CLASS PRODUK FISIK
class ProdukFisik extends Produk {
  final double beratGram;
  final String dimensi;

  ProdukFisik({
    required super.id,
    required super.nama,
    required super.harga,
    required super.stok,
    required this.beratGram,
    required this.dimensi,
  });

  @override
  String deskripsi() {
    return 'Produk Fisik: $nama | '
        'Berat: ${beratGram}g | Dimensi: $dimensi';
  }
}

// 4. MIXIN DISKON
mixin MixInBisaDiskon {
  double hitungHargaDiskon(double persen) {
    return hargaProduk * (1 - persen / 100);
  }

  double get hargaProduk; // Getter abstrak sederhana
}

// Produk Fisik menggunakan mixin diskon
class ProdukFisikDiskon extends ProdukFisik with MixInBisaDiskon {
  ProdukFisikDiskon({
    required super.id,
    required super.nama,
    required super.harga,
    required super.stok,
    required super.beratGram,
    required super.dimensi,
  });

  @override
  double get hargaProduk => harga;
}

// 5. CUSTOM EXCEPTION
class StokHabisException implements Exception {
  final String pesan;
  StokHabisException(this.pesan);

  @override
  String toString() => 'StokHabisException: $pesan';
}

class ProdukTidakAdaException implements Exception {
  final String pesan;
  ProdukTidakAdaException(this.pesan);

  @override
  String toString() => 'ProdukTidakAdaException: $pesan';
}

// 6. CLASS KERANJANG
class Keranjang {
  final List<Produk> daftarProduk = [];

  void tambah(Produk produk) {
    // Menambahkan produk
    if (produk.stok <= 0) {
      throw StokHabisException('Stok produk "${produk.nama}" sudah habis.');
    }
    daftarProduk.add(produk);
    produk.stok--;

    print('Produk "${produk.nama}" berhasil ditambahkan.');
  }

  void hapus(String id) {
    // Menghapus produk
    try {
      final index = daftarProduk.indexWhere((produk) => produk.id == id);

      if (index == -1) {
        throw ProdukTidakAdaException(
          'Produk dengan ID $id tidak ada di keranjang.',
        );
      }

      final produk = daftarProduk.removeAt(index);

      produk.stok++; // Kembalikan stok

      print('Produk "${produk.nama}" berhasil dihapus.');
    } catch (e) {
      print('Gagal menghapus produk: $e');
    }
  }

  double totalHarga() {
    // Menghitung total harga
    double total = 0;

    for (var produk in daftarProduk) {
      total += produk.harga;
    }

    return total;
  }

  void tampilkanKeranjang() {
    // Menampilkan isi keranjang
    print('\n===== ISI KERANJANG =====');

    if (daftarProduk.isEmpty) {
      print('Keranjang masih kosong.');
      return;
    }

    for (var produk in daftarProduk) {
      print(
        '${produk.id} | ${produk.nama} | '
        'Rp${produk.harga.toStringAsFixed(0)}',
      );
    }

    print('Total Harga: Rp${totalHarga().toStringAsFixed(0)}');
  }
}

// 7. CLASS TOKO SERVICE
class TokoService {
  final List<Produk> daftarProduk;

  TokoService(this.daftarProduk);

  Future<Produk> cariProduk(String nama) async {
    // Mencari produk secara asynchronous
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulasi proses pencarian

    try {
      final produk = daftarProduk.firstWhere(
        (produk) => produk.nama.toLowerCase() == nama.toLowerCase(),
      );

      return produk;
    } catch (e) {
      throw ProdukTidakAdaException('Produk "$nama" tidak ditemukan.');
    }
  }

  Future<void> prosesCheckout(Keranjang keranjang) async {
    // Proses checkout menggunakan Future
    try {
      print('\nMemproses checkout...');

      await Future.delayed(const Duration(seconds: 2));

      if (keranjang.daftarProduk.isEmpty) {
        throw Exception('Keranjang kosong.');
      }

      final total = keranjang.totalHarga();

      print('Checkout berhasil!');
      print('Total pembayaran: Rp${total.toStringAsFixed(0)}');
    } catch (e) {
      print('Checkout gagal: $e');
    }
  }
}

// 8. PROGRAM UTAMA
Future<void> main() async {
  print('======================================');
  print('   SISTEM MANAJEMEN TOKO ONLINE');
  print('======================================');

  // Membuat produk
  final produk1 = ProdukDigital(
    id: 'D001',
    nama: 'E-Book Flutter',
    harga: 50000,
    stok: 5,
    ukuranMB: 10.5,
    formatFile: 'PDF',
  );

  final produk2 = ProdukFisikDiskon(
    id: 'F001',
    nama: 'Keyboard Mechanical',
    harga: 350000,
    stok: 3,
    beratGram: 800,
    dimensi: '35 x 12 x 4 cm',
  );

  final produk3 = ProdukFisik(
    id: 'F002',
    nama: 'Mouse Wireless',
    harga: 150000,
    stok: 0,
    beratGram: 200,
    dimensi: '12 x 6 x 4 cm',
  );

  // Menampilkan deskripsi produk
  print('\n===== DAFTAR PRODUK =====');
  print(produk1.deskripsi());
  print(produk2.deskripsi());
  print(produk3.deskripsi());

  // Mixin diskon
  print('\n===== DISKON =====');

  final hargaDiskon = produk2.hitungHargaDiskon(10);

  print('Harga normal: Rp${produk2.harga.toStringAsFixed(0)}');
  print(
    'Harga setelah diskon 10%: '
    'Rp${hargaDiskon.toStringAsFixed(0)}',
  );

  // Membuat keranjang
  final keranjang = Keranjang();

  print('\n===== TAMBAH PRODUK =====');

  try {
    keranjang.tambah(produk1);
    keranjang.tambah(produk2);

    // Sengaja mencoba produk yang stoknya habis
    keranjang.tambah(produk3);
  } catch (e) {
    print('Gagal menambahkan produk: $e');
  }

  // Menampilkan keranjang
  keranjang.tampilkanKeranjang();

  // Menghapus produk
  print('\n===== HAPUS PRODUK =====');

  keranjang.hapus('F001');

  keranjang.tampilkanKeranjang();

  // TOKO SERVICE
  final toko = TokoService([produk1, produk2, produk3]);

  // Async/Await mencari produk
  print('\n===== PENCARIAN PRODUK =====');

  try {
    final hasil = await toko.cariProduk('E-Book Flutter');

    print('Produk ditemukan:');
    print(hasil.deskripsi());
  } catch (e) {
    print('Pencarian gagal: $e');
  }

  // Mencoba mencari produk yang tidak ada
  try {
    final hasil = await toko.cariProduk('Laptop Gaming');

    print(hasil.deskripsi());
  } catch (e) {
    print('Pencarian gagal: $e');
  }

  // CHECKOUT
  print('\n===== CHECKOUT =====');

  // Tambahkan kembali produk untuk checkout
  try {
    keranjang.tambah(produk1);
    keranjang.tambah(produk2);
  } catch (e) {
    print('Gagal menambahkan produk: $e');
  }

  keranjang.tampilkanKeranjang();

  await toko.prosesCheckout(keranjang);

  print('\n======================================');
  print('       PROGRAM SELESAI');
  print('======================================');
}
