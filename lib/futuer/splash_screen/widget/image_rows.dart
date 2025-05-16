import 'package:flutter/material.dart';

class ImageRows extends StatelessWidget {
  const ImageRows({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -93,
      top: -68,
      child: Column(
        children: List.generate(3, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _placeholder(color: const Color(0xFFACA0CD)),
                SizedBox(width: 12),
                _networkImage(),
                SizedBox(width: 12),
                _placeholder(color: const Color(0xFFDC9497)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _placeholder({required Color color}) {
    return Container(
      width: 184,
      height: 319,
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _networkImage() {
    return Container(
      width: 184,
      height: 319,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: NetworkImage('https://placehold.co/184x319'),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
