import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' as intl;

/// Detects the text direction from the first strong directional character.
/// Defaults to [TextDirection.rtl] if the text is empty or contains no strong characters.
TextDirection detectTextDirection(String? text) {
  if (text == null || text.trim().isEmpty) {
    return TextDirection.rtl;
  }

  // Check first strong character directionality using intl's Bidi utilities
  if (intl.Bidi.startsWithLtr(text)) {
    return TextDirection.ltr;
  }
  if (intl.Bidi.startsWithRtl(text)) {
    return TextDirection.rtl;
  }

  // Fallback to estimation
  final estimated = intl.Bidi.estimateDirectionOfText(text);
  if (estimated == intl.TextDirection.LTR) {
    return TextDirection.ltr;
  }

  return TextDirection.rtl;
}

/// Helper to convert a [TextDirection] to corresponding [TextAlign].
TextAlign textDirectionToTextAlign(TextDirection direction) {
  return direction == TextDirection.rtl ? TextAlign.right : TextAlign.left;
}

/// A text widget that automatically aligns and directs user-entered text
/// according to its first strong character.
class DirectionalText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const DirectionalText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final direction = detectTextDirection(text);
    return Text(
      text,
      textDirection: direction,
      textAlign: textDirectionToTextAlign(direction),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A Cupertino text field that dynamically updates its [textDirection]
/// and [textAlign] live as the user types based on the first strong character.
class DirectionalTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final TextStyle? placeholderStyle;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry padding;
  final BoxDecoration? decoration;
  final bool autofocus;

  const DirectionalTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.placeholderStyle,
    this.style,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.prefix,
    this.suffix,
    this.padding = const EdgeInsets.all(12),
    this.decoration,
    this.autofocus = false,
  });

  @override
  State<DirectionalTextField> createState() => _DirectionalTextFieldState();
}

class _DirectionalTextFieldState extends State<DirectionalTextField> {
  late TextEditingController _effectiveController;
  bool _createdInternalController = false;
  late TextDirection _currentDirection;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _effectiveController = TextEditingController();
      _createdInternalController = true;
    } else {
      _effectiveController = widget.controller!;
    }
    _currentDirection = detectTextDirection(_effectiveController.text);
    _effectiveController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(DirectionalTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_createdInternalController) {
        _effectiveController.dispose();
      }
      if (widget.controller == null) {
        _effectiveController = TextEditingController();
        _createdInternalController = true;
      } else {
        _effectiveController = widget.controller!;
        _createdInternalController = false;
      }
      _currentDirection = detectTextDirection(_effectiveController.text);
      _effectiveController.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    final newDirection = detectTextDirection(_effectiveController.text);
    if (newDirection != _currentDirection) {
      setState(() {
        _currentDirection = newDirection;
      });
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onTextChanged);
    if (_createdInternalController) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _effectiveController,
      textDirection: _currentDirection,
      textAlign: textDirectionToTextAlign(_currentDirection),
      placeholder: widget.placeholder,
      placeholderStyle: widget.placeholderStyle,
      style: widget.style,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      prefix: widget.prefix,
      suffix: widget.suffix,
      padding: widget.padding,
      decoration: widget.decoration,
      autofocus: widget.autofocus,
    );
  }
}
