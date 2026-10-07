import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _mailController = TextEditingController();
  final _hpController = TextEditingController();

  String? _jenisKelamin;

  final Map<String, bool> _hobi = {
    'Membaca': false,
    'Olahraga': false,
    'Musik': false,
    'Traveling': false,
    'Gaming': false,
  };

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _mailController.dispose();
    _hpController.dispose();
    super.dispose();
  }

  String? _validateNama(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Nama lengkap wajib diisi';
    if (value.trim().length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  String? _validateNim(String? value) {
    if (value == null || value.trim().isEmpty) return 'NIM wajib diisi';
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim()))
      return 'NIM hanya boleh angka';
    if (value.trim().length < 8) return 'NIM minimal 8 digit';
    return null;
  }

  String? _validatmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'mail wajib diisi';
    final mailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!mailRegex.hasMatch(value.trim())) return 'Format mail tidak valid';
    return null;
  }

  String? _validateHp(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nomor HP wajib diisi';
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim()))
      return 'Nomor HP hanya boleh angka';
    if (value.trim().length < 10 || value.trim().length > 13) {
      return 'Nomor HP harus 10-13 digit';
    }
    return null;
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      _showToast('Mohon lengkapi data dengan benar!', isError: true);
      return;
    }
    if (_jenisKelamin == null) {
      _showToast('Pilih jenis kelamin terlebih dahulu!', isError: true);
      return;
    }
    final hobiTerpilih = _hobi.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (hobiTerpilih.isEmpty) {
      _showToast('Pilih minimal 1 hobi!', isError: true);
      return;
    }
    _showToast('Data berhasil disimpan!');
    _showResultModal(hobiTerpilih);
  }

  void _reset() {
    _formKey.currentState!.reset();
    _namaController.clear();
    _nimController.clear();
    _mailController.clear();
    _hpController.clear();
    setState(() {
      _jenisKelamin = null;
      _hobi.updateAll((key, value) => false);
    });
    _showToast('Form berhasil direset');
  }

  void _showToast(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);

    final topPadding = MediaQuery.of(context).padding.top;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding + 16, 
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isError ? Colors.red.shade700 : Colors.green.shade700,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  void _showResultModal(List<String> hobiTerpilih) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 8),
            Text('Hasil Biodata'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultRow('Nama Lengkap', _namaController.text),
              _buildResultRow('NIM', _nimController.text),
              _buildResultRow('mail', _mailController.text),
              _buildResultRow('Nomor HP', _hpController.text),
              _buildResultRow('Jenis Kelamin', _jenisKelamin ?? '-'),
              _buildResultRow('Hobi', hobiTerpilih.join(', ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(
              'Tutup',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Biodata Mahasiswa'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: _validateNama,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  hintText: 'Masukkan NIM',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: _validateNim,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'email',
                  hintText: 'contoh@mail.com',
                  prefixIcon: Icon(Icons.mail),
                  border: OutlineInputBorder(),
                ),
                validator: _validatmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hpController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor HP',
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: _validateHp,
              ),
              const SizedBox(height: 20),
              const Text(
                'Jenis Kelamin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Laki-laki'),
                      value: 'Laki-laki',
                      groupValue: _jenisKelamin,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) =>
                          setState(() => _jenisKelamin = value),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Perempuan'),
                      value: 'Perempuan',
                      groupValue: _jenisKelamin,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) =>
                          setState(() => _jenisKelamin = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Hobi (pilih minimal 1)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Column(
                children: _hobi.keys.map((namaHobi) {
                  return CheckboxListTile(
                    title: Text(namaHobi),
                    value: _hobi[namaHobi],
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) =>
                        setState(() => _hobi[namaHobi] = value ?? false),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _simpan,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
