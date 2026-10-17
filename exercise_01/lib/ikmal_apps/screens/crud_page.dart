import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../db/database_helper.dart';
import '../models/news_model.dart';
import '../widgets/app_image.dart';
import '../widgets/app_toast.dart';

/// Halaman Pengelolaan Data Berita (CRUD) untuk Ikmal_apps
/// Mendukung Create, Read, Update, Delete serta fitur browse gambar dari galeri/perangkat
/// yang otomatis disimpan ke dalam assets/images dan langsung tampil di UI.
class IkmalCrudPage extends StatefulWidget {
  final VoidCallback? onDataChanged;
  final bool isTab;

  const IkmalCrudPage({
    super.key,
    this.onDataChanged,
    this.isTab = false,
  });

  @override
  State<IkmalCrudPage> createState() => _IkmalCrudPageState();
}

class _IkmalCrudPageState extends State<IkmalCrudPage> {
  List<NewsModel> _newsList = [];
  bool _isLoading = true;

  /// Daftar aset gambar lokal yang tersedia untuk dipilih
  final List<String> _availableImages = [
    'assets/images/cover_berita.jpeg',
    'assets/images/kebakaran_hutan.jpg',
    'assets/images/kebakaran hutan.jpg',
    'assets/images/kabut_asap_ke_singapura.jpeg',
    'assets/images/sebaran_asap_lintas_negara.jpeg',
    'assets/images/malaysia_daring.webp',
    'assets/images/logo.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  /// READ: Mengambil seluruh berita dari database SQLite
  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
    });

    final data = await DatabaseHelper.instance.getAllNews();

    setState(() {
      _newsList = data;
      _isLoading = false;
    });
  }

  /// Browse gambar dari galeri/perangkat dan otomatis simpan ke assets/images
  Future<String?> _pickAndCopyImage(BuildContext dialogContext, StateSetter setDialogState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (pickedFile == null) return null;

    final fileName = pickedFile.name;
    final bytes = await pickedFile.readAsBytes();

    // 1. Simpan ke disk assets/images/$fileName jika di Desktop / Mobile
    if (!kIsWeb) {
      final possibleDirs = [
        Directory(r'i:\Mobile Proggraming\exercise_01\assets\images'),
        Directory('assets/images'),
        Directory('${Directory.current.path}/assets/images'),
      ];
      for (final dir in possibleDirs) {
        try {
          if (!dir.existsSync()) {
            dir.createSync(recursive: true);
          }
          final destFile = File('${dir.path}/$fileName');
          await destFile.writeAsBytes(bytes);
        } catch (e) {
          debugPrint('Catatan salin gambar ke ${dir.path}: $e');
        }
      }
    }

    // 2. Buat data URI Base64 bersih agar dapat tampil langsung di Web maupun Mobile tanpa perlu rebuild bundle
    final base64String = base64Encode(bytes).replaceAll(RegExp(r'\s+'), '');
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpeg';
    final imageUri = 'data:image/$ext;base64,$base64String';

    setDialogState(() {
      if (!_availableImages.contains(imageUri)) {
        _availableImages.insert(0, imageUri);
      }
    });

    if (mounted) {
      AppToast.show(context, 'Gambar "$fileName" berhasil dipilih dan disimpan!');
    }

    return imageUri;
  }

  /// CREATE / UPDATE: Menampilkan Modal Form untuk Tambah atau Edit Berita
  void _showFormDialog({NewsModel? existingNews}) {
    final bool isEdit = existingNews != null;
    final formKey = GlobalKey<FormState>();

    final judulController = TextEditingController(
      text: isEdit ? existingNews.judul : '',
    );
    final kategoriController = TextEditingController(
      text: isEdit ? existingNews.kategori : 'Lingkungan',
    );
    final penulisController = TextEditingController(
      text: isEdit ? existingNews.penulis : 'Muhammad Ikmal',
    );
    final isiController = TextEditingController(
      text: isEdit ? existingNews.isi : '',
    );

    if (isEdit && !_availableImages.contains(existingNews.gambar)) {
      _availableImages.insert(0, existingNews.gambar);
    }

    String selectedImage =
        isEdit ? existingNews.gambar : _availableImages.first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogContentContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isEdit ? 'Edit Berita (Update)' : 'Tambah Berita Baru (Create)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input Judul
                        TextFormField(
                          controller: judulController,
                          decoration: const InputDecoration(
                            labelText: 'Judul Berita',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Input Kategori
                        TextFormField(
                          controller: kategoriController,
                          decoration: const InputDecoration(
                            labelText: 'Kategori (contoh: Lingkungan/Nasional)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Input Penulis
                        TextFormField(
                          controller: penulisController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Penulis / Jurnalis',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Pilihan Asset Gambar Lokal & Browse File
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Gambar Berita:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // Tombol BROWSE GAMBAR
                            TextButton.icon(
                              onPressed: () async {
                                final newPath = await _pickAndCopyImage(dialogContext, setDialogState);
                                if (newPath != null) {
                                  setDialogState(() {
                                    selectedImage = newPath;
                                  });
                                }
                              },
                              icon: const Icon(Icons.add_photo_alternate, size: 18),
                              label: const Text('Browse Gambar', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Preview Gambar Terpilih
                        Container(
                          width: double.infinity,
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppImage(
                            imagePath: selectedImage,
                            borderRadius: BorderRadius.circular(8),
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Dropdown Pilihan Gambar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedImage,
                              items: _availableImages.map((imgPath) {
                                String label;
                                if (imgPath.startsWith('data:image')) {
                                  final browsedList = _availableImages.where((s) => s.startsWith('data:image')).toList();
                                  final num = browsedList.indexOf(imgPath) + 1;
                                  label = '[Gambar Baru #$num]';
                                } else {
                                  label = imgPath.split('/').last;
                                }
                                return DropdownMenuItem<String>(
                                  value: imgPath,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: AppImage(
                                          imagePath: imgPath,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          label,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedImage = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Input Isi Berita
                        TextFormField(
                          controller: isiController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Isi / Deskripsi Berita',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Wajib diisi'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final now = DateTime.now();
                    final formattedDate = '${now.day} Oktober ${now.year}';

                    if (isEdit) {
                      // UPDATE: Perbarui data di SQLite
                      final updated = existingNews.copyWith(
                        judul: judulController.text.trim(),
                        kategori: kategoriController.text.trim(),
                        penulis: penulisController.text.trim(),
                        gambar: selectedImage,
                        isi: isiController.text.trim(),
                      );
                      await DatabaseHelper.instance.updateNews(updated);
                    } else {
                      // CREATE: Tambahkan berita baru ke SQLite
                      final newNews = NewsModel(
                        judul: judulController.text.trim(),
                        kategori: kategoriController.text.trim(),
                        penulis: penulisController.text.trim(),
                        tanggal: formattedDate,
                        gambar: selectedImage,
                        isi: isiController.text.trim(),
                        isFavorite: false,
                      );
                      await DatabaseHelper.instance.insertNews(newNews);
                    }

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    _loadNews();
                    if (widget.onDataChanged != null) {
                      widget.onDataChanged!();
                    }
                    if (!mounted) return;
                    AppToast.show(
                      context,
                      isEdit ? 'Berita berhasil diperbarui!' : 'Berita baru berhasil ditambahkan!',
                    );
                  },
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// DELETE: Menghapus berita dengan dialog konfirmasi
  void _confirmDelete(NewsModel news) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Hapus Berita'),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus berita:\n"${news.judul}"?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (news.id != null) {
                  await DatabaseHelper.instance.deleteNews(news.id!);
                  if (mounted) {
                    AppToast.show(context, 'Berita berhasil dihapus!');
                  }
                  _loadNews();
                  if (widget.onDataChanged != null) {
                    widget.onDataChanged!();
                  }
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _newsList.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada data berita.\nKlik tombol + di bawah untuk menambah data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: 80,
                ),
                itemCount: _newsList.length,
                itemBuilder: (context, index) {
                  final item = _newsList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: AppImage(
                        imagePath: item.gambar,
                        width: 65,
                        height: 65,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        item.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${item.kategori} • Oleh ${item.penulis}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol UPDATE
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                            tooltip: 'Edit Berita',
                            onPressed: () => _showFormDialog(existingNews: item),
                          ),
                          // Tombol DELETE
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Hapus Berita',
                            onPressed: () => _confirmDelete(item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      // Hanya tampilkan AppBar jika dibuka standalone (bukan sebagai tab di dalam Dashboard)
      appBar: widget.isTab
          ? null
          : AppBar(
              title: const Text(
                'Kelola Data Berita (CRUD)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Berita'),
      ),
      body: bodyContent,
    );
  }
}
