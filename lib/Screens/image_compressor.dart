import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import 'dart:typed_data';

class ImageCompressorScreen extends StatefulWidget {
  const ImageCompressorScreen({super.key});

  @override
  _ImageCompressorScreenState createState() => _ImageCompressorScreenState();
}

class _ImageCompressorScreenState extends State<ImageCompressorScreen> {
  File? _originalImage;
  File? _compressedImage;
  int? _originalSize;
  int? _compressedSize;
  double _compressionQuality = 85;
  bool _isCompressing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Image Compressor',
          style: TextStyle(color: Colors.white70),
        )),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[600]!, Colors.blue[50]!],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPickImageSection(),
              const SizedBox(height: 20),
              if (_originalImage != null) _buildCompressionSection(),
              if (_originalImage != null && _compressedImage != null)
                _buildComparisonSection(),
              if (_compressedImage != null) _buildDownloadSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickImageSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.image,
              size: 60,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 15),
            Text(
              'Select Image to Compress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompressionSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compression Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text('Quality: '),
                Expanded(
                  child: Slider(
                    value: _compressionQuality,
                    min: 10,
                    max: 100,
                    divisions: 18,
                    label: '${_compressionQuality.round()}%',
                    onChanged: (value) {
                      setState(() {
                        _compressionQuality = value;
                      });
                    },
                  ),
                ),
                Text('${_compressionQuality.round()}%'),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCompressing ? null : _compressImage,
                icon: _isCompressing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.compress),
                label:
                    Text(_isCompressing ? 'Compressing...' : 'Compress Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Original',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _originalImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatFileSize(_originalSize ?? 0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Compressed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _compressedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatFileSize(_compressedSize ?? 0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Space saved: ${_calculateCompressionRatio()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _downloadCompressedImage,
                icon: const Icon(Icons.download),
                label: const Text('Save to Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _originalImage = File(pickedFile.path);
          _compressedImage = null;
          _originalSize = null;
          _compressedSize = null;
        });
        _getOriginalFileSize();
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _getOriginalFileSize() async {
    if (_originalImage != null) {
      final int fileSize = await _originalImage!.length();
      setState(() {
        _originalSize = fileSize;
      });
    }
  }

  Future<void> _compressImage() async {
    if (_originalImage == null) return;

    setState(() {
      _isCompressing = true;
    });

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
        _originalImage!.absolute.path,
        quality: _compressionQuality.round(),
        format: CompressFormat.jpeg,
      );

      if (compressedBytes != null) {
        final File compressedFile = File(targetPath);
        await compressedFile.writeAsBytes(compressedBytes);

        setState(() {
          _compressedImage = compressedFile;
          _compressedSize = compressedBytes.length;
        });

        _showSnackBar('Image compressed successfully!');
      }
    } catch (e) {
      _showSnackBar('Error compressing image: $e');
    } finally {
      setState(() {
        _isCompressing = false;
      });
    }
  }

  Future<void> _downloadCompressedImage() async {
    if (_compressedImage == null) return;

    try {
      // Check if Gal has permission
      final bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final bool requestResult = await Gal.requestAccess();
        if (!requestResult) {
          _showSnackBar('Gallery access permission is required to save images');
          return;
        }
      }

      // Save to gallery using Gal
      await Gal.putImage(_compressedImage!.path, album: 'Compressed Images');
      _showSnackBar('Image saved to gallery successfully!');
    } catch (e) {
      _showSnackBar('Error saving image: $e');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _calculateCompressionRatio() {
    if (_originalSize == null || _compressedSize == null) return '0';
    final double ratio =
        ((_originalSize! - _compressedSize!) / _originalSize!) * 100;
    return ratio.toStringAsFixed(1);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[600],
      ),
    );
  }
}
