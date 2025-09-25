import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url =
      "https://goxvvylwgjzhicfbdzck.supabase.co"; // 👈 ของคุณ
  static const String anonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdveHZ2eWx3Z2p6aGljZmJkemNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg4MTk2MjYsImV4cCI6MjA3NDM5NTYyNn0.TprhUmPFIs0GFnT43YAGn4JAPfw_-KQorfxj1BBd3II"; // 👈 copy จาก Supabase > API Keys

  static final client = SupabaseClient(url, anonKey);
}
