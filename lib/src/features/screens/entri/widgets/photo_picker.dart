import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:welangflood/src/constants/color.dart';

class PhotoPicker extends StatefulWidget {
  final String hintText;
  final bool isRequired;
  final TextEditingController? controller;
  final bool isValid;
  final bool fitParentWidth;
  final Function(String)? onPhotoSelected;

  const PhotoPicker({
    super.key,
    required this.hintText,
    required this.isRequired,
    this.controller,
    required this.isValid,
    this.fitParentWidth = false,
    this.onPhotoSelected,
  });

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  String? _selectedPath;

  bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
  }

  String _fileNameFromPath(String path) {
    final unix = path.split('/').last;
    return unix.split('\\').last;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedPath = pickedFile.path;
          widget.controller?.text = pickedFile.path;
          widget.onPhotoSelected?.call(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Gagal memilih foto. Coba lagi.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _pickFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> _pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      final selectedPath = result?.files.single.path;
      if (selectedPath != null && selectedPath.isNotEmpty) {
        setState(() {
          _selectedPath = selectedPath;
          widget.controller?.text = selectedPath;
          widget.onPhotoSelected?.call(selectedPath);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Gagal memilih file. Coba lagi.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _showSourceOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('File'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeFile() {
    setState(() => _selectedPath = null);
    widget.controller?.clear();
    widget.onPhotoSelected?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final containerWidth = widget.fitParentWidth
        ? double.infinity
        : (screenSize.width >= 375 ? 375.0 : screenSize.width - 30.0);

    return Container(
      width: containerWidth,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hintText,
            style: const TextStyle(color: tPrimaryColor, fontSize: 16, fontFamily: 'Inter'),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Container(
            width: containerWidth,
            decoration: BoxDecoration(
              color: widget.isValid ? const Color(0xFFF9FAFB) : Colors.redAccent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: tPrimaryColor),
            ),
            child: _selectedPath != null
                ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: SizedBox(
                          width: containerWidth,
                          height: 160,
                          child: _isImagePath(_selectedPath!)
                              ? Image.file(
                                  File(_selectedPath!),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: const Color(0xFFF3F4F6),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.insert_drive_file, color: tPrimaryColor),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _fileNameFromPath(_selectedPath!),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: tPrimaryColor,
                                                fontFamily: 'Inter',
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 6, right: 6,
                        child: GestureDetector(
                          onTap: _removeFile,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    height: 56,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: _showSourceOptions,
                        color: tPrimaryColor,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
