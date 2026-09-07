import 'package:flutter/material.dart';

class AnimalSearchToolbar extends StatefulWidget {
  final String initialQuery;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;
  final String hintText;

  const AnimalSearchToolbar({
    super.key,
    required this.initialQuery,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onSortTap,
    this.hintText = 'Szukaj po imieniu',
  });

  @override
  State<AnimalSearchToolbar> createState() => _AnimalSearchToolbarState();
}

class _AnimalSearchToolbarState extends State<AnimalSearchToolbar> {
  late final _controller = TextEditingController(text: widget.initialQuery);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onSearchChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clear,
                ),
              ),
              onChanged: (value) {
                widget.onSearchChanged(value);
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton.filledTonal(
                onPressed: widget.onFilterTap,
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtry',
              ),
              if (widget.hasActiveFilters)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            onPressed: widget.onSortTap,
            icon: const Icon(Icons.sort),
            tooltip: 'Sortuj',
          ),
        ],
      ),
    );
  }
}