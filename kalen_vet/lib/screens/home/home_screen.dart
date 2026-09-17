import 'package:flutter/material.dart';

import '../../app/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openModule(BuildContext context, String module) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$module module selected'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 800;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),

            SliverToBoxAdapter(child: _buildCommandCard(context)),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'QUICK MODULES',
                'Access KALEN capabilities',
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  _ModuleCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chat',
                    description: 'Talk with KALEN',
                    onTap: () => _openModule(context, 'Chat'),
                  ),
                  _ModuleCard(
                    icon: Icons.mic_none,
                    title: 'Voice',
                    description: 'Voice commands',
                    onTap: () => _openModule(context, 'Voice'),
                  ),
                  _ModuleCard(
                    icon: Icons.visibility_outlined,
                    title: 'Vision',
                    description: 'Analyze images',
                    onTap: () => _openModule(context, 'Vision'),
                  ),
                  _ModuleCard(
                    icon: Icons.search,
                    title: 'OSINT',
                    description: 'Public-source intelligence',
                    onTap: () => _openModule(context, 'OSINT'),
                  ),
                  _ModuleCard(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Creator',
                    description: 'Create with AI',
                    onTap: () => _openModule(context, 'Creator'),
                  ),
                  _ModuleCard(
                    icon: Icons.phone_outlined,
                    title: 'Smart Call',
                    description: 'Call intelligence',
                    onTap: () => _openModule(context, 'Smart Call'),
                  ),
                ]),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: isWide ? 1.55 : 1.2,
                ),
              ),
            ),

            SliverToBoxAdapter(child: _buildSystemStatus()),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: KalenVetTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: KalenVetTheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.bolt,
              color: KalenVetTheme.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KALEN VET',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'AI COMMAND CENTER',
                  style: TextStyle(
                    color: KalenVetTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.22)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                SizedBox(width: 7),
                Text(
                  'ONLINE',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [KalenVetTheme.surfaceLight, KalenVetTheme.surface],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: KalenVetTheme.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: KalenVetTheme.primary,
                  size: 18,
                ),
                SizedBox(width: 9),
                Text(
                  'READY',
                  style: TextStyle(
                    color: KalenVetTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            const Text(
              'What should we work on?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 7),

            const Text(
              'Choose a module or start a conversation with KALEN.',
              style: TextStyle(
                color: KalenVetTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            GestureDetector(
              onTap: () => _openModule(context, 'Chat'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: KalenVetTheme.background,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.chat_outlined,
                      color: KalenVetTheme.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ask KALEN anything...',
                        style: TextStyle(
                          color: KalenVetTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: KalenVetTheme.primary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: KalenVetTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: KalenVetTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SYSTEM STATUS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),

            const SizedBox(height: 15),

            _StatusRow(
              icon: Icons.psychology_outlined,
              label: 'AI Engine',
              status: 'READY',
            ),

            _StatusRow(
              icon: Icons.cloud_outlined,
              label: 'Backend',
              status: 'READY',
            ),

            _StatusRow(icon: Icons.mic_none, label: 'Voice', status: 'READY'),

            _StatusRow(
              icon: Icons.visibility_outlined,
              label: 'Vision',
              status: 'READY',
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: KalenVetTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: KalenVetTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: KalenVetTheme.primary, size: 21),
              ),

              const SizedBox(height: 13),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: KalenVetTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, color: KalenVetTheme.textSecondary, size: 18),

          const SizedBox(width: 11),

          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),

          const Icon(Icons.circle, color: Colors.greenAccent, size: 7),

          const SizedBox(width: 7),

          Text(
            status,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
