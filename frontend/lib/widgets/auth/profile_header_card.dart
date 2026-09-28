import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../modern_card.dart';
import 'edit_profile_dialog.dart';

/// Profile Header Card showcasing avatar badge, engineer credentials, and quick circularity metrics.
class ProfileHeaderCard extends StatelessWidget {
  final VoidCallback? onLogout;

  const ProfileHeaderCard({
    super.key,
    this.onLogout,
  });

  void _openEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EditProfileDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthService(),
      builder: (context, _) {
        final auth = AuthService();
        final user = auth.currentUser;
        final stats = user?.stats;
        final isMobile = MediaQuery.of(context).size.width < 700;

        if (user == null) {
          return const SizedBox.shrink();
        }

        return ModernCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          borderColor: AppTheme.borderTeal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top User Identity Bar
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _AvatarBadge(initials: user.initials),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _UserInfoColumn(user: user),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _ActionButtonsRow(
                          onEdit: () => _openEditDialog(context),
                          onLogout: onLogout ?? () => auth.logout(),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AvatarBadge(initials: user.initials),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _UserInfoColumn(user: user),
                        ),
                        const SizedBox(width: 16),
                        _ActionButtonsRow(
                          onEdit: () => _openEditDialog(context),
                          onLogout: onLogout ?? () => auth.logout(),
                        ),
                      ],
                    ),

              const SizedBox(height: 24),
              const Divider(color: AppTheme.borderSubtle, height: 1),
              const SizedBox(height: 20),

              // Bottom Analytics Grid
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _StatPill(
                    icon: Icons.science_outlined,
                    label: 'Total Analyses',
                    value: '${stats?.totalAnalysesCount ?? 0}',
                    color: AppTheme.primaryTeal,
                  ),
                  _StatPill(
                    icon: Icons.bookmark_added_outlined,
                    label: 'Saved Presets',
                    value: '${auth.savedAnalyses.length}',
                    color: const Color(0xFF0284C7),
                  ),
                  _StatPill(
                    icon: Icons.eco_rounded,
                    label: 'Eco Formulations',
                    value: '${stats?.ecoFriendlyCount ?? 0}',
                    color: AppTheme.emeraldEco,
                  ),
                  _StatPill(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Avg Circularity',
                    value: '${stats?.averageSustainabilityScore.toStringAsFixed(1) ?? '85.0'}/100',
                    color: const Color(0xFFD97706),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String initials;

  const _AvatarBadge({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x330F766E),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _UserInfoColumn extends StatelessWidget {
  final dynamic user;

  const _UserInfoColumn({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slateDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (user.isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          user.role +
              (user.organization != null && user.organization!.isNotEmpty
                  ? ' • ${user.organization}'
                  : ''),
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.slateBody,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.mail_outline_rounded, size: 14, color: AppTheme.slateBody),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                user.email,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.slateBody,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.bgOffWhite,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Text(
                user.preferences.defaultCurrency,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  const _ActionButtonsRow({
    required this.onEdit,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          key: const Key('profile_edit_button'),
          icon: const Icon(Icons.edit_outlined, size: 15, color: AppTheme.primaryTeal),
          label: const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.borderTeal),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onEdit,
        ),
        const SizedBox(width: 8),
        IconButton(
          key: const Key('profile_logout_button'),
          tooltip: 'Sign Out',
          icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFEF2F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onLogout,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgOffWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.slateBody,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
