import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/input_slider.dart';
import '../widgets/internet_quality_picker.dart';
import '../widgets/section_card.dart';
import '../widgets/result_panel.dart';
import '../widgets/alert_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Inputs ─────────────────────────────────────────────────────────────────
  double studyHours          = 4;
  double selfStudyHours      = 2;
  double onlineClassesHours  = 3;
  double socialMediaHours    = 2;
  double gamingHours         = 1;
  double sleepHours          = 7;
  double screenTimeHours     = 5;
  double exerciseMinutes     = 30;
  double caffeineIntakeMg    = 100;
  double partTimeJob         = 0;
  double upcomingDeadline    = 1;
  String internetQuality     = 'Good';
  double mentalHealthScore   = 7;
  double focusIndex          = 6;
  double burnoutLevel        = 3;
  double productivityScore   = 7;

  // ── State ──────────────────────────────────────────────────────────────────
  bool isLoading             = false;
  PredictionResult? result;
  String? errorMessage;

  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _headerFade =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  // ── Local alert generation (matches Python logic exactly) ──────────────────
  List<String> _buildLocalAlerts() {
    final List<String> a = [];
    if (studyHours == 0)
      a.add("You haven't studied today. Try to study to increase your exam scores.");
    if (sleepHours < 6)
      a.add("You slept less than 6 hours. Proper sleep improves focus and exam scores.");
    if (gamingHours > 5)
      a.add("High gaming detected. Reduce gaming to increase your productivity.");
    if (mentalHealthScore < 5)
      a.add("Your mental health is not good. Relax or seek help to improve wellness and exam scores.");
    return a;
  }

  Future<void> _predict() async {
    setState(() {
      isLoading    = true;
      errorMessage = null;
      result       = null;
    });

    try {
      final data = StudentData(
        studyHours:         studyHours,
        selfStudyHours:     selfStudyHours,
        onlineClassesHours: onlineClassesHours,
        socialMediaHours:   socialMediaHours,
        gamingHours:        gamingHours,
        sleepHours:         sleepHours,
        screenTimeHours:    screenTimeHours,
        exerciseMinutes:    exerciseMinutes.toInt(),
        caffeineIntakeMg:   caffeineIntakeMg.toInt(),
        partTimeJob:        partTimeJob.toInt(),
        upcomingDeadline:   upcomingDeadline.toInt(),
        internetQuality:    internetQuality,
        mentalHealthScore:  mentalHealthScore.toInt(),
        focusIndex:         focusIndex,
        burnoutLevel:       burnoutLevel,
        productivityScore:  productivityScore,
      );

      final prediction = await ApiService.predict(data);

      // Merge server alerts with local ones (server handles prob-based alert)
      final localAlerts = _buildLocalAlerts();
      final merged = <String>{...prediction.alerts, ...localAlerts}.toList();

      setState(() {
        result = PredictionResult(
          examScoreProb: prediction.examScoreProb,
          failProb:      prediction.failProb,
          alerts:        merged,
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage =
            'Could not reach the server.\n\nMake sure your Python backend is running:\n  python python_backend/app.py\n\n${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: FadeTransition(
        opacity: _headerFade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 6),
                  _buildHeroLabel(),
                  const SizedBox(height: 24),

                  // ── Section 1: Study ──────────────────────────────────────
                  SectionCard(
                    emoji: '📚',
                    title: 'STUDY METRICS',
                    children: [
                      InputSlider(
                        label: 'Study Hours / Day',
                        value: studyHours,
                        min: 0, max: 12, unit: 'hrs',
                        color: const Color(0xFF00E5CC),
                        onChanged: (v) => setState(() => studyHours = v),
                      ),
                      InputSlider(
                        label: 'Self Study Hours / Day',
                        value: selfStudyHours,
                        min: 0, max: 10, unit: 'hrs',
                        color: const Color(0xFF00E5CC),
                        onChanged: (v) => setState(() => selfStudyHours = v),
                      ),
                      InputSlider(
                        label: 'Online Classes / Day',
                        value: onlineClassesHours,
                        min: 0, max: 12, unit: 'hrs',
                        color: const Color(0xFF00E5CC),
                        onChanged: (v) =>
                            setState(() => onlineClassesHours = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Section 2: Lifestyle ──────────────────────────────────
                  SectionCard(
                    emoji: '🎮',
                    title: 'LIFESTYLE',
                    children: [
                      InputSlider(
                        label: 'Social Media Hours / Day',
                        value: socialMediaHours,
                        min: 0, max: 12, unit: 'hrs',
                        color: const Color(0xFFFF6B6B),
                        onChanged: (v) => setState(() => socialMediaHours = v),
                      ),
                      InputSlider(
                        label: 'Gaming Hours / Day',
                        value: gamingHours,
                        min: 0, max: 12, unit: 'hrs',
                        color: const Color(0xFFFF6B6B),
                        onChanged: (v) => setState(() => gamingHours = v),
                      ),
                      InputSlider(
                        label: 'Screen Time / Day',
                        value: screenTimeHours,
                        min: 0, max: 16, unit: 'hrs',
                        color: const Color(0xFFFF6B6B),
                        onChanged: (v) => setState(() => screenTimeHours = v),
                      ),
                      InputSlider(
                        label: 'Sleep Hours',
                        value: sleepHours,
                        min: 0, max: 12, unit: 'hrs',
                        color: const Color(0xFF42A5F5),
                        onChanged: (v) => setState(() => sleepHours = v),
                      ),
                      InputSlider(
                        label: 'Exercise',
                        value: exerciseMinutes,
                        min: 0, max: 180, unit: 'min',
                        color: const Color(0xFF42A5F5),
                        isInt: true,
                        onChanged: (v) => setState(() => exerciseMinutes = v),
                      ),
                      InputSlider(
                        label: 'Caffeine Intake',
                        value: caffeineIntakeMg,
                        min: 0, max: 600, unit: 'mg',
                        divisions: 60,
                        color: const Color(0xFFFFB74D),
                        isInt: true,
                        onChanged: (v) => setState(() => caffeineIntakeMg = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Section 3: Wellbeing ──────────────────────────────────
                  SectionCard(
                    emoji: '🧠',
                    title: 'WELLBEING & PERFORMANCE',
                    children: [
                      InputSlider(
                        label: 'Mental Health Score',
                        sublabel: '1 = poor  →  10 = excellent',
                        value: mentalHealthScore,
                        min: 1, max: 10, divisions: 9, unit: '/10',
                        color: const Color(0xFF66BB6A),
                        isInt: true,
                        onChanged: (v) =>
                            setState(() => mentalHealthScore = v),
                      ),
                      InputSlider(
                        label: 'Focus Index',
                        value: focusIndex,
                        min: 0, max: 10, unit: '/10',
                        color: const Color(0xFF66BB6A),
                        onChanged: (v) => setState(() => focusIndex = v),
                      ),
                      InputSlider(
                        label: 'Burnout Level',
                        sublabel: '0 = fresh  →  10 = burned out',
                        value: burnoutLevel,
                        min: 0, max: 10, unit: '/10',
                        color: const Color(0xFFAB47BC),
                        onChanged: (v) => setState(() => burnoutLevel = v),
                      ),
                      InputSlider(
                        label: 'Productivity Score',
                        value: productivityScore,
                        min: 0, max: 10, unit: '/10',
                        color: const Color(0xFF66BB6A),
                        onChanged: (v) =>
                            setState(() => productivityScore = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Section 4: Context ────────────────────────────────────
                  SectionCard(
                    emoji: '📋',
                    title: 'CONTEXT',
                    children: [
                      InputSlider(
                        label: 'Part-Time Jobs',
                        value: partTimeJob,
                        min: 0, max: 3, divisions: 3, unit: 'jobs',
                        color: const Color(0xFFFFB74D),
                        isInt: true,
                        onChanged: (v) => setState(() => partTimeJob = v),
                      ),
                      InputSlider(
                        label: 'Upcoming Deadlines',
                        value: upcomingDeadline,
                        min: 0, max: 10, divisions: 10, unit: '',
                        color: const Color(0xFFFF6B6B),
                        isInt: true,
                        onChanged: (v) =>
                            setState(() => upcomingDeadline = v),
                      ),
                      InternetQualityPicker(
                        value: internetQuality,
                        onChanged: (v) =>
                            setState(() => internetQuality = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // ── Predict button ────────────────────────────────────────
                  _buildPredictButton(),

                  const SizedBox(height: 28),

                  // ── Results ───────────────────────────────────────────────
                  if (isLoading) _buildLoading(),
                  if (result != null) ...[
                    ResultPanel(result: result!),
                    if (result!.alerts.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildAlertsSection(result!.alerts),
                    ],
                  ],
                  if (errorMessage != null) _buildError(),

                  const SizedBox(height: 60),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      backgroundColor: const Color(0xFF0B0D17),
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 18, bottom: 14),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5CC), Color(0xFF0097A7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.auto_graph_rounded,
                  color: Colors.white, size: 17),
            ),
            const SizedBox(width: 10),
            Text(
              'EduPredict',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F1120), Color(0xFF0B0D17)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Check-In',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fill in today\'s metrics to predict your exam outcome.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Colors.white38,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictButton() {
    return GestureDetector(
      onTap: isLoading ? null : _predict,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isLoading
              ? const LinearGradient(
                  colors: [Color(0xFF1E2A2A), Color(0xFF1E2A2A)])
              : const LinearGradient(
                  colors: [Color(0xFF00E5CC), Color(0xFF0097A7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF00E5CC).withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Color(0xFF00E5CC)),
                )
              : Text(
                  'Predict My Score',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'Analysing your data...',
          style: GoogleFonts.dmSans(color: Colors.white30, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildAlertsSection(List<String> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              'RECOMMENDATIONS',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts.map((a) => AlertChip(message: a)),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1218),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: GoogleFonts.dmSans(
                color: Colors.redAccent,
                fontSize: 12.5,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
