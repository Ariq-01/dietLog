import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Dark rounded input bar with image-upload, text field and animated send button.
/// - [onSend] is called with the trimmed text when send is tapped.
/// - [onImageTap] is called when the image icon is tapped.
/// Logic for both callbacks is intentionally left to the caller.
class BottomNavBarWidget extends StatefulWidget {
  final ValueChanged<String>? onSend;
  final VoidCallback? onImageTap;

  const BottomNavBarWidget({super.key, this.onSend, this.onImageTap});

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Image upload icon ────────────────────────────────────────
          Tooltip(
            message: 'Attach image',
            child: GestureDetector(
              onTap: widget.onImageTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 9, right: 4),
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.bottomNavIcon.withValues(alpha: 0.45),
                  size: 22,
                ),
              ),
            ),
          ),

          // ── Text field ───────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.bottomNavIcon,
                height: 1.45,
              ),
              decoration: InputDecoration(
                hintText: 'Write something...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.bottomNavIcon.withValues(alpha: 0.35),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
              cursorColor: AppColors.bottomNavIcon,
              cursorWidth: 1.5,
            ),
          ),

          const SizedBox(width: 6),

          // ── Send button ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: GestureDetector(
              onTap: _hasText ? _handleSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasText
                      ? AppColors.bottomNavIcon
                      : Colors.transparent,
                  border: _hasText
                      ? null
                      : Border.all(
                          color: AppColors.bottomNavIcon.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                ),
                child: AnimatedScale(
                  scale: _hasText ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 18,
                    color: _hasText
                        ? AppColors.bottomNavBackground
                        : AppColors.bottomNavIcon.withValues(alpha: 0.3),
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
