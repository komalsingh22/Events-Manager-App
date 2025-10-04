import 'package:flutter/material.dart';
import 'package:campus/utils/constants.dart';

class SearchFilterBar extends StatefulWidget {
  final String? searchQuery;
  final String? selectedCategory;
  final DateTimeRange? dateRange;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String?>? onCategoryChanged;
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;
  final VoidCallback? onClearFilters;

  const SearchFilterBar({
    super.key,
    this.searchQuery,
    this.selectedCategory,
    this.dateRange,
    this.onSearchChanged,
    this.onCategoryChanged,
    this.onDateRangeChanged,
    this.onClearFilters,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchField(theme),
          const SizedBox(height: 16),
          _buildFilterChips(theme),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 12),
            _buildClearFiltersButton(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged?.call('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(theme),
                const SizedBox(width: 8),
                _buildDateChip(theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    final isSelected = widget.selectedCategory != null;

    return FilterChip(
      label: Text(
        widget.selectedCategory ?? 'Category',
        style: theme.textTheme.labelMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        _showCategoryDialog();
      },
      backgroundColor: theme.colorScheme.surfaceContainer,
      selectedColor: theme.colorScheme.primary,
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.2),
      ),
      avatar: Icon(
        Icons.category,
        size: 18,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildDateChip(ThemeData theme) {
    final isSelected = widget.dateRange != null;

    String chipText = 'Date';
    if (widget.dateRange != null) {
      final start = widget.dateRange!.start;
      final end = widget.dateRange!.end;
      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        chipText = '${start.day}/${start.month}/${start.year}';
      } else {
        chipText = '${start.day}/${start.month} - ${end.day}/${end.month}';
      }
    }

    return FilterChip(
      label: Text(
        chipText,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        _showDateRangePicker();
      },
      backgroundColor: theme.colorScheme.surfaceContainer,
      selectedColor: theme.colorScheme.primary,
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.2),
      ),
      avatar: Icon(
        Icons.calendar_today,
        size: 18,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildClearFiltersButton(ThemeData theme) {
    return TextButton.icon(
      onPressed: widget.onClearFilters,
      icon: Icon(Icons.clear_all, size: 18, color: theme.colorScheme.error),
      label: Text(
        'Clear Filters',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return widget.selectedCategory != null ||
        widget.dateRange != null ||
        (widget.searchQuery != null && widget.searchQuery!.isNotEmpty);
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('All Categories'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: widget.selectedCategory,
                  onChanged: (value) {
                    widget.onCategoryChanged?.call(value);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  widget.onCategoryChanged?.call(null);
                  Navigator.pop(context);
                },
              ),
              ...EventCategories.all.map(
                (category) => ListTile(
                  title: Text(category),
                  leading: Radio<String?>(
                    value: category,
                    groupValue: widget.selectedCategory,
                    onChanged: (value) {
                      widget.onCategoryChanged?.call(value);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    widget.onCategoryChanged?.call(category);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: widget.dateRange,
    );

    if (picked != null) {
      widget.onDateRangeChanged?.call(picked);
    }
  }
}
