# Naskah Video Penjelasan Responsi Flutter - CuacaKita

Naskah ini dapat digunakan untuk video sekitar 6-8 menit. Sesuaikan bagian identitas dan jangan menyebut hasil pengujian yang belum benar-benar dilakukan.

## 1. Pembukaan dan tujuan aplikasi (00:00-00:35)

"Assalamualaikum warahmatullahi wabarakatuh. Perkenalkan, saya [nama], NIM [NIM], dari Program Studi [program studi]. Pada video ini saya akan menjelaskan aplikasi CuacaKita yang saya buat menggunakan Flutter dan bahasa pemrograman Dart.

Aplikasi ini digunakan untuk melihat informasi cuaca suatu kota. Data kota diperoleh melalui Open-Meteo Geocoding API, kemudian data cuaca aktual dan prakiraan hariannya diperoleh melalui Open-Meteo Weather Forecast API. Aplikasi menerapkan arsitektur Model-View-ViewModel atau MVVM, menggunakan Provider untuk state management, dan SharedPreferences untuk menyimpan lokasi favorit."

**Tampilkan:** halaman Home aplikasi.

## 2. Demonstrasi Home / Weather Screen (00:35-01:35)

"Ini adalah Home Screen atau Weather Screen. Pada bagian atas ditampilkan nama kota yang sedang dipilih. Di bagian kartu utama terdapat kondisi cuaca berdasarkan weather code dari API, suhu saat ini, dan suhu yang dirasakan.

Di bawahnya terdapat informasi kelembapan udara, kecepatan angin, curah hujan, dan suhu yang dirasakan. Kemudian di bagian prakiraan tujuh hari ditampilkan kondisi cuaca harian, suhu maksimum, suhu minimum, serta peluang hujan maksimum.

Nilai cuaca tidak saya tulis secara statis di dalam tampilan. Aplikasi meminta data dari Open-Meteo dan menampilkan hasil respons API. Jika request sedang berlangsung, aplikasi menampilkan loading. Jika gagal, aplikasi menyediakan pesan error dan tombol coba lagi."

**Tampilkan:** scroll halaman sampai prakiraan 7 hari. Tunjukkan sumber Open-Meteo dan zona waktu di bagian bawah.

## 3. Demonstrasi Search / Location Screen (01:35-02:30)

"Berikutnya adalah Search Screen. Pengguna dapat memasukkan nama kota, misalnya Makassar. Ketika tombol pencarian ditekan, aplikasi mengirim request GET ke Open-Meteo Geocoding API menggunakan nama kota sebagai parameter.

Respons API berisi daftar lokasi yang cocok, termasuk nama kota, wilayah administratif, negara, latitude, dan longitude. Hasil tersebut ditampilkan kepada pengguna. Ketika salah satu lokasi dipilih, aplikasi menggunakan koordinatnya untuk meminta cuaca melalui Weather Forecast API, lalu kembali ke Home Screen.

Pada setiap hasil pencarian juga terdapat ikon bintang untuk menyimpan lokasi sebagai favorit."

**Tampilkan:** cari `Makassar`, perlihatkan hasil, lalu pilih satu hasil yang muncul. Tunjukkan Home berubah ke kota pilihan.

## 4. Demonstrasi Local Storage (02:30-03:05)

"Saya juga menambahkan fitur lokasi favorit. Ketika ikon bintang ditekan, lokasi dimasukkan ke daftar favorit. Data lokasi diubah menjadi JSON string dan disimpan menggunakan SharedPreferencesAsync.

Saat Search Screen dibuka lagi, aplikasi membaca data yang tersimpan dan menampilkannya pada bagian Lokasi Favorit. Penyimpanan ini bersifat lokal pada perangkat, sehingga tidak membutuhkan akun pengguna atau database server."

**Tampilkan:** tandai satu kota sebagai favorit, kembali, buka Search lagi. Bila sudah diuji, tutup aplikasi penuh dan buka ulang untuk menunjukkan favorit tetap tersimpan.

## 5. Penjelasan struktur proyek dan MVVM (03:05-04:15)

"Selanjutnya saya jelaskan struktur proyek. File main.dart merupakan titik awal aplikasi. Pada file ini saya mendaftarkan service dan WeatherViewModel menggunakan MultiProvider.

Folder data/models berisi LocationModel untuk data lokasi, serta CurrentWeather, DailyForecast, dan WeatherData untuk data cuaca yang telah diubah dari JSON menjadi objek Dart.

Folder data/services berisi OpenMeteoService dan FavoriteStorageService. OpenMeteoService bertanggung jawab untuk melakukan HTTP GET dan mengolah respons API. FavoriteStorageService bertanggung jawab membaca dan menyimpan lokasi favorit di perangkat.

Folder features/home dan features/search memisahkan fitur berdasarkan halaman. Masing-masing memiliki folder views dan viewmodels. HomeScreen dan SearchScreen merupakan bagian View, yaitu tampilan yang berinteraksi dengan pengguna. WeatherViewModel mengelola data cuaca, lokasi terpilih, loading, dan error. SearchViewModel mengelola pencarian kota dan daftar favorit.

Pemisahan ini menerapkan MVVM: Model merepresentasikan data, View menampilkan UI, dan ViewModel menjadi penghubung yang mengelola state serta proses yang dibutuhkan View."

**Tampilkan:** buka Explorer VS Code, lalu tunjukkan file Model, Service, ViewModel, dan View.

## 6. Penjelasan implementasi Open-Meteo API (04:15-05:25)

"Integrasi API berada pada file open_meteo_service.dart. Untuk pencarian kota, aplikasi membuat URL Geocoding API dengan parameter name, count, language, dan format. Request dilakukan menggunakan metode GET dari package http. Setelah menerima respons dengan status HTTP 200, respons JSON dibaca dan setiap hasil dipetakan menjadi LocationModel.

Untuk mengambil cuaca, aplikasi memanggil endpoint Weather Forecast API menggunakan latitude dan longitude dari lokasi terpilih. Parameter current meminta suhu, kelembapan, suhu terasa, curah hujan, weather code, dan kecepatan angin. Parameter daily meminta weather code, suhu maksimum, suhu minimum, dan peluang hujan maksimum. Parameter timezone menggunakan auto dan forecast_days menggunakan tujuh.

Respons JSON kemudian diproses oleh WeatherData.fromJson pada weather_model.dart. Data current dipetakan ke CurrentWeather, sedangkan array daily dipetakan menjadi daftar DailyForecast. Dengan begitu, View tidak perlu membaca JSON mentah secara langsung."

**Tampilkan:** buka `open_meteo_service.dart`, tunjukkan dua method `searchCities` dan `fetchWeather`, lalu buka `weather_model.dart`.

## 7. State management dan kondisi error (05:25-06:10)

"State management menggunakan Provider dengan ChangeNotifier. Ketika data dimuat, ViewModel mengubah nilai isLoading dan memanggil notifyListeners. Consumer pada View mendengarkan perubahan tersebut sehingga tampilan dapat diperbarui.

Jika request berhasil, data cuaca disimpan pada state dan ditampilkan. Jika request gagal, ViewModel menyimpan pesan error. Pada Home Screen disediakan tombol coba lagi. Pada Search Screen tersedia kondisi loading dan pesan ketika lokasi tidak ditemukan.

Dengan cara ini, proses request tidak ditempatkan langsung di dalam widget tampilan, sehingga tanggung jawab View dan ViewModel tetap terpisah."

**Tampilkan:** `weather_view_model.dart`, `search_view_model.dart`, dan bagian Consumer pada Home Screen.

## 8. Pengujian, README, dan GitHub (06:10-07:00)

"Untuk pengujian, saya menambahkan unit test pada weather_model_test.dart untuk memeriksa parsing LocationModel, parsing data WeatherData, dan pemetaan weather code. Selain unit test, saya juga melakukan pengujian manual terhadap pencarian kota, pemilihan lokasi, tampilan prakiraan, penyimpanan favorit, serta kondisi ketika data gagal dimuat.

README pada repository berisi deskripsi aplikasi, fitur, screenshot, struktur folder, penjelasan MVVM, implementasi API, Local Storage, cara menjalankan aplikasi, dan referensi dokumentasi. Source code dan dokumentasi dapat dilihat melalui repository GitHub yang saya tampilkan."

**Tampilkan:** terminal `flutter test` jika sudah berhasil, README GitHub, screenshot, dan struktur repository.

## 9. Penutup (07:00-07:15)

"Demikian penjelasan aplikasi CuacaKita yang saya kembangkan untuk memenuhi Responsi Flutter. Aplikasi ini menerapkan Flutter, Dart, Material Design, MVVM, state management Provider, local storage, serta integrasi Open-Meteo API. Terima kasih. Wassalamualaikum warahmatullahi wabarakatuh."

---

## Checklist sebelum video dikirim

- [ ] Nama, NIM, dan program studi sudah benar.
- [ ] Aplikasi berjalan tanpa error fatal.
- [ ] Demonstrasi pencarian benar-benar menghasilkan hasil API.
- [ ] Kota yang dipilih benar-benar memuat cuaca berdasarkan koordinatnya.
- [ ] Favorit benar-benar tersimpan dan sudah diuji setelah aplikasi dibuka ulang.
- [ ] Penjelasan file sesuai dengan kode yang ditampilkan.
- [ ] Tidak ada klaim pengujian yang belum dilakukan.
- [ ] Video memperlihatkan aplikasi dan kode, bukan slide saja.
- [ ] Suara jelas, notifikasi pribadi tidak terlihat, dan link video dapat dibuka dosen.
