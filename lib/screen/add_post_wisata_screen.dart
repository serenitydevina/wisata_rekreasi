import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:wisata_rekreasi/models/kota.dart';

class AddPostWisataScreen extends StatefulWidget {
  final Kota kota;
  const AddPostWisataScreen({super.key, required this.kota});
  @override
  _AddPostWisataScreenState createState() => _AddPostWisataScreenState();
}

class _AddPostWisataScreenState extends State<AddPostWisataScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  TimeOfDay _jamBuka = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _jamTutup = TimeOfDay(hour: 19, minute: 0);

  File? _image;
  bool _isLoading = false;
  bool _isLoadingAddress = false;
  Timer? _debounceTimer;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk auto search alamat
    _latitudeController.addListener(_onCoordinateChanged);
    _longitudeController.addListener(_onCoordinateChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _latitudeController.removeListener(_onCoordinateChanged);
    _longitudeController.removeListener(_onCoordinateChanged);
    super.dispose();
  }

  // Fungsi yang dipanggil ketika koordinat berubah
  void _onCoordinateChanged() {
    // Cancel timer sebelumnya jika ada
    _debounceTimer?.cancel();

    // Set timer baru dengan delay 1 detik untuk menghindari terlalu banyak request
    _debounceTimer = Timer(Duration(seconds: 1), () {
      if (_latitudeController.text.isNotEmpty &&
          _longitudeController.text.isNotEmpty) {
        _getAddressFromCoordinates();
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _jamBuka : _jamTutup,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _jamBuka = picked;
        } else {
          _jamTutup = picked;
        }
      });
    }
  }

  Future<void> _getAddressFromCoordinates() async {
    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
      return;
    }

    try {
      final lat = double.parse(_latitudeController.text);
      final lon = double.parse(_longitudeController.text);

      if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
        return;
      }

      setState(() => _isLoadingAddress = true);

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'WisataRekreasi/1.0 (fellyciacaroline_2327250010@mhs.mdp.ac.id)',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['display_name'] != null) {
          setState(() {
            _alamatController.text = data['display_name'];
          });
        } else {
          setState(() {
            _alamatController.text = 'Alamat tidak ditemukan';
          });
        }
      }
    } catch (e) {
      setState(() {
        _alamatController.text = 'Error mencari alamat';
      });
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _getCoordinatesFromAddress() async {
    if (_alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan alamat terlebih dahulu')),
      );
      return;
    }

    try {
      setState(() => _isLoadingAddress = true);

      final encodedAddress = Uri.encodeComponent(_alamatController.text);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$encodedAddress&limit=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'WisataRekreasi/1.0 (your-email@domain.com)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            _latitudeController.text = data[0]['lat'];
            _longitudeController.text = data[0]['lon'];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Koordinat berhasil ditemukan')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Koordinat tidak ditemukan')));
        }
      } else {
        throw Exception('Gagal mengambil data koordinat');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _submitData() async {
    if (_image == null ||
        _namaController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Semua field wajib diisi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User tidak ditemukan')));
        return;
      }

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final fullname = userDoc.data()?['fullname'] ?? 'Anonymous';

      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final newData = {
        'gambarUrl': base64Image,
        'nama': _namaController.text,
        'deskripsi': _deskripsiController.text,
        'jamBuka': _jamBuka.format(context),
        'jamTutup': _jamTutup.format(context),
        'latitude': double.parse(_latitudeController.text),
        'longitude': double.parse(_longitudeController.text),
        'alamat': _alamatController.text,
        'createdAt': DateTime.now().toIso8601String(),
        'fullname': fullname,
        'userId': uid,
        'kotaId': widget.kota.id,
      };

      await FirebaseFirestore.instance
          .collection('kotas')
          .doc(widget.kota.id)
          .collection('wisatas')
          .add(newData);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTimeButton(TimeOfDay time, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
      child: Text(
        DateFormat.jm().format(DateTime(0, 0, 0, time.hour, time.minute)),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Tambah Wisata",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey,
              child:
                  _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : Center(child: Text("No image selected")),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.upload, color: Colors.white),
              label: Text("Upload Foto", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(141, 153, 174, 1),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Nama Wisata",
                labelStyle: TextStyle(color: Color.fromRGBO(73, 69, 79, 1)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(121, 116, 126, 1.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Deskripsi",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(121, 116, 126, 1.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                Text("Jam Buka: "),
                _buildTimeButton(_jamBuka, () => _pickTime(true)),
                SizedBox(width: 16),
                Text("Jam Tutup: "),
                _buildTimeButton(_jamTutup, () => _pickTime(false)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latitudeController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Lintang",
                      labelStyle: TextStyle(
                        color: Color.fromRGBO(73, 69, 79, 1),
                      ),
                      prefixIcon: Icon(Icons.location_on),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(121, 116, 126, 1.0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _longitudeController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Bujur",
                      labelStyle: TextStyle(
                        color: Color.fromRGBO(73, 69, 79, 1),
                      ),
                      prefixIcon: Icon(Icons.location_on),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(121, 116, 126, 1.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _alamatController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Alamat",
                      labelStyle: TextStyle(
                        color: Color.fromRGBO(73, 69, 79, 1),
                      ),
                      prefixIcon: Icon(Icons.place),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(121, 116, 126, 1.0),
                        ),
                      ),
                      suffixIcon:
                          _isLoadingAddress
                              ? Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color.fromRGBO(141, 153, 174, 1),
                                  ),
                                ),
                              )
                              : null,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed:
                      _isLoadingAddress ? null : _getCoordinatesFromAddress,
                  icon: Icon(Icons.my_location, color: Colors.white),
                  label: Text(
                    "Cari Koordinat",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(141, 153, 174, 1),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Alamat akan otomatis dicari saat Anda menginput koordinat",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(141, 153, 174, 1),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
          ],
        ),
      ),
    );
  }
}
