import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:campus/models/event.dart';
import 'package:campus/utils/date_formatter.dart';

class BannerCarousel extends StatefulWidget {
  final List<Event> featuredEvents;
  final Function(Event)? onEventTap;

  const BannerCarousel({
    super.key,
    required this.featuredEvents,
    this.onEventTap,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.featuredEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.featuredEvents.length,
          options: CarouselOptions(
            height: 220,
            aspectRatio: 16 / 9,
            viewportFraction: 0.9,
            initialPage: 0,
            enableInfiniteScroll: widget.featuredEvents.length > 1,
            reverse: false,
            autoPlay: widget.featuredEvents.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final event = widget.featuredEvents[index];
            return _buildBannerItem(context, theme, event);
          },
        ),
        if (widget.featuredEvents.length > 1) ...[
          const SizedBox(height: 12),
          _buildPageIndicator(theme),
        ],
      ],
    );
  }

  Widget _buildBannerItem(BuildContext context, ThemeData theme, Event event) {
    return GestureDetector(
      onTap: () => widget.onEventTap?.call(event),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              _buildBackgroundImage(event, theme),
              _buildGradientOverlay(),
              _buildEventContent(event, theme),
              _buildFeaturedBadge(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(Event event, ThemeData theme) {
    if (event.imageUrl != null) {
      return Image.network(
        event.imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildDefaultBackground(theme),
      );
    } else {
      return _buildDefaultBackground(theme);
    }
  }

  Widget _buildDefaultBackground(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event,
          size: 80,
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
          stops: const [0.4, 1.0],
        ),
      ),
    );
  }

  Widget _buildEventContent(Event event, ThemeData theme) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  DateFormatter.formatEventDateTime(
                    event.startTime,
                    event.endTime,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.location,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBadge(ThemeData theme) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 16, color: theme.colorScheme.onTertiary),
            const SizedBox(width: 4),
            Text(
              'Featured',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.featuredEvents.asMap().entries.map((entry) {
        final index = entry.key;
        final isActive = index == _currentIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
    );
  }
}
