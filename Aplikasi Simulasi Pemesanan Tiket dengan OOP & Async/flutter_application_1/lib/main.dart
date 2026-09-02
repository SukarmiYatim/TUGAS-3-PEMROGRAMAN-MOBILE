import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// WARNA
const Color primaryBlue = Color(0xFF1565C0);
const Color lightBlue = Color(0xFF42A5F5);
const Color green = Color(0xFF10B981);
const Color orange = Color(0xFFFFA000);
const Color purple = Color(0xFF7E57C2);

// FORMAT RUPIAH
String rupiah(double value) {
  final number = value.round().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < number.length; i++) {
    if (i > 0 && (number.length - i) % 3 == 0) {
      buffer.write('.');
    }

    buffer.write(number[i]);
  }

  return 'Rp ${buffer.toString()}';
}

// CUSTOM EXCEPTION
class StokHabisException implements Exception {
  final String message;

  StokHabisException(this.message);

  @override
  String toString() => message;
}

class TiketTidakDitemukanException implements Exception {
  final String message;

  TiketTidakDitemukanException(this.message);

  @override
  String toString() => message;
}

class DiskonTidakValidException implements Exception {
  final String message;

  DiskonTidakValidException(this.message);

  @override
  String toString() => message;
}

// ABSTRACT CLASS
abstract class Tiket {
  final String id;
  final String nama;
  final double harga;
  int stok;
  final String deskripsi;
  final IconData icon;
  final Color warna;

  Tiket({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    required this.icon,
    required this.warna,
  });

  String kategori();

  bool get tersedia => stok > 0;

  String get statusStok {
    if (stok <= 0) {
      return 'Stok habis';
    }

    if (stok <= 3) {
      return 'Stok terbatas';
    }

    return 'Tersedia';
  }
}

// MIXIN
mixin BisaDiskon on Tiket {
  double get diskonMaksimal;

  bool validasiDiskon(double persen) {
    return persen >= 0 && persen <= diskonMaksimal;
  }

  double hitungHargaDiskon(double persen) {
    if (!validasiDiskon(persen)) {
      throw DiskonTidakValidException(
        'Diskon maksimal $nama adalah '
        '${diskonMaksimal.toStringAsFixed(0)}%',
      );
    }

    return harga - (harga * persen / 100);
  }

  double hitungNilaiDiskon(double persen) {
    return harga * persen / 100;
  }
}

// INHERITANCE - TIKET EKONOMI
class TiketEkonomi extends Tiket with BisaDiskon {
  TiketEkonomi({
    required super.id,
    required super.nama,
    required super.harga,
    required super.stok,
    required super.deskripsi,
    required super.icon,
    required super.warna,
  });

  @override
  double get diskonMaksimal => 10;

  @override
  String kategori() {
    return 'Ekonomi';
  }
}

// INHERITANCE - TIKET VIP
class TiketVIP extends Tiket with BisaDiskon {
  TiketVIP({
    required super.id,
    required super.nama,
    required super.harga,
    required super.stok,
    required super.deskripsi,
    required super.icon,
    required super.warna,
  });

  @override
  double get diskonMaksimal => 20;

  @override
  String kategori() {
    return 'VIP';
  }
}

// INHERITANCE - TIKET BISA DISKON
class TiketKhusus extends Tiket with BisaDiskon {
  TiketKhusus({
    required super.id,
    required super.nama,
    required super.harga,
    required super.stok,
    required super.deskripsi,
    required super.icon,
    required super.warna,
  });

  @override
  double get diskonMaksimal => 15;

  @override
  String kategori() {
    return 'BisaDiskon';
  }
}

// MODEL PESANAN
class Pesanan {
  final String kode;
  final String namaTiket;
  final String kategori;
  final int jumlah;
  final double hargaSatuan;
  final double diskon;
  final double total;
  final DateTime tanggal;

  Pesanan({
    required this.kode,
    required this.namaTiket,
    required this.kategori,
    required this.jumlah,
    required this.hargaSatuan,
    required this.diskon,
    required this.total,
    required this.tanggal,
  });
}

// SERVICE
// FUTURE + ASYNC + AWAIT
class TiketService {
  final List<Tiket> _daftarTiket = [
    TiketEkonomi(
      id: 'EKO001',
      nama: 'Tiket Ekonomi',
      harga: 250000,
      stok: 10,
      deskripsi: 'Tiket perjalanan dengan harga ekonomis.',
      icon: Icons.confirmation_number,
      warna: green,
    ),

    TiketVIP(
      id: 'VIP001',
      nama: 'Tiket VIP',
      harga: 750000,
      stok: 7,
      deskripsi: 'Fasilitas lebih nyaman dengan layanan VIP.',
      icon: Icons.star,
      warna: orange,
    ),

    TiketKhusus(
      id: 'DSK001',
      nama: 'Tiket BisaDiskon',
      harga: 400000,
      stok: 8,
      deskripsi: 'Tiket khusus dengan promo diskon menarik.',
      icon: Icons.percent,
      warna: purple,
    ),
  ];

  final List<Pesanan> _riwayat = [];

  // Getter agar UI tidak mengakses private variable
  List<Tiket> get daftarTiket => List.unmodifiable(_daftarTiket);

  // AMBIL DAFTAR TIKET
  Future<List<Tiket>> ambilDaftarTiket() async {
    await Future.delayed(const Duration(seconds: 1));

    return List.unmodifiable(_daftarTiket);
  }

  // CARI TIKET
  Future<Tiket> cariTiket(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      return _daftarTiket.firstWhere((tiket) => tiket.id == id);
    } catch (_) {
      throw TiketTidakDitemukanException('Tiket $id tidak ditemukan.');
    }
  }

  // HITUNG DISKON
  Future<double> hitungDiskon(Tiket tiket, double persen) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (tiket is! BisaDiskon) {
      throw DiskonTidakValidException('Tiket ini tidak mendukung diskon.');
    }

    final diskon = tiket as BisaDiskon;

    return diskon.hitungHargaDiskon(persen);
  }

  // PESAN TIKET
  Future<Pesanan> pesanTiket(Tiket tiket, int jumlah) async {
    await Future.delayed(const Duration(seconds: 2));

    if (jumlah <= 0) {
      throw Exception('Jumlah tiket harus lebih dari 0.');
    }

    if (tiket.stok < jumlah) {
      throw StokHabisException(
        'Stok tidak cukup. '
        'Stok tersedia hanya ${tiket.stok} tiket.',
      );
    }

    double hargaAkhir = tiket.harga;
    double nilaiDiskon = 0;

    // Mixin digunakan di sini
    if (tiket is BisaDiskon) {
      final diskon = tiket as BisaDiskon;

      final persen = diskon.diskonMaksimal;

      hargaAkhir = diskon.hitungHargaDiskon(persen);

      nilaiDiskon = diskon.hitungNilaiDiskon(persen);
    }

    final total = hargaAkhir * jumlah;

    final pesanan = Pesanan(
      kode: _buatKodePesanan(),
      namaTiket: tiket.nama,
      kategori: tiket.kategori(),
      jumlah: jumlah,
      hargaSatuan: tiket.harga,
      diskon: nilaiDiskon,
      total: total,
      tanggal: DateTime.now(),
    );

    // Stok dikurangi setelah pemesanan berhasil
    tiket.stok -= jumlah;

    // Masukkan ke riwayat
    _riwayat.insert(0, pesanan);

    return pesanan;
  }

  // AMBIL RIWAYAT
  Future<List<Pesanan>> ambilRiwayat() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return List.unmodifiable(_riwayat);
  }

  // KODE PESANAN
  String _buatKodePesanan() {
    final random = Random();
    final angka = 100000 + random.nextInt(900000);

    return 'TKT-$angka';
  }
}

// MY APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulasi Pemesanan Tiket',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),

        scaffoldBackgroundColor: const Color(0xFFF5F7FB),

        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),
      ),

      home: const MainPage(),
    );
  }
}

// MAIN PAGE
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int halaman = 0;

  final TiketService service = TiketService();

  final List<String> judulHalaman = [
    'Beranda',
    'Daftar Tiket',
    'Hitung Diskon',
    'Pemesanan',
    'Riwayat',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      BerandaPage(
        service: service,
        bukaTiket: () {
          setState(() {
            halaman = 1;
          });
        },
      ),

      DaftarTiketPage(
        service: service,
        pesan: (tiket) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PemesananPage(service: service, tiketAwal: tiket),
            ),
          );
        },
      ),

      HitungDiskonPage(service: service),

      PemesananPage(service: service),

      RiwayatPage(service: service),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.confirmation_number),
            const SizedBox(width: 10),
            const Text(
              'Simulasi Pemesanan Tiket',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        actions: [
          if (MediaQuery.of(context).size.width > 700)
            ...List.generate(judulHalaman.length, (index) {
              return TextButton(
                onPressed: () {
                  setState(() {
                    halaman = index;
                  });
                },
                child: Text(
                  judulHalaman[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: halaman == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }),

          const SizedBox(width: 15),
        ],
      ),

      body: pages[halaman],

      bottomNavigationBar: MediaQuery.of(context).size.width <= 700
          ? NavigationBar(
              selectedIndex: halaman,

              onDestinationSelected: (index) {
                setState(() {
                  halaman = index;
                });
              },

              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.confirmation_number_outlined),
                  selectedIcon: Icon(Icons.confirmation_number),
                  label: 'Tiket',
                ),
                NavigationDestination(
                  icon: Icon(Icons.percent_outlined),
                  selectedIcon: Icon(Icons.percent),
                  label: 'Diskon',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: 'Pesanan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'Riwayat',
                ),
              ],
            )
          : null,
    );
  }
}

// BERANDA
class BerandaPage extends StatefulWidget {
  final TiketService service;
  final VoidCallback bukaTiket;

  const BerandaPage({
    super.key,
    required this.service,
    required this.bukaTiket,
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late StreamController<int> countdownController;

  late Stream<int> countdownStream;

  Timer? countdownTimer;

  int waktu = 180;

  @override
  void initState() {
    super.initState();

    // Broadcast agar aman ketika widget rebuild
    countdownController = StreamController<int>.broadcast();

    countdownStream = countdownController.stream;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (waktu > 0) {
        waktu--;
        countdownController.add(waktu);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    countdownController.close();

    super.dispose();
  }

  String waktuFormat(int totalDetik) {
    final jam = totalDetik ~/ 3600;

    final menit = (totalDetik % 3600) ~/ 60;

    final detik = totalDetik % 60;

    return '${jam.toString().padLeft(2, '0')} : '
        '${menit.toString().padLeft(2, '0')} : '
        '${detik.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),

      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // HERO
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(32),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1565C0),
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Selamat Datang!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                'Pesan tiket favoritmu sekarang ✈️',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),

                              const SizedBox(height: 20),

                              ElevatedButton.icon(
                                onPressed: widget.bukaTiket,

                                icon: const Icon(Icons.search),

                                label: const Text('Lihat Daftar Tiket'),

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (constraints.maxWidth > 600)
                          const Padding(
                            padding: EdgeInsets.only(right: 40),
                            child: Icon(
                              Icons.flight_takeoff,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // FITUR
              const Text(
                'Fitur Utama',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              GridView.extent(
                maxCrossAxisExtent: 380,

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                crossAxisSpacing: 15,
                mainAxisSpacing: 15,

                childAspectRatio: 2.1,

                children: [
                  fiturCard(
                    Icons.account_tree,
                    'Penerapan OOP',
                    'Abstract class, inheritance, '
                        'override dan mixin.',
                    green,
                  ),

                  fiturCard(
                    Icons.bolt,
                    'Async & Future',
                    'Future, async dan await '
                        'untuk proses data.',
                    orange,
                  ),

                  fiturCard(
                    Icons.security,
                    'Error Handling',
                    'try, catch, finally dan '
                        'custom exception.',
                    purple,
                  ),

                  fiturCard(
                    Icons.web,
                    'Flutter Web',
                    'Dapat dijalankan langsung '
                        'menggunakan Google Chrome.',
                    lightBlue,
                  ),

                  fiturCard(
                    Icons.timer,
                    'Promo Countdown',
                    'Countdown real-time menggunakan '
                        'StreamBuilder.',
                    Colors.deepOrange,
                  ),

                  fiturCard(
                    Icons.history,
                    'Riwayat Pesanan',
                    'Menyimpan pesanan yang '
                        'berhasil dilakukan.',
                    Colors.teal,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // PILIHAN TIKET
              const Text(
                'Pilihan Tiket',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              FutureBuilder<List<Tiket>>(
                future: widget.service.ambilDaftarTiket(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return errorBox(snapshot.error.toString());
                  }

                  final tiket = snapshot.data ?? [];

                  return GridView.extent(
                    maxCrossAxisExtent: 360,

                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,

                    childAspectRatio: 1.15,

                    children: tiket
                        .map(
                          (item) => tiketCard(
                            item,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PemesananPage(
                                    service: widget.service,
                                    tiketAwal: item,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 25),

              // COUNTDOWN
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(25),

                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),

                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: .1),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.timer,
                          color: primaryBlue,
                          size: 35,
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Waktu Tersisa Promo',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            StreamBuilder<int>(
                              stream: countdownStream,

                              builder: (context, snapshot) {
                                final waktuSekarang = snapshot.data ?? waktu;

                                return Text(
                                  waktuFormat(waktuSekarang),

                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),

                            const Text('Jangan lewatkan promo menarik!'),
                          ],
                        ),
                      ),

                      if (MediaQuery.of(context).size.width > 700)
                        const Expanded(
                          child: Text(
                            'Nikmati berbagai pilihan '
                            'tiket dengan harga dan '
                            'diskon terbaik.',
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // TENTANG
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Tentang Aplikasi',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Aplikasi ini merupakan simulasi '
                      'pemesanan tiket berbasis Flutter Web '
                      'dengan penerapan OOP, Inheritance, '
                      'Mixin, Future, Async/Await, '
                      'Error Handling dan StreamBuilder.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FITUR CARD
Widget fiturCard(IconData icon, String title, String description, Color color) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(18),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: color, size: 30),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// DAFTAR TIKET
class DaftarTiketPage extends StatelessWidget {
  final TiketService service;
  final Function(Tiket) pesan;

  const DaftarTiketPage({
    super.key,
    required this.service,
    required this.pesan,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),

      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'Daftar Tiket',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text('Pilih jenis tiket yang ingin Anda pesan.'),

              const SizedBox(height: 25),

              FutureBuilder<List<Tiket>>(
                future: service.ambilDaftarTiket(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return errorBox(snapshot.error.toString());
                  }

                  final data = snapshot.data ?? [];

                  return GridView.extent(
                    maxCrossAxisExtent: 380,

                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,

                    childAspectRatio: 1.15,

                    children: data
                        .map(
                          (tiket) => tiketCard(
                            tiket,
                            onPressed: () {
                              pesan(tiket);
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TIKET CARD
Widget tiketCard(Tiket tiket, {required VoidCallback onPressed}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),

                decoration: BoxDecoration(
                  color: tiket.warna.withValues(alpha: .1),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(tiket.icon, color: tiket.warna, size: 30),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Text(
                  tiket.nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(tiket.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis),

          const SizedBox(height: 12),

          Text(
            rupiah(tiket.harga),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: tiket.warna,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Icon(
                tiket.tersedia ? Icons.check_circle : Icons.cancel,

                size: 16,

                color: tiket.tersedia ? green : Colors.red,
              ),

              const SizedBox(width: 5),

              Text(
                '${tiket.statusStok} '
                '(${tiket.stok})',

                style: TextStyle(color: tiket.tersedia ? green : Colors.red),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: tiket.tersedia ? onPressed : null,

              icon: const Icon(Icons.shopping_cart),

              label: const Text('Pesan Sekarang'),

              style: ElevatedButton.styleFrom(
                backgroundColor: tiket.warna,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// HITUNG DISKON
class HitungDiskonPage extends StatefulWidget {
  final TiketService service;

  const HitungDiskonPage({super.key, required this.service});

  @override
  State<HitungDiskonPage> createState() => _HitungDiskonPageState();
}

class _HitungDiskonPageState extends State<HitungDiskonPage> {
  Tiket? tiket;

  final TextEditingController diskonController = TextEditingController(
    text: '10',
  );

  double? hargaAkhir;
  double? hemat;

  bool loading = false;

  Future<void> hitung() async {
    if (tiket == null) {
      showMessage(context, 'Pilih tiket terlebih dahulu.', Colors.orange);
      return;
    }

    final persen = double.tryParse(diskonController.text) ?? 0;

    setState(() {
      loading = true;
      hargaAkhir = null;
      hemat = null;
    });

    try {
      final hasil = await widget.service.hitungDiskon(tiket!, persen);

      if (!mounted) return;

      setState(() {
        hargaAkhir = hasil;
        hemat = tiket!.harga - hasil;
      });
    } catch (e) {
      if (!mounted) return;

      showMessage(context, e.toString(), Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    diskonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),

      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'Hitung Diskon',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text('Hitung harga tiket setelah mendapatkan diskon.'),

              const SizedBox(height: 25),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(25),

                  child: Column(
                    children: [
                      DropdownButtonFormField<Tiket>(
                        value: tiket,

                        decoration: const InputDecoration(
                          labelText: 'Pilih Tiket',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.confirmation_number),
                        ),

                        items: widget.service.daftarTiket
                            .map(
                              (item) => DropdownMenuItem<Tiket>(
                                value: item,
                                child: Text(item.nama),
                              ),
                            )
                            .toList(),

                        onChanged: loading
                            ? null
                            : (value) {
                                setState(() {
                                  tiket = value;
                                });
                              },
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: diskonController,

                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

                        decoration: const InputDecoration(
                          labelText: 'Persentase Diskon (%)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.percent),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton.icon(
                          onPressed: loading ? null : hitung,

                          icon: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.calculate),

                          label: Text(
                            loading ? 'Menghitung...' : 'Hitung Diskon',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (hargaAkhir != null) ...[
                const SizedBox(height: 25),

                Card(
                  color: const Color(0xFFE8F5E9),

                  child: Padding(
                    padding: const EdgeInsets.all(25),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Hasil Perhitungan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        resultRow('Harga Awal', rupiah(tiket!.harga)),

                        resultRow('Hemat', rupiah(hemat!)),

                        const Divider(),

                        resultRow(
                          'Total Bayar',
                          rupiah(hargaAkhir!),
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// PEMESANAN
class PemesananPage extends StatefulWidget {
  final TiketService service;
  final Tiket? tiketAwal;

  const PemesananPage({super.key, required this.service, this.tiketAwal});

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  Tiket? tiket;
  int jumlah = 1;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    tiket = widget.tiketAwal;
  }

  double get hargaSetelahDiskon {
    if (tiket == null) {
      return 0;
    }

    if (tiket is BisaDiskon) {
      final diskon = tiket as BisaDiskon;

      return diskon.hitungHargaDiskon(diskon.diskonMaksimal);
    }

    return tiket!.harga;
  }

  double get nilaiDiskon {
    if (tiket == null) {
      return 0;
    }

    return tiket!.harga - hargaSetelahDiskon;
  }

  double get total {
    return hargaSetelahDiskon * jumlah;
  }

  Future<void> pesanTiket() async {
    if (tiket == null) {
      showMessage(context, 'Silakan pilih tiket.', Colors.orange);
      return;
    }

    if (jumlah > tiket!.stok) {
      showMessage(context, 'Jumlah melebihi stok tiket.', Colors.red);
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final hasil = await widget.service.pesanTiket(tiket!, jumlah);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StatusPesananPage(pesanan: hasil)),
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(context, e.toString(), Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),

      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'Pemesanan Tiket',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text('Pilih tiket dan tentukan jumlah pemesanan.'),

              const SizedBox(height: 25),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(25),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      DropdownButtonFormField<Tiket>(
                        value: tiket,

                        decoration: const InputDecoration(
                          labelText: 'Jenis Tiket',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.confirmation_number),
                        ),

                        items: widget.service.daftarTiket
                            .map(
                              (item) => DropdownMenuItem<Tiket>(
                                value: item,
                                child: Text(item.nama),
                              ),
                            )
                            .toList(),

                        onChanged: loading
                            ? null
                            : (value) {
                                setState(() {
                                  tiket = value;
                                  jumlah = 1;
                                });
                              },
                      ),

                      const SizedBox(height: 25),

                      if (tiket != null)
                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            color: tiket!.warna.withValues(alpha: .08),

                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: Row(
                            children: [
                              Icon(tiket!.icon, color: tiket!.warna, size: 45),

                              const SizedBox(width: 20),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      tiket!.nama,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(tiket!.deskripsi),

                                    const SizedBox(height: 5),

                                    Text(
                                      'Stok tersedia: '
                                      '${tiket!.stok}',
                                      style: const TextStyle(
                                        color: green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 25),

                      const Text(
                        'Jumlah Tiket',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          IconButton.filled(
                            onPressed: loading || jumlah <= 1
                                ? null
                                : () {
                                    setState(() {
                                      jumlah--;
                                    });
                                  },
                            icon: const Icon(Icons.remove),
                          ),

                          const SizedBox(width: 25),

                          Text(
                            '$jumlah',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 25),

                          IconButton.filled(
                            onPressed:
                                loading ||
                                    tiket == null ||
                                    jumlah >= tiket!.stok
                                ? null
                                : () {
                                    setState(() {
                                      jumlah++;
                                    });
                                  },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),

                      const Divider(height: 40),

                      if (tiket != null) ...[
                        resultRow('Harga Satuan', rupiah(tiket!.harga)),

                        resultRow('Diskon', rupiah(nilaiDiskon)),

                        resultRow('Jumlah', '$jumlah tiket'),

                        const Divider(),

                        resultRow(
                          'Total Bayar',
                          rupiah(total),
                          highlight: true,
                        ),
                      ],

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,

                        height: 55,

                        child: ElevatedButton.icon(
                          onPressed: loading ? null : pesanTiket,

                          icon: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.shopping_cart_checkout),

                          label: Text(
                            loading ? 'Memproses Pesanan...' : 'Pesan Sekarang',
                          ),
                        ),
                      ),

                      if (loading)
                        const Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Center(
                            child: Text(
                              'Mohon tunggu sebentar...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// STATUS PESANAN
class StatusPesananPage extends StatelessWidget {
  final Pesanan pesanan;

  const StatusPesananPage({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Pemesanan')),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),

            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30),

                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(Icons.check, color: green, size: 60),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Pemesanan Berhasil!',
                      style: TextStyle(
                        color: green,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Terima kasih, tiket Anda '
                      'sudah dipesan.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 25),

                    detailRow('Kode Pesanan', pesanan.kode),

                    detailRow('Jenis Tiket', pesanan.namaTiket),

                    detailRow('Kategori', pesanan.kategori),

                    detailRow('Jumlah', '${pesanan.jumlah} tiket'),

                    detailRow('Diskon', rupiah(pesanan.diskon)),

                    detailRow('Total Bayar', rupiah(pesanan.total)),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,

                      height: 50,

                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(Icons.arrow_back),

                        label: const Text('Kembali'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// RIWAYAT
class RiwayatPage extends StatefulWidget {
  final TiketService service;

  const RiwayatPage({super.key, required this.service});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  late Future<List<Pesanan>> futureRiwayat;

  @override
  void initState() {
    super.initState();

    futureRiwayat = widget.service.ambilRiwayat();
  }

  void refresh() {
    setState(() {
      futureRiwayat = widget.service.ambilRiwayat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),

      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Riwayat Pemesanan',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text('Daftar tiket yang telah berhasil dipesan.'),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: refresh,
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              FutureBuilder<List<Pesanan>>(
                future: futureRiwayat,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return errorBox(snapshot.error.toString());
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return emptyBox();
                  }

                  return Column(
                    children: data
                        .map((pesanan) => riwayatCard(pesanan))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// RIWAYAT CARD
// ============================================================

Widget riwayatCard(Pesanan pesanan) {
  return Card(
    margin: const EdgeInsets.only(bottom: 15),

    child: Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: green.withValues(alpha: .1),

                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Icon(Icons.check_circle, color: green),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      pesanan.namaTiket,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      pesanan.kode,
                      style: const TextStyle(color: primaryBlue),
                    ),
                  ],
                ),
              ),

              Text(
                rupiah(pesanan.total),

                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'Kategori: '
                '${pesanan.kategori}',
              ),

              Text(
                'Jumlah: '
                '${pesanan.jumlah}',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// RESULT ROW
Widget resultRow(String label, String value, {bool highlight = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 18 : 15,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,

            style: TextStyle(
              fontSize: highlight ? 20 : 15,
              fontWeight: FontWeight.bold,
              color: highlight ? green : null,
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// DETAIL ROW
// ============================================================

Widget detailRow(String label, String value) {
  return Container(
    width: double.infinity,

    padding: const EdgeInsets.symmetric(vertical: 12),

    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
    ),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),

        const SizedBox(width: 20),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,

            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

// EMPTY BOX
Widget emptyBox() {
  return Container(
    width: double.infinity,

    padding: const EdgeInsets.all(50),

    child: Column(
      children: [
        Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),

        const SizedBox(height: 15),

        const Text(
          'Belum ada pesanan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 5),

        const Text(
          'Pesanan yang berhasil dibuat '
          'akan muncul di sini.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ERROR BOX
Widget errorBox(String message) {
  return Container(
    width: double.infinity,

    padding: const EdgeInsets.all(25),

    decoration: BoxDecoration(
      color: Colors.red.withValues(alpha: .08),

      borderRadius: BorderRadius.circular(15),
    ),

    child: Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 50),

        const SizedBox(height: 10),

        const Text(
          'Terjadi Kesalahan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 5),

        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}

// SNACKBAR
void showMessage(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
