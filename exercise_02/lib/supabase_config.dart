// Konfigurasi koneksi Supabase & helper header HTTP untuk REST API.
// Catatan: nilai URL & anon key di bawah sebaiknya diambil dari --dart-define
// saat build, contoh:
//   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
// Untuk sekarang masih const demi kesederhanaan tugas.

class SupabaseConfig {
  // ⚠️ Ganti dengan anon key asli dari dashboard Supabase
  // (Settings → API → Project API keys → anon public).
  // Anon key standar berformat JWT dan diawali "eyJ...".
  static const String supabaseUrl = 'https://knvnporwbvgmzqecgkoj.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_1fhF4VzJVShGFwLi7IMDBA_7hFEaL55';

  static const String todoEndpoint = '$supabaseUrl/rest/v1/todos';

  /// Header untuk request REST API yang MEMBUTUHKAN identitas user
  /// (Authorization memakai access token user, bukan anon key).
  /// Dipakai setelah login untuk operasi CRUD yang tunduk pada RLS.
  static Map<String, String> getHeader(String accessToken) => {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };
}
