import 'package:flutter/material.dart';

class PiAvatarPicker extends StatelessWidget {
  final ImageProvider<Object> avatar;
  final VoidCallback onPick;

  const PiAvatarPicker({
    super.key,
    required this.avatar,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(0.08),
                ),
              ],
            ),
            child: CircleAvatar(radius: 56, backgroundImage: avatar),
          ),
          GestureDetector(
            onTap: onPick,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF111827),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}