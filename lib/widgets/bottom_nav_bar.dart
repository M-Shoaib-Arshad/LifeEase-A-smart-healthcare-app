import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showNotificationBadge;
  final int notificationCount;
  final bool showEmergencyButton;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.showEmergencyButton = false,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _emergencyController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _emergencyPulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _emergencyController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.18, // slightly reduced to avoid vertical overflow during bounce
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _emergencyPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25, // slightly reduced to keep within bar height
    ).animate(CurvedAnimation(
      parent: _emergencyController,
      curve: Curves.easeInOut,
    ));

    if (widget.showEmergencyButton) {
      _emergencyController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onTap(index);
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Emergency Alert'),
          ],
        ),
        content: const Text(
            'This will immediately alert emergency services and your emergency contacts. Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerEmergencyAlert();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Emergency Alert', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _triggerEmergencyAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.white),
            SizedBox(width: 8),
            Text('Emergency alert sent!'),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseHeight = widget.showEmergencyButton ? 90.0 : 70.0;

    // Clamp text scaling inside the bar so labels don’t grow and cause overflow
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.hardEdge, // ensure we don’t draw outside the bar
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Container(
              height: baseHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // slightly reduced vertical padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    isSelected: widget.currentIndex == 0,
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    index: 1,
                    isSelected: widget.currentIndex == 1,
                    showBadge: widget.showNotificationBadge && widget.notificationCount > 0,
                    badgeCount: widget.notificationCount,
                  ),
                  if (widget.showEmergencyButton) _buildEmergencyButton(),
                  _buildNavItem(
                    icon: Icons.calendar_month,
                    label: 'Schedule',
                    index: 2,
                    isSelected: widget.currentIndex == 2,
                  ),
                  _buildNavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    index: 3,
                    isSelected: widget.currentIndex == 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // slightly reduced
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  alignment: Alignment.center, // center the scale
                  scale: isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade600 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                ),
                if (showBadge && badgeCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2), // slightly reduced spacing
            // FittedBox ensures the label never overflows vertically
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 8,
                height: 1.0, // tighter line height
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '',
                  // will be replaced below
                ),
              ),
            ),
          ],
        ),
      ),
    ).buildLabel(label);
  }

  Widget _buildEmergencyButton() {
    return GestureDetector(
      onTap: _showEmergencyDialog,
      child: AnimatedBuilder(
        animation: _emergencyPulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            alignment: Alignment.center,
            scale: _emergencyPulseAnimation.value,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.red.shade600,
                    Colors.red.shade800,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade300.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emergency,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Small extension to keep label injection clean without changing your structure above
extension _NavLabel on Widget {
  Widget buildLabel(String label) {
    return Builder(
      builder: (context) {
        // Replace the placeholder FittedBox in the AnimatedDefaultTextStyle above with the actual label.
        // We wrap the label with FittedBox to prevent overflow for large text scales.
        return _ReplaceChild(
          parent: this,
          replacement: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label),
          ),
        );
      },
    );
  }
}

// Helper widget to replace the last child (the label) without restructuring everything above.
// You can also inline the label directly if you prefer simpler code.
class _ReplaceChild extends StatelessWidget {
  final Widget parent;
  final Widget replacement;

  const _ReplaceChild({required this.parent, required this.replacement});

  @override
  Widget build(BuildContext context) {
    // The parent here is the GestureDetector -> AnimatedContainer -> Column.
    // We rebuild the Column with the replacement label. If you prefer, you can
    // remove this helper and inline FittedBox(Text(label)) directly where the label sits.
    if (parent is GestureDetector) {
      final gd = parent as GestureDetector;
      final animated = gd.child as AnimatedContainer;
      final column = animated.child as Column;
      final children = List<Widget>.from(column.children);
      // Replace the last child (label) with replacement
      children[children.length - 1] = (column.children.last is AnimatedDefaultTextStyle)
          ? AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: (column.children.last as AnimatedDefaultTextStyle).style!,
        child: replacement,
      )
          : replacement;

      return GestureDetector(
        onTap: gd.onTap,
        child: AnimatedContainer(
          duration: animated.duration,
          padding: animated.padding,
          decoration: animated.decoration,
          child: Column(
            mainAxisSize: column.mainAxisSize,
            children: children,
          ),
        ),
      );
    }
    return parent;
  }
}