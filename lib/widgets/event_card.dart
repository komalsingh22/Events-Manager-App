import 'package:flutter/material.dart';
import 'package:campus/models/event.dart';
import 'package:campus/utils/date_formatter.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool showClub;
  final bool compact;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.showClub = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: compact
            ? _buildCompactCard(context, theme)
            : _buildFullCard(context, theme),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.imageUrl != null) _buildEventImage(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showClub && event.club != null) _buildClubInfo(theme),
              const SizedBox(height: 8),
              _buildTitle(theme),
              const SizedBox(height: 8),
              _buildDateTime(theme),
              const SizedBox(height: 8),
              _buildLocation(theme),
              const SizedBox(height: 12),
              _buildFooter(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCard(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (event.imageUrl != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(event.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.event,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatEventDateTime(
                    event.startTime,
                    event.endTime,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.location,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          event.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.event,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClubInfo(ThemeData theme) {
    return Row(
      children: [
        if (event.club?.logoUrl != null)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(event.club!.logoUrl!),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondaryContainer,
            ),
            child: Icon(
              Icons.group,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          event.club?.name ?? 'Unknown Club',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (event.isFeatured) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Featured',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      event.title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateTime(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          DateFormatter.formatEventDateTime(event.startTime, event.endTime),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            event.location,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        _buildCapacityInfo(theme),
        const Spacer(),
        _buildStatusChip(theme),
      ],
    );
  }

  Widget _buildCapacityInfo(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          '${event.registeredCount}/${event.capacity}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    Color chipColor;
    String statusText;

    if (event.isFull) {
      chipColor = theme.colorScheme.error;
      statusText = 'Full';
    } else if (event.isCompleted) {
      chipColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
      statusText = 'Completed';
    } else if (event.isOngoing) {
      chipColor = theme.colorScheme.tertiary;
      statusText = 'Ongoing';
    } else {
      chipColor = theme.colorScheme.primary;
      statusText = '${event.availableSpots} spots left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
