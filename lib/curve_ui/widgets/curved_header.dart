import 'package:flutter/material.dart';

class CurvedHeader extends StatelessWidget {
  const CurvedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('asset/images/p4.jpg'),
            fit: BoxFit.fill,
            // colorFilter: ColorFilter.mode(
            //   Colors.transparent,
            //   BlendMode.srcOver,
            // ),
          ),
        ),

        //
        child: SafeArea(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                      children: [
                        TextSpan(
                          text: 'Zes',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'ty',
                          style: TextStyle(color: Color(0xFFFBD034)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);

    path.quadraticBezierTo(
      size.width / 2,
      size.height - 80,
      size.width,
      size.height,
    );

    path.lineTo(size.width, 00);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
