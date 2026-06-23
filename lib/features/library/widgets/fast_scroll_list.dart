import 'package:flutter/material.dart';

class FastScrollList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final String Function(T item) titleExtractor;

  const FastScrollList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.titleExtractor,
  });

  @override
  State<FastScrollList<T>> createState() => _FastScrollListState<T>();
}

class _FastScrollListState<T> extends State<FastScrollList<T>> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ#".split('');
  String _currentLetter = '';
  bool _isDragging = false;

  void _scrollToLetter(String letter) {
    if (widget.items.isEmpty) return;

    int targetIndex = -1;
    if (letter == '#') {
      // Find the first non-alphabet character
      targetIndex = widget.items.indexWhere((item) {
        final title = widget.titleExtractor(item);
        if (title.isEmpty) return true;
        final firstChar = title[0].toUpperCase();
        return !RegExp(r'[A-Z]').hasMatch(firstChar);
      });
    } else {
      targetIndex = widget.items.indexWhere((item) {
        final title = widget.titleExtractor(item);
        if (title.isEmpty) return false;
        return title[0].toUpperCase() == letter;
      });
    }

    if (targetIndex != -1) {
      // Assuming a fixed height per item for simplicity, typically around 72.0 for ListTile
      // For a perfectly accurate scroll with variable height, ScrollablePositionedList is needed,
      // but for this implementation we assume a standard height of 72.
      double offset = targetIndex * 72.0;
      if (offset > _scrollController.position.maxScrollExtent) {
        offset = _scrollController.position.maxScrollExtent;
      }
      _scrollController.jumpTo(offset);
      
      setState(() {
        _currentLetter = letter;
      });
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    setState(() {
      _isDragging = true;
    });
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.globalToLocal(details.globalPosition);
    
    // Calculate which letter we are hovering over
    final letterHeight = constraints.maxHeight / _alphabet.length;
    final index = (position.dy / letterHeight).clamp(0, _alphabet.length - 1).toInt();
    
    final newLetter = _alphabet[index];
    if (newLetter != _currentLetter) {
      _scrollToLetter(newLetter);
    }
  }

  void _onVerticalDragEnd() {
    setState(() {
      _isDragging = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                // Wrap in a SizedBox to enforce the 72.0 height assumed by the scroll math
                return SizedBox(
                  height: 72.0,
                  child: widget.itemBuilder(context, index, widget.items[index]),
                );
              },
            ),
            
            // Fast Scroll Bar
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 30,
              child: GestureDetector(
                onVerticalDragUpdate: (details) => _onVerticalDragUpdate(details, constraints),
                onVerticalDragDown: (details) => _onVerticalDragUpdate(
                  DragUpdateDetails(
                    globalPosition: details.globalPosition,
                    delta: Offset.zero,
                  ),
                  constraints,
                ),
                onVerticalDragEnd: (_) => _onVerticalDragEnd(),
                onVerticalDragCancel: _onVerticalDragEnd,
                child: Container(
                  color: Colors.transparent, // Catch taps
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _alphabet.map((letter) {
                      return Text(
                        letter,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _isDragging && _currentLetter == letter
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Large center overlay when dragging
            if (_isDragging && _currentLetter.isNotEmpty)
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _currentLetter,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
