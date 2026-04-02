import 'package:flutter/material.dart';

import '../models/surveillance_models.dart';
import '../utils/surveillance_formatters.dart';

class SurveillanceTopHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime now;
  final Future<void> Function() onRefresh;

  const SurveillanceTopHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.now,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF5B6577),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _RoundActionButton(
              icon: Icons.refresh_rounded,
              onTap: () => onRefresh(),
            ),
            const SizedBox(height: 10),
            Text(
              SurveillanceFormatters.clock(now),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F3C88),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SurveillanceHeroBanner extends StatelessWidget {
  final SurveillanceDashboard dashboard;
  final DateTime now;

  const SurveillanceHeroBanner({
    super.key,
    required this.dashboard,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF1F3C88),
            Color(0xFF3459B6),
            Color(0xFF4B72D6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F1F3C88),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Supervision avancee',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                SurveillanceFormatters.clockWithSeconds(now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Mur live multi-cameras, lecture individuelle, et archives en supervision dediee.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: _HeroMetric(
                  value: '${dashboard.dvrs.length}',
                  label: 'DVR',
                ),
              ),
              Expanded(
                child: _HeroMetric(
                  value: '${dashboard.onlineCameras}/${dashboard.cameras.length}',
                  label: 'Flux live',
                ),
              ),
              Expanded(
                child: _HeroMetric(
                  value: '${dashboard.recordings.length}',
                  label: 'Archives',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SurveillanceSourceBanner extends StatelessWidget {
  final String message;

  const SurveillanceSourceBanner({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E6FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1F3C88).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.hub_rounded,
              color: Color(0xFF1F3C88),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF30415F),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SurveillanceSummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const SurveillanceSummaryStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE3F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5B6577),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class SurveillanceArchiveMetric extends StatelessWidget {
  final String label;
  final String value;

  const SurveillanceArchiveMetric({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5B6577),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class SurveillanceTinyBadge extends StatelessWidget {
  final String label;
  final Color color;

  const SurveillanceTinyBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDCE3F1)),
          ),
          child: Icon(icon, color: const Color(0xFF1F3C88)),
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;

  const _HeroMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}
