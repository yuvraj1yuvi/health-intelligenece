import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF10B981), // Emerald
                const Color(0xFF047857), // Dark emerald
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Heart symbol
              Icon(
                Icons.favorite,
                color: Colors.white.withOpacity(0.9),
                size: size * 0.4,
              ),
              // Data visualization overlay
              Positioned(
                bottom: size * 0.15,
                right: size * 0.15,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.15,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B), // Amber accent
                    borderRadius: BorderRadius.circular(size * 0.02),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: size * 0.04,
                        height: size * 0.08,
                        color: const Color(0xFFEC4899).withOpacity(0.8), // Rose accent
                      ),
                    ),
                  ),
                ),
              ),
              // Intelligence spark
              Positioned(
                top: size * 0.15,
                left: size * 0.15,
                child: Container(
                  width: size * 0.15,
                  height: size * 0.15,
                  decoration: const BoxDecoration(
                    color: Color(0xFF06B6D4), // Cyan accent
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.insights,
                    color: Colors.white,
                    size: size * 0.08,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'Health\nIntelligence',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size * 0.15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF047857),
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
