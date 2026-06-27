
// Opción 1: Widget Expandible con Animación Manual (Control Total)

import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class ExpandableInfoSection extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool initiallyExpanded;

  const ExpandableInfoSection({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableInfoSection> createState() => _ExpandableInfoSectionState();
}

class _ExpandableInfoSectionState extends State<ExpandableInfoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // Media vuelta (180 grados)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header tappeable
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpand,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: AppThemeHSL.accentGold, size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Icono de expansión animado
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Contenido expandible
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
Opción 1 - Control total
ExpandableInfoSection(
  label: "INFORMACIÓN DE RECURRENCIA",
  value: "Esta es una transacción...",
  icon: Icons.info_outline_rounded,
  initiallyExpanded: false,
)
 */


// Opción 2: Versión Simplificada con AnimationController reutilizable

class AnimatedExpandableSection extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Duration duration;
  final Curve curve;

  const AnimatedExpandableSection({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedExpandableSection> createState() =>
      _AnimatedExpandableSectionState();
}

class _AnimatedExpandableSectionState extends State<AnimatedExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _iconAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.icon, color: AppThemeHSL.accentGold, size: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _iconAnimation,
                    color: Colors.white54,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightAnimation.value,
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  widget.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
Opción 2 - Animación simplificada
AnimatedExpandableSection(
  label: "INFORMACIÓN DE RECURRENCIA",
  value: "Esta es una transacción...",
  icon: Icons.info_outline_rounded,
  duration: Duration(milliseconds: 400), // Opcional
  curve: Curves.easeOutCubic, // Opcional
)
*/