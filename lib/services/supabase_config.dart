import 'package:supabase_flutter/supabase_flutter.dart';

// Shared Supabase project with A-level app.
// GCSE tables are prefixed with gcse_ to avoid conflicts.
const String supabaseUrl = 'https://ljmrisjnemabzidffewn.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqbXJpc2puZW1hYnppZGZmZXduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NDMzODEsImV4cCI6MjA4NTQxOTM4MX0.T7HJySU50z--LthkTyqeLKEpESZisfCuSjCV-fBtF9Y';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
