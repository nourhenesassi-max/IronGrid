import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String site;
  final String avatarUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.site,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 54,
            backgroundColor: AppColors.primary,
            child: CircleAvatar(
                radius: 51, backgroundImage: NetworkImage(avatarUrl)),
          ),
          const SizedBox(height: 14),
          Text(name,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(role,
              style: const TextStyle(
                  color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999)),
            child: Text(site,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!,
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700)),
                    ],
                  ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class OfflineTile extends StatefulWidget {
  const OfflineTile({super.key});

  @override
  State<OfflineTile> createState() => _OfflineTileState();
}

class _OfflineTileState extends State<OfflineTile> {
  bool _offline = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_outlined, color: AppColors.primary),
          const SizedBox(width: 14),
          const Expanded(
            child: Text("Mode Hors Ligne",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          Switch(
            value: _offline,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _offline = v),
          )
        ],
      ),
    );
  }
}
