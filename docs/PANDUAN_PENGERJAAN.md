# Panduan Pengerjaan Manual Responsi Flutter - CuacaKita

Dokumen ini memandu proses dari inisiasi Flutter dan GitHub, memasang kode starter, menjalankan aplikasi, menguji setiap fitur, memperbarui README, sampai merekam video penjelasan.

## 0. Persiapan

Pastikan perangkat memiliki:

- Flutter SDK dan Dart SDK.
- Android Studio beserta Android SDK, atau perangkat Android dengan USB debugging.
- VS Code dengan ekstensi Flutter dan Dart (opsional, tetapi memudahkan).
- Git.
- Koneksi internet untuk mengambil data dari Open-Meteo.

Buka PowerShell atau terminal, lalu periksa:

```bash
flutter --version
dart --version
git --version
flutter doctor -v
```

Selesaikan masalah utama yang ditampilkan `flutter doctor`, terutama Android toolchain apabila menjalankan aplikasi di Android.

## 1. Buat proyek Flutter baru

Pilih folder kerja, kemudian jalankan:

```bash
cd D:\praktikum\mobile
flutter create cuaca_kita
cd cuaca_kita
```

Sesuaikan folder `D:\praktikum\mobile` dengan lokasi kerja milikmu. Nama folder harus `cuaca_kita` agar cocok dengan nama package dalam `pubspec.yaml` starter.

Buka proyek:

```bash
code .
```

Jika perintah `code` belum tersedia, buka VS Code lalu pilih **File > Open Folder** dan pilih folder `cuaca_kita`.

## 2. Salin kode dari ZIP starter

1. Ekstrak `cuaca_kita_starter.zip`.
2. Buka folder hasil ekstrak.
3. Salin seluruh isi folder `cuaca_kita_starter` ke folder proyek hasil `flutter create`.
4. Pilih **Replace** ketika diminta menimpa `pubspec.yaml`, `analysis_options.yaml`, atau `.gitignore`.
5. Pastikan folder `android/`, `ios/`, `web/`, dan file konfigurasi yang dibuat Flutter tetap berada di proyek. Jangan menghapus folder platform tersebut.

Alternatif PowerShell (sesuaikan lokasi file ZIP yang sudah diekstrak):

```powershell
Copy-Item -Path "D:\Downloads\cuaca_kita_starter\*" -Destination "D:\praktikum\mobile\cuaca_kita" -Recurse -Force
```

## 3. Pastikan izin internet Android

Buka:

`android/app/src/main/AndroidManifest.xml`

Di dalam tag `<manifest>` dan sebelum tag `<application>`, pastikan terdapat:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Jangan menaruh baris permission tersebut di dalam `<application>`. Jangan mengganti isi manifest lainnya tanpa alasan.

## 4. Pasang dependency dan periksa kode

Jalankan di root proyek, yaitu folder yang berisi `pubspec.yaml`:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

Tujuan setiap perintah:

- `flutter clean`: menghapus hasil build lama.
- `flutter pub get`: mengunduh paket sesuai `pubspec.yaml` dan membuat `pubspec.lock`.
- `flutter analyze`: memeriksa masalah statis pada kode Dart.
- `flutter test`: menjalankan unit test model dan pemetaan kode cuaca.

Jangan lanjut merekam video sebelum masalah error pada analyze atau test diselesaikan. Warning perlu diperiksa, tetapi bedakan warning dari error.

## 5. Jalankan aplikasi

Periksa perangkat yang tersedia:

```bash
flutter devices
```

Jika memakai emulator:

1. Buka Android Studio.
2. Pilih **Device Manager**.
3. Jalankan emulator Android.
4. Kembali ke terminal dan pastikan perangkat terdeteksi.

Lalu jalankan:

```bash
flutter run
```

Untuk memilih perangkat tertentu, gunakan ID yang tampil dari `flutter devices`:

```bash
flutter run -d NAMA_ID_PERANGKAT
```

Lokasi awal aplikasi adalah Purwokerto. Nama dan koordinat lokasi awal dicari melalui Geocoding API, sedangkan seluruh data cuacanya diambil dari Weather Forecast API. Lokasi awal ini bukan data cuaca hardcoded.

## 6. Pahami alur implementasi sebelum demonstrasi

### A. Ketika aplikasi dibuka

1. `main.dart` menyiapkan `MultiProvider` dan dependency service.
2. `WeatherViewModel` menjalankan `loadInitialWeather()`.
3. `OpenMeteoService.searchCities('Purwokerto')` mengirim GET ke Geocoding API.
4. API mengembalikan data lokasi termasuk latitude dan longitude.
5. Aplikasi memakai koordinat tersebut untuk memanggil `fetchWeather()`.
6. Weather Forecast API mengembalikan JSON cuaca aktual dan prakiraan harian.
7. JSON dipetakan ke `WeatherData`, `CurrentWeather`, dan `DailyForecast`.
8. ViewModel mengubah state dan memanggil `notifyListeners()`.
9. `HomeScreen` menerima pembaruan melalui `Consumer<WeatherViewModel>`.

### B. Ketika pengguna mencari kota

1. Pengguna memasukkan minimal dua karakter nama kota di Search Screen.
2. Tombol cari atau tombol Search pada keyboard memanggil `SearchViewModel.search()`.
3. ViewModel meminta `OpenMeteoService.searchCities()`.
4. Service mengirim HTTP GET ke Geocoding API dan mem-parsing hasil menjadi `LocationModel`.
5. Search Screen menampilkan hasil yang benar-benar berasal dari API.
6. Ketika hasil dipilih, lokasi diteruskan ke `WeatherViewModel.loadWeather(location)`.
7. Weather Forecast API dipanggil memakai koordinat lokasi yang dipilih.
8. Home Screen menampilkan data kota tersebut.

### C. Ketika pengguna menyimpan favorit

1. Pengguna menekan ikon bintang pada salah satu lokasi.
2. `SearchViewModel.toggleFavorite()` menambah atau menghapus lokasi.
3. `FavoriteStorageService.saveFavorites()` mengubah objek lokasi menjadi JSON string.
4. `SharedPreferencesAsync` menyimpan daftar string secara lokal.
5. Saat Search Screen dibuka, `loadFavorites()` membaca data dan mengubah JSON kembali menjadi `LocationModel`.

## 7. Pengujian manual wajib

Lakukan satu per satu dan catat hasilnya. Jangan menyatakan pengujian berhasil sebelum benar-benar dicoba.

| No. | Skenario | Langkah | Hasil yang diharapkan |
|---|---|---|---|
| 1 | Pemuatan awal | Jalankan aplikasi dengan internet aktif | Loading muncul, kemudian cuaca Purwokerto tampil |
| 2 | Data aktual | Periksa suhu, kelembapan, angin, dan curah hujan | Nilai tampil dari respons Weather API |
| 3 | Prakiraan | Periksa bagian Prakiraan 7 Hari | Baris tanggal, suhu maksimum/minimum, dan peluang hujan tampil |
| 4 | Pencarian kota | Cari `Makassar` | Hasil lokasi dari Geocoding API tampil |
| 5 | Pilih hasil | Tekan salah satu hasil pencarian | Home menampilkan kota terpilih dan cuaca dari koordinatnya |
| 6 | Simpan favorit | Tekan ikon bintang pada hasil kota | Kota masuk bagian Lokasi Favorit |
| 7 | Hapus favorit | Tekan bintang pada lokasi favorit | Kota hilang dari daftar favorit |
| 8 | Persistensi | Simpan favorit, tutup aplikasi penuh, lalu jalankan lagi | Favorit masih tersimpan |
| 9 | Kota tidak ada | Cari nama yang tidak cocok, misalnya `KotaTidakAdaXYZ` | Pesan hasil tidak ditemukan tampil |
| 10 | Input terlalu pendek | Cari satu huruf | Pesan minimal dua karakter tampil |
| 11 | Error jaringan | Matikan koneksi saat meminta data | Pesan error dan tombol coba lagi tampil |
| 12 | Coba ulang | Aktifkan internet kembali lalu tekan coba lagi | Request berjalan dan data tampil bila API tersedia |

Untuk membuktikan request API, kamu juga dapat membuka DevTools/terminal Debug Console ketika aplikasi dijalankan. Jika diminta dosen, tunjukkan endpoint dan parameter yang dibangun pada `open_meteo_service.dart`. Jangan mengubah aplikasi agar mengisi data cuaca contoh ketika API gagal.

## 8. Ambil screenshot untuk README

Screenshot harus berasal dari aplikasi yang benar-benar berjalan.

1. Buka Home Screen dengan cuaca sudah tampil.
2. Ambil screenshot emulator/perangkat.
3. Simpan sebagai `docs/screenshots/home_screen.png`.
4. Buka Search Screen dan tampilkan hasil pencarian kota.
5. Ambil screenshot.
6. Simpan sebagai `docs/screenshots/search_screen.png`.
7. Pastikan kedua file tampil di bagian Screenshot README.

Cara screenshot emulator dapat memakai tombol screenshot pada jendela emulator atau fitur screenshot bawaan sistem operasi. Crop seperlunya, tetapi jangan mengubah nilai cuaca atau menambahkan data palsu.

## 9. Inisiasi repository GitHub

### A. Buat repository di GitHub

1. Masuk ke akun GitHub milikmu.
2. Tekan tombol **New repository**.
3. Isi nama repository, misalnya `responsi-flutter-cuaca-kita`.
4. Isi deskripsi: `Aplikasi informasi cuaca Flutter menggunakan Open-Meteo API dan MVVM`.
5. Pilih Public jika dosen perlu membuka repository tanpa undangan. Jika dosen meminta private, pilih Private dan undang akun dosen.
6. Untuk menghindari konflik file awal, jangan centang pembuatan README, `.gitignore`, atau License jika file tersebut sudah ada di proyek lokal.
7. Tekan **Create repository** dan salin URL HTTPS repository.

### B. Hubungkan proyek lokal

Jalankan perintah berikut dari root proyek:

```bash
git init
git add .
git commit -m "chore: initialize CuacaKita Flutter project"
git branch -M main
git remote add origin https://github.com/USERNAME/responsi-flutter-cuaca-kita.git
git push -u origin main
```

Ganti `USERNAME` dan URL dengan repository milikmu. Jika `git remote add origin` menyatakan remote sudah ada, periksa dengan `git remote -v`; jangan menambahkan remote kedua dengan nama sama.

Untuk memastikan file terkirim:

```bash
git status
git log --oneline
git remote -v
```

Buka repository melalui browser dan pastikan `lib/`, `test/`, `README.md`, `pubspec.yaml`, serta dokumentasi terlihat.

### C. Commit lanjutan yang rapi

Setelah commit awal, lakukan perubahan yang memang sudah selesai dan commit secara bermakna, misalnya:

```bash
git add lib/data lib/core
git commit -m "feat: integrate Open-Meteo API and weather models"

git add lib/features

git commit -m "feat: implement MVVM weather and location screens"

git add test

git commit -m "test: add weather model unit tests"

git add README.md docs

git commit -m "docs: add project guide and application screenshots"

git push
```

Jika semua file sudah terlanjur masuk dalam commit pertama, jangan membuat commit kosong hanya demi menambah jumlah commit. Commit tambahan harus berisi perubahan nyata.

## 10. Perbarui README dan verifikasi repository

Sebelum submit:

- Isi nama, NIM, program studi, dan tautan repository pada bagian Identitas Pengembang.
- Pastikan screenshot Home dan Search sudah ada.
- Pastikan instruksi menjalankan aplikasi benar.
- Pastikan README menjelaskan API dan MVVM.
- Pastikan `pubspec.lock` ikut masuk repository setelah `flutter pub get`.
- Pastikan folder `.dart_tool/` dan `build/` tidak ikut dikirim.
- Pastikan tidak ada file rahasia atau credential.
- Jalankan `git status`, commit perubahan terbaru, lalu `git push`.

## 11. Rekam video penjelasan kode

Baca naskah pada `docs/SCRIPT_VIDEO.md`. Rekomendasi urutan rekaman:

1. Perkenalan, nama/NIM, dan tujuan aplikasi.
2. Demonstrasi Home Screen.
3. Demonstrasi Search Screen dan pemilihan kota.
4. Demonstrasi penyimpanan favorit dan persistensi setelah aplikasi dibuka kembali.
5. Penjelasan struktur MVVM.
6. Penjelasan request Geocoding dan Weather Forecast API.
7. Penjelasan parsing JSON, state, loading/error, dan Local Storage.
8. Tunjukkan README, pengujian, dan repository GitHub.

Sebelum merekam, tutup notifikasi pribadi, pastikan nama/NIM yang benar, dan pastikan semua demo sudah diuji. Jangan membaca klaim fitur yang belum kamu buktikan.

## 12. Pengumpulan

PDF menyebutkan komponen pengumpulan berikut:

1. Link pengumpulan: https://forms.gle/vz5LUdPVZmJ2F5uKA
2. Source code melalui GitHub masing-masing.
3. Dokumentasi singkat struktur aplikasi, implementasi API, dan MVVM.
4. Screenshot setiap screen pada README.
5. Video penjelasan kode aplikasi.

Buka formulir asli dan periksa kolom/link yang diminta. PDF menyebut batas pengerjaan 26 November 2026 pukul 10.00; ikuti waktu resmi yang ditetapkan pengajar apabila ada pengumuman perubahan.
