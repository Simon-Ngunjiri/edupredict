import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentData {
  final double studyHours;
  final double selfStudyHours;
  final double onlineClassesHours;
  final double socialMediaHours;
  final double gamingHours;
  final double sleepHours;
  final double screenTimeHours;
  final int exerciseMinutes;
  final int caffeineIntakeMg;
  final int partTimeJob;
  final int upcomingDeadline;
  final String internetQuality; // 'Poor' | 'Average' | 'Good'
  final int mentalHealthScore;
  final double focusIndex;
  final double burnoutLevel;
  final double productivityScore;

  const StudentData({
    required this.studyHours,
    required this.selfStudyHours,
    required this.onlineClassesHours,
    required this.socialMediaHours,
    required this.gamingHours,
    required this.sleepHours,
    required this.screenTimeHours,
    required this.exerciseMinutes,
    required this.caffeineIntakeMg,
    required this.partTimeJob,
    required this.upcomingDeadline,
    required this.internetQuality,
    required this.mentalHealthScore,
    required this.focusIndex,
    required this.burnoutLevel,
    required this.productivityScore,
  });
}

class PredictionResult {
  final double examScoreProb;
  final double failProb;
  final List<String> alerts;

  const PredictionResult({
    required this.examScoreProb,
    required this.failProb,
    required this.alerts,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      examScoreProb: (json['exam_score_prob'] as num).toDouble(),
      failProb: (json['fail_prob'] as num).toDouble(),
      alerts: List<String>.from(json['alerts'] ?? []),
    );
  }
}

class ApiService {
  // ── Set your backend URL here ──────────────────────────────────────────────
  // Android emulator  →  http://10.0.2.2:5000
  // iOS simulator     →  http://localhost:5000
  // Physical device   →  http://<YOUR_PC_IP>:5000 i.e http:172.31.0.217:5000
  static const String baseUrl = 'https://edupredict-4.onrender.com';

  static Future<PredictionResult> predict(StudentData data) async {
    final uri = Uri.parse('$baseUrl/predict');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'study_hours': data.studyHours,
            'self_study_hours': data.selfStudyHours,
            'online_classes_hours': data.onlineClassesHours,
            'mental_health_score': data.mentalHealthScore,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return PredictionResult.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Server error ${response.statusCode}: ${response.body}');
    }
  }
}
