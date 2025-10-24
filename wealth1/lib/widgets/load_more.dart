import 'package:flutter/material.dart';

class LoadMoreText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final String loadMoreText;
  final String showLessText;
  final Color buttonColor;

  const LoadMoreText({
    Key? key,
    required this.text,
    this.maxLines = 4,
    this.style,
    this.loadMoreText = 'See More',
    this.showLessText = 'See Less',
    this.buttonColor = Colors.grey,
  }) : super(key: key);

  @override
  _LoadMoreTextState createState() => _LoadMoreTextState();
}

class _LoadMoreTextState extends State<LoadMoreText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, size) {
            final span = TextSpan(text: widget.text, style: widget.style);
            final tp = TextPainter(
              text: span,
              maxLines: widget.maxLines,
              textDirection: TextDirection.ltr,
            );
            tp.layout(maxWidth: size.maxWidth);

            if (tp.didExceedMaxLines) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.text,
                    style: widget.style,
                    maxLines: _isExpanded ? null : widget.maxLines,
                    overflow: _isExpanded ? null : TextOverflow.ellipsis,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? widget.showLessText : widget.loadMoreText,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor:widget.buttonColor,
                        color: widget.buttonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Text(widget.text, style: widget.style);
            }
          },
        ),
      ],
    );
  }
}
