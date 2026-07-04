import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/obat_model.dart';

final _db = Supabase.instance.client;

// ─────────────────────────────────────────────
// USER
// ─────────────────────────────────────────────

Future<void> simpanUserKeDB(UserAccount akun, String password) async {
  await _db.from('users').upsert({
    'nama': akun.nama,
    'email': akun.email,
    'inisial': akun.inisial,
    'role': akun.role,
    'password': password,
  }, onConflict: 'email');
}

Future<UserAccount?> fetchUserByEmail(String email) async {
  final res = await _db
      .from('users')
      .select()
      .eq('email', email.toLowerCase())
      .maybeSingle();
  if (res == null) return null;
  return UserAccount(
    nama: res['nama'],
    email: res['email'],
    inisial: res['inisial'] ?? '?',
    role: res['role'] ?? 'utama',
  );
}

Future<List<UserAccount>> fetchSemuaUser() async {
  final res = await _db.from('users').select();
  return (res as List).map((e) => UserAccount(
    nama: e['nama'],
    email: e['email'],
    inisial: e['inisial'] ?? '?',
    role: e['role'] ?? 'utama',
  )).toList();
}

Future<void> hapusUserDariDB(String email) async {
  await _db.from('users').delete().eq('email', email.toLowerCase());
}

Future<void> updateNamaUserDiDB(String email, String namaBaru) async {
  final inisial = namaBaru.trim().split(' ')
      .map((w) => w.isNotEmpty ? w[0] : '')
      .take(2).join().toUpperCase();
  await _db.from('users').update({
    'nama': namaBaru.trim(),
    'inisial': inisial,
  }).eq('email', email.toLowerCase());
}

Future<void> updatePasswordDiDB(String email, String passwordBaru) async {
  await _db.from('users').update({
    'password': passwordBaru,
  }).eq('email', email.toLowerCase());
}

Future<String> getPasswordDariDB(String email) async {
  final res = await _db
      .from('users')
      .select('password')
      .eq('email', email.toLowerCase())
      .maybeSingle();
  return res?['password'] ?? '';
}

// ─────────────────────────────────────────────
// KELUARGA
// ─────────────────────────────────────────────

Future<AnggotaKeluarga?> simpanAnggotaKeluargaKeDB({
  required String userEmail,
  required String nama,
  required String inisial,
  String hubungan = 'Anggota Keluarga',
  String? akunTerkaitEmail,
}) async {
  final user = await _db
      .from('users')
      .select('id')
      .eq('email', userEmail.toLowerCase())
      .maybeSingle();
  if (user == null) return null;

  String? akunTerkaitId;
  if (akunTerkaitEmail != null && akunTerkaitEmail.trim().isNotEmpty) {
    final akunTerkait = await _db
        .from('users')
        .select('id')
        .eq('email', akunTerkaitEmail.toLowerCase())
        .maybeSingle();
    akunTerkaitId = akunTerkait?['id'];
  }

  final res = await _db.from('keluarga').insert({
    'user_id': user['id'],
    'akun_terkait_id': akunTerkaitId,
    'nama': nama,
    'inisial': inisial,
    'hubungan': hubungan,
  }).select().single();

  return AnggotaKeluarga(
    id: res['id'],
    nama: res['nama'],
    inisial: res['inisial'],
    hubungan: res['hubungan'] ?? 'Anggota Keluarga',
    akunTerkaitEmail: akunTerkaitEmail,
  );
}

Future<List<AnggotaKeluarga>> fetchAnggotaKeluargaByUser(String userEmail) async {
  final user = await _db
      .from('users')
      .select('id')
      .eq('email', userEmail.toLowerCase())
      .maybeSingle();
  if (user == null) return [];

  final res = await _db
      .from('keluarga')
      .select('*, akun_terkait:akun_terkait_id(email)')
      .eq('user_id', user['id'])
      .order('created_at');

  return (res as List).map((e) => AnggotaKeluarga(
    id: e['id'],
    nama: e['nama'],
    inisial: e['inisial'] ?? '?',
    hubungan: e['hubungan'] ?? 'Anggota Keluarga',
    akunTerkaitEmail: e['akun_terkait']?['email'],
  )).toList();
}

Future<void> hapusAnggotaKeluargaDariDB(String id) async {
  await _db.from('keluarga').delete().eq('id', id);
}

// ─────────────────────────────────────────────
// OBAT
// ─────────────────────────────────────────────

Future<void> simpanObatKDB(Obat obat, String userEmail) async {
  final user = await _db
      .from('users')
      .select('id')
      .eq('email', userEmail.toLowerCase())
      .maybeSingle();
  if (user == null) return;

  await _db.from('obat').upsert({
    'id': obat.id,
    'user_id': user['id'],
    'anggota_id': obat.anggotaId,
    'nama': obat.nama,
    'dosis': obat.dosis,
    'waktu': obat.waktu,
    'instruksi': obat.instruksi,
    'stok_tablet': obat.stokTablet,
    'stok_hari_lagi': obat.stokHariLagi,
    'hari': obat.hari.toList(),
    'notif_minum': obat.notifMinum,
    'notif_stok': obat.notifStok,
    'tanggal_mulai': obat.tanggalMulai.toIso8601String().split('T').first,
  }, onConflict: 'id');
}

Future<List<Obat>> fetchObatByUser(String userEmail) async {
  final user = await _db
      .from('users')
      .select('id')
      .eq('email', userEmail.toLowerCase())
      .maybeSingle();
  if (user == null) return [];

  final res = await _db
      .from('obat')
      .select()
      .eq('user_id', user['id']);

  return (res as List).map((e) => Obat(
    id: e['id'],
    nama: e['nama'],
    dosis: e['dosis'] ?? '',
    waktu: e['waktu'] ?? '',
    instruksi: e['instruksi'] ?? '',
    status: MedStatus.belum,
    stokTablet: e['stok_tablet'] ?? 0,
    stokHariLagi: e['stok_hari_lagi'] ?? 0,
    hari: Set<String>.from(e['hari'] ?? []),
    notifMinum: e['notif_minum'] ?? true,
    notifStok: e['notif_stok'] ?? true,
    anggotaId: e['anggota_id'],
    tanggalMulai: e['tanggal_mulai'] != null
        ? DateTime.parse(e['tanggal_mulai'])
        : null,
  )).toList();
}

Future<void> hapusObatDariDB(String obatId) async {
  await _db.from('obat').delete().eq('id', obatId);
}

// ─────────────────────────────────────────────
// RIWAYAT MINUM
// ─────────────────────────────────────────────

Future<void> simpanRiwayatMinum({
  required String obatId,
  required String userEmail,
  required DateTime tanggal,
  required String status,
  String? anggotaId,
}) async {
  final user = await _db
      .from('users')
      .select('id')
      .eq('email', userEmail.toLowerCase())
      .maybeSingle();
  if (user == null) return;

  await _db.from('riwayat_minum').insert({
    'obat_id': obatId,
    'user_id': user['id'],
    'anggota_id': anggotaId,
    'tanggal': tanggal.toIso8601String().split('T').first,
    'status': status,
  });
}

/// Ambil riwayat minum. Filter opsional:
/// - Kalau [hanyaDiriSendiri] true -> cuma riwayat milik pemilik akun (anggota_id kosong)
/// - Kalau [anggotaId] diisi -> cuma riwayat anggota itu
/// - Kalau keduanya kosong -> semua riwayat (diri sendiri + semua anggota)
Future<List<Map<String, dynamic>>> fetchRiwayatByUser(
  String userEmail, {
  String? anggotaId,
  bool hanyaDiriSendiri = false,
}) async {
  final user = await _db
      .from('users')
      .select('id')
      .eq('email', userEmail.toLowerCase())
      .maybeSingle();
  if (user == null) return [];

  var query = _db
      .from('riwayat_minum')
      .select('*, obat(nama, dosis), keluarga:anggota_id(nama)')
      .eq('user_id', user['id']);

  if (hanyaDiriSendiri) {
    query = query.filter('anggota_id', 'is', null);
  } else if (anggotaId != null) {
    query = query.eq('anggota_id', anggotaId);
  }

  final res = await query.order('tanggal', ascending: false);
  return List<Map<String, dynamic>>.from(res);
}