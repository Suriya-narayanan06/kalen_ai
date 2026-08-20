import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B0F),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),

            child: ListView(
              padding: const EdgeInsets.all(24),

              children: [
                const SizedBox(height: 20),

                // ─────────────────────────────
                // HEADER
                // ─────────────────────────────

                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: Colors.cyanAccent,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),

                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KALEN AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            'Personal AI Intelligence',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ONLINE STATUS
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.greenAccent
                            .withOpacity(0.08),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.greenAccent
                              .withOpacity(0.25),
                        ),
                      ),

                      child: const Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.greenAccent,
                            size: 8,
                          ),

                          SizedBox(width: 6),

                          Text(
                            'ONLINE',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 45),

                // ─────────────────────────────
                // GREETING
                // ─────────────────────────────

                const Text(
                  'Good evening 👋',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'How can I help you?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 28),

                // ─────────────────────────────
                // AI INPUT DISPLAY
                // STATIC ONLY
                // ─────────────────────────────

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFF151A20),
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.cyanAccent
                          .withOpacity(0.18),
                    ),
                  ),

                  child: const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.cyanAccent,
                        size: 22,
                      ),

                      SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          'Ask KALEN anything...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      Icon(
                        Icons.mic_none,
                        color: Colors.grey,
                        size: 22,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // ─────────────────────────────
                // MODULES TITLE
                // ─────────────────────────────

                const Text(
                  'KALEN MODULES',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 15),

                // ─────────────────────────────
                // MODULES
                // ─────────────────────────────

                GridView.count(
                  crossAxisCount: 2,

                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,

                  childAspectRatio: 1.35,

                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  children: const [
                    StaticModuleCard(
                      icon: Icons.chat_outlined,
                      title: 'Chat',
                      subtitle: 'AI conversation',
                    ),

                    StaticModuleCard(
                      icon: Icons.mic_none,
                      title: 'Voice',
                      subtitle: 'Voice assistant',
                    ),

                    StaticModuleCard(
                      icon: Icons.visibility_outlined,
                      title: 'Vision',
                      subtitle: 'Image intelligence',
                    ),

                    StaticModuleCard(
                      icon: Icons.public,
                      title: 'OSINT',
                      subtitle: 'Intelligence engine',
                    ),

                    StaticModuleCard(
                      icon: Icons.auto_awesome,
                      title: 'Creator',
                      subtitle: 'AI creation tools',
                    ),

                    StaticModuleCard(
                      icon: Icons.phone_in_talk_outlined,
                      title: 'Smart Call',
                      subtitle: 'Call intelligence',
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ─────────────────────────────
                // CORE STATUS
                // ─────────────────────────────

                Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFF11161C),

                    borderRadius:
                        BorderRadius.circular(18),

                    border: Border.all(
                      color: Colors.white10,
                    ),
                  ),

                  child: const Row(
                    children: [
                      Icon(
                        Icons.memory,
                        color: Colors.cyanAccent,
                        size: 25,
                      ),

                      SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KALEN CORE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'System ready • AI engine standby',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // VERSION

                const Center(
                  child: Text(
                    'KALEN AI  •  v2.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ═══════════════════════════════════════════
// STATIC MODULE CARD
// ═══════════════════════════════════════════

class StaticModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const StaticModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF151A20),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: Colors.cyanAccent,
            size: 30,
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}