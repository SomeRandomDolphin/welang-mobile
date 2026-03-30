import 'package:flutter/material.dart';
import 'package:welangflood/src/constants/color.dart';

class OutlinedForm extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final bool isRequired;
  final bool isValid;
  final IconData? icon;
  final Function(String)? onChanged; // Tambahkan parameter onChanged
  final bool fitParentWidth;

  const OutlinedForm({
    Key? key,
    required this.labelText,
    required this.hintText,
    this.controller,
    required this.isRequired,
    required this.isValid,
    this.icon,
    this.onChanged, // Tambahkan parameter onChanged
    this.fitParentWidth = false,
  }) : super(key: key);

  @override
  _OutlinedFormState createState() => _OutlinedFormState();
}

class _OutlinedFormState extends State<OutlinedForm> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: widget.fitParentWidth
          ? double.infinity
          : (screenSize.width >= 375 ? 375 : screenSize.width - 30),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hintText,
            style: const TextStyle(
              color: tPrimaryColor,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Container(
            height: screenSize.height * 0.055,
            decoration: BoxDecoration(
              color: widget.isValid ? const Color(0xFFF9FAFB) : Colors.redAccent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: tPrimaryColor),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.controller,
                      obscureText: widget.icon == Icons.visibility ? _isObscure : false,
                      textAlign: TextAlign.left,
                      onChanged: widget.onChanged,
                      validator: (value) {
                        if (widget.isRequired && (value == null || value.isEmpty)) {
                          return 'This field is required';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: widget.labelText,
                        labelStyle: const TextStyle(
                          color: tSecondaryColor,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                        hintText: '',
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                  if (widget.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.icon == Icons.visibility) {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          }
                        },
                        child: Icon(widget.icon, color: tPrimaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


