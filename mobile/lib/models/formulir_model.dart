// lib/models/formulir_model.dart
// ============================================================
// Model data untuk Survey Task dan Formulir Pendataan
// ============================================================

// ── Model Survey Task ─────────────────────────────────────────
class SurveyTask {
  final int     id;
  final String  nop;
  final String  namaWp;
  final String  alamatOp;
  final String  kdKecamatan;
  final String  kdKelurahan;
  final String  kdBlok;
  final String  noUrut;
  final String  kdJnsOp;
  final String  statusTask;     // pending | in_progress | completed
  final int?    assignedTo;
  final double? latitude;
  final double? longitude;
  final String? enumeratorName;
  final int?    formulirId;
  final String? formulirStatus; // draft | synced | failed

  const SurveyTask({
    required this.id,
    required this.nop,
    required this.namaWp,
    required this.alamatOp,
    required this.kdKecamatan,
    required this.kdKelurahan,
    required this.kdBlok,
    required this.noUrut,
    required this.kdJnsOp,
    required this.statusTask,
    this.assignedTo,
    this.latitude,
    this.longitude,
    this.enumeratorName,
    this.formulirId,
    this.formulirStatus,
  });

  factory SurveyTask.fromJson(Map<String, dynamic> json) {
    return SurveyTask(
      id:             json['id'] as int,
      nop:            json['nop'] as String,
      namaWp:         json['nama_wp'] as String,
      alamatOp:       json['alamat_op'] as String,
      kdKecamatan:    json['kd_kecamatan'] as String,
      kdKelurahan:    json['kd_kelurahan'] as String,
      kdBlok:         json['kd_blok'] as String,
      noUrut:         json['no_urut'] as String,
      kdJnsOp:        json['kd_jns_op'] as String,
      statusTask:     json['status_task'] as String,
      assignedTo:     json['assigned_to'] as int?,
      latitude:       json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude:      json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      enumeratorName: json['enumerator_name'] as String?,
      formulirId:     json['formulir_id'] as int?,
      formulirStatus: json['formulir_status'] as String?,
    );
  }
}

// ── Model Formulir Pendataan ──────────────────────────────────
class FormulirModel {
  final int?    id;
  final int     taskId;
  final String  nop;

  // Data tanah
  final double  luasBumi;
  final String? jenisBumi;
  final String? kondisiTanah;

  // Data bangunan
  final double  luasBangunan;
  final int     jumlahLantai;
  final int?    tahunDibangun;
  final String? kondisiBangunan;

  // Material
  final String? materialDinding;
  final String? materialAtap;
  final String? materialLantai;

  // Fasilitas
  final List<String> fasilitas;

  // Catatan & status
  final String? catatan;
  final String  statusSync; // draft | synced | failed

  // --- NEW FIELDS (Ditambahkan untuk melengkapi SPOP/LSPOP) ---
  final String? penggunaanBangunan;
  final String? statusKepemilikan;
  final int?    tahunRenovasi;
  final String? dayaListrik;
  final String? aksesJalan;
  final double? lebarJalan;
  final String? pagar;
  final String? sumberAir;
  final String? statusHunian;
  // -----------------------------------------------------------

  const FormulirModel({
    this.id,
    required this.taskId,
    required this.nop,
    required this.luasBumi,
    this.jenisBumi,
    this.kondisiTanah,
    required this.luasBangunan,
    required this.jumlahLantai,
    this.tahunDibangun,
    this.kondisiBangunan,
    this.materialDinding,
    this.materialAtap,
    this.materialLantai,
    this.fasilitas = const [],
    this.catatan,
    this.statusSync = 'draft',
    // --- NEW FIELDS ---
    this.penggunaanBangunan,
    this.statusKepemilikan,
    this.tahunRenovasi,
    this.dayaListrik,
    this.aksesJalan,
    this.lebarJalan,
    this.pagar,
    this.sumberAir,
    this.statusHunian,
    // ------------------
  });

  // Buat dari JSON response API
  factory FormulirModel.fromJson(Map<String, dynamic> json) {
    // Parse fasilitas (bisa berupa List atau String JSON)
    List<String> parsedFasilitas = [];
    final rawFasilitas = json['fasilitas'];
    if (rawFasilitas is List) {
      parsedFasilitas = rawFasilitas.map((e) => e.toString()).toList();
    }

    return FormulirModel(
      id:              json['id'] as int?,
      taskId:          json['task_id'] as int,
      nop:             json['nop'] as String,
      luasBumi:        double.tryParse(json['luas_bumi'].toString()) ?? 0,
      jenisBumi:       json['jenis_bumi'] as String?,
      kondisiTanah:    json['kondisi_tanah'] as String?,
      luasBangunan:    double.tryParse(json['luas_bangunan'].toString()) ?? 0,
      jumlahLantai:    json['jumlah_lantai'] as int? ?? 1,
      tahunDibangun:   json['tahun_dibangun'] as int?,
      kondisiBangunan: json['kondisi_bangunan'] as String?,
      materialDinding: json['material_dinding'] as String?,
      materialAtap:    json['material_atap'] as String?,
      materialLantai:  json['material_lantai'] as String?,
      fasilitas:       parsedFasilitas,
      catatan:         json['catatan'] as String?,
      statusSync:      json['status_sync'] as String? ?? 'draft',
      
      // --- NEW FIELDS (Parsing dari backend JSON) ---
      penggunaanBangunan: json['penggunaan_bangunan'] as String?,
      statusKepemilikan:  json['status_kepemilikan'] as String?,
      tahunRenovasi:      json['tahun_renovasi'] as int?,
      dayaListrik:        json['daya_listrik'] as String?,
      aksesJalan:         json['akses_jalan'] as String?,
      lebarJalan:         json['lebar_jalan'] != null ? double.tryParse(json['lebar_jalan'].toString()) : null,
      pagar:              json['pagar'] as String?,
      sumberAir:          json['sumber_air'] as String?,
      statusHunian:       json['status_hunian'] as String?,
      // ----------------------------------------------
    );
  }

  // Konversi ke Map untuk dikirim ke API
  Map<String, dynamic> toJson() => {
    'task_id':          taskId,
    'nop':              nop,
    'luas_bumi':        luasBumi,
    'jenis_bumi':       jenisBumi,
    'kondisi_tanah':    kondisiTanah,
    'luas_bangunan':    luasBangunan,
    'jumlah_lantai':    jumlahLantai,
    'tahun_dibangun':   tahunDibangun,
    'kondisi_bangunan': kondisiBangunan,
    'material_dinding': materialDinding,
    'material_atap':    materialAtap,
    'material_lantai':  materialLantai,
    'fasilitas':        fasilitas,
    'catatan':          catatan,
    // --- NEW FIELDS (Untuk dikirim ke API) ---
    'penggunaan_bangunan': penggunaanBangunan,
    'status_kepemilikan':  statusKepemilikan,
    'tahun_renovasi':      tahunRenovasi,
    'daya_listrik':        dayaListrik,
    'akses_jalan':         aksesJalan,
    'lebar_jalan':         lebarJalan,
    'pagar':               pagar,
    'sumber_air':          sumberAir,
    'status_hunian':       statusHunian,
    // -----------------------------------------
  };
}

// ── Model Stats Dashboard ─────────────────────────────────────
class TaskStats {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;

  const TaskStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) {
    return TaskStats(
      total:      json['total']       as int? ?? 0,
      pending:    json['pending']     as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      completed:  json['completed']   as int? ?? 0,
    );
  }
}