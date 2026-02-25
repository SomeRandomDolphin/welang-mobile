import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:welangflood/src/constants/color.dart';

class PhotoPicker extends StatefulWidget {
  final String hintText;
  final bool isRequired;
  final TextEditingController? controller;
  final bool isValid;
  final Function(String)? onPhotoSelected;

  const PhotoPicker({
    super.key,
    required this.hintText,
    required this.isRequired,
    this.controller,
    required this.isValid,
    this.onPhotoSelected,
  });

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  XFile? _pickedFile;

  Future<void> _pickFile() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
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

  void _removeFile() {
    setState(() => _pickedFile = null);
    widget.controller?.clear();
    widget.onPhotoSelected?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final containerWidth = screenSize.width >= 375 ? 375.0 : screenSize.width - 30.0;

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
            child: _pickedFile != null
                ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      // Fixed-height thumbnail — won't overflow
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: SizedBox(
                          width: containerWidth,
                          height: 160,
                          child: Image.file(
                            File(_pickedFile!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Remove button
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
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _pickFile,
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