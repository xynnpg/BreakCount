import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../services/storage_service.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/radar_painter.dart';

int _moodIndex(int daysUntilBreak, bool isOnBreak) {
  if (isOnBreak) return 6;
  int mood;
  if (daysUntilBreak <= 2) {
    mood = 5;
  } else if (daysUntilBreak <= 7) {
    mood = 4;
  } else if (daysUntilBreak <= 15) {
    mood = 3;
  } else if (daysUntilBreak <= 30) {
    mood = 2;
  } else if (daysUntilBreak <= 60) {
    mood = 1;
  } else {
    mood = 0;
  }
  // Friday afternoon boost, Monday morning dip
  final now = DateTime.now();
  if (now.weekday == DateTime.friday && now.hour >= 14) mood++;
  if (now.weekday == DateTime.monday && now.hour < 10) mood--;
  return mood.clamp(0, 6);
}

const _moodEmojis = ['💀', '😩', '😐', '👀', '🔥', '🤩', '🏖️'];

const _personaDisplay = {
  'hype': ('🔥', 'Hype'),
  'chill': ('😎', 'Chill'),
  'dramatic': ('🎭', 'Dramatic'),
  'sarcastic': ('🙃', 'Sarcastic'),
};

class PersonalityCard extends StatefulWidget {
  final int daysUntilBreak;
  final bool isOnBreak;

  const PersonalityCard({
    super.key,
    required this.daysUntilBreak,
    required this.isOnBreak,
  });

  @override
  State<PersonalityCard> createState() => _PersonalityCardState();
}

class _PersonalityCardState extends State<PersonalityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarCtrl;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final persona =
        StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';
    final (emoji, label) = _personaDisplay[persona] ?? ('🔥', 'Hype');
    final moodIdx = _moodIndex(widget.daysUntilBreak, widget.isOnBreak);
    final moodEmoji = _moodEmojis[moodIdx];

    return GlassmorphicCard(
      animationDelay: 290,
      onTap: () => Navigator.pushNamed(context, '/nearby-users'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR VIBE',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              // Persona block
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Personality',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              // Divider
              Container(
                width: 1,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                color: AppColors.surfaceBorder,
              ),
              // Mood block
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(moodEmoji,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 2),
                  Text(
                    'Current Mood',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Radar + hint
              Column(
                children: [
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _radarCtrl,
                      builder: (context, child) => CustomPaint(
                        painter: RadarPainter(progress: _radarCtrl.value),
                        size: const Size(32, 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nearby',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
