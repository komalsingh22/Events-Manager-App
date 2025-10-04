import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.bottom,
  }) : assert(
         title != null || titleWidget != null,
         'Either title or titleWidget must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title:
          titleWidget ??
          Text(
            title!,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: foregroundColor ?? theme.appBarTheme.foregroundColor,
            ),
          ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation,
      bottom: bottom,
      automaticallyImplyLeading: leading == null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final TextEditingController? controller;

  const SearchAppBar({
    super.key,
    this.hintText = 'Search events...',
    this.onSearch,
    this.onFilterTap,
    this.showFilter = true,
    this.controller,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      title: Container(
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: TextField(
          controller: _controller,
          onChanged: (value) {
            widget.onSearch?.call(value);
          },
          onTap: () {
            setState(() {
              _isSearching = true;
            });
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            suffixIcon: _isSearching && _controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _controller.clear();
                      widget.onSearch?.call('');
                      setState(() {
                        _isSearching = false;
                      });
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
      ),
      actions: widget.showFilter
          ? [
              IconButton(
                onPressed: widget.onFilterTap,
                icon: Icon(Icons.tune, color: theme.colorScheme.primary),
                tooltip: 'Filter',
              ),
              const SizedBox(width: 8),
            ]
          : null,
    );
  }
}
