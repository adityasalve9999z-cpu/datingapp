import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://eaanwwxdboicfduhnhea.supabase.co',
    anonKey: 'sb_publishable_vRt1n7IEv3n6-F2WXaLJPw_wTKlXB9T',
  );
  runApp(MyApp());
}