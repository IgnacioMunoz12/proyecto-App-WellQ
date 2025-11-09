class RecoveryTip {
  final String title;
  final String description;
  final List<String> tips;
  final String scientific;
  final String emoji;

  RecoveryTip({
    required this.title,
    required this.description,
    required this.tips,
    required this.scientific,
    required this.emoji,
  });
}

class RecoveryTipsService {
  static RecoveryTip getSleepTips(double sleepHours) {
    if (sleepHours >= 7) {
      return RecoveryTip(
        title: 'Excellent Rest!',
        emoji: '✨',
        description: 'Your sleep is at optimal levels. Keep these habits to continue your effective recovery.',
        tips: [
          'Keep your sleep schedule consistent, even on weekends',
          'Expose yourself to natural light within 30-60 minutes of waking',
          'Keep your bedroom cool (65-68°F/18-20°C) for deeper sleep',
          'Avoid alcohol 3-4 hours before bed as it disrupts REM sleep'
        ],
        scientific: 'Quality sleep reduces pain sensitivity by 60% and accelerates musculoskeletal injury recovery according to clinical studies.',
      );
    } else if (sleepHours >= 5) {
      return RecoveryTip(
        title: 'Improve Your Rest',
        emoji: '💤',
        description: 'Your sleep is below optimal. Small changes can make a big difference in your recovery.',
        tips: [
          'Avoid caffeine at least 8-10 hours before bedtime',
          'Reduce blue light from screens 1-2 hours before bed',
          'Take a warm bath before sleep to lower your core temperature',
          'Create a relaxation routine: light reading or deep breathing',
          'Keep your bedroom dark, quiet, and cool'
        ],
        scientific: 'Inadequate sleep increases sports injury risk by 70% and significantly reduces muscle recovery capacity.',
      );
    } else {
      return RecoveryTip(
        title: 'Sleep Needs Attention',
        emoji: '⚠️',
        description: 'Insufficient rest affects your recovery. Prioritize sleep this week for better health.',
        tips: [
          'Set a bedtime alarm, not just a wake-up alarm',
          'If you can\'t sleep in 20-30 min, get up and do a calming activity',
          'Keep bedroom temperature between 60-67°F (15-19°C)',
          'Avoid heavy meals 2-3 hours before bedtime',
          'Consider magnesium or chamomile tea (consult your doctor)',
          'Use blackout curtains and white noise if needed'
        ],
        scientific: 'Sleep deprivation is linked to increased pain sensitivity, impaired concentration, and weakened immune function.',
      );
    }
  }

  static RecoveryTip getExerciseTips(int steps) {
    if (steps >= 8000) {
      return RecoveryTip(
        title: 'Excellent Activity!',
        emoji: '🔥',
        description: 'Your exercise level is optimal. Remember that recovery is as important as training.',
        tips: [
          'Allow 48h recovery between intense workouts of the same muscle group',
          'Incorporate mobility exercises and gentle stretching',
          'Stay hydrated (water with electrolytes post-workout)',
          'Consume 20-40g protein within 2h after exercise',
          'Get 7-9 hours of sleep on training days for optimal recovery'
        ],
        scientific: 'High VO2max improves recovery between exercise sets and accelerates creatine phosphate resynthesis by up to 40%.',
      );
    } else if (steps >= 4000) {
      return RecoveryTip(
        title: 'Increase Gradually',
        emoji: '📈',
        description: 'Your exercise level is moderate. Gradually increasing will improve your recovery capacity.',
        tips: [
          'Exercise in morning or evening, avoid intense workouts 2-3h before bed',
          'Start with 10-15 min walks and increase 10% weekly',
          'Alternate cardiovascular days with strength training',
          'Listen to your body: mild muscle soreness is normal, sharp pain is not',
          'Stay consistent - aim for 150 minutes of moderate activity per week'
        ],
        scientific: 'Regular exercise improves sleep quality by 65% and reduces stress hormones by 25-30%.',
      );
    } else {
      return RecoveryTip(
        title: 'Start Moving',
        emoji: '🚶',
        description: 'Physical activity is key to your recovery. Start today with small steps toward better health.',
        tips: [
          'Begin with 5-10 min daily walks',
          'Perform joint mobility exercises when you wake up',
          'If you have pain, opt for gentle yoga or stretching',
          'Set hourly reminders to stand and move',
          'Find activities you enjoy: dancing, swimming, cycling',
          'Park farther away or take stairs when possible'
        ],
        scientific: 'Prolonged inactivity reduces bone density by 1-2% monthly, decreases muscle strength, and increases injury risk.',
      );
    }
  }

  static RecoveryTip getStressTips(String stressLevel) {
    if (stressLevel == 'Low') {
      return RecoveryTip(
        title: 'Stress Under Control!',
        emoji: '🧘',
        description: 'Your stress management is excellent. Maintain these practices for your wellbeing.',
        tips: [
          'Continue deep breathing techniques (5 min daily)',
          'Maintain positive social connections',
          'Dedicate time to hobbies and activities you enjoy',
          'Practice gratitude: write 3 positive things each day',
          'Keep regular exercise and sleep schedules'
        ],
        scientific: 'Breathing techniques reduce sympathetic nervous system stress response immediately and lower cortisol by 25%.',
      );
    } else if (stressLevel == 'Moderate') {
      return RecoveryTip(
        title: 'Manage Stress Actively',
        emoji: '🎯',
        description: 'Your stress is elevated. Implement relaxation techniques for better recovery and wellbeing.',
        tips: [
          'Practice diaphragmatic breathing: inhale 4 sec, hold 4 sec, exhale 6 sec',
          'Dedicate 10-20 min daily to mindfulness meditation',
          'Do a "body scan" before bed to release muscle tension',
          'Journal before sleeping to process thoughts',
          'Try yoga, tai chi or qigong (gentle movements + breathing)',
          'Limit news and social media before bedtime'
        ],
        scientific: 'Mindfulness meditation reduces anxiety by 60% and improves chronic pain management according to clinical studies.',
      );
    } else {
      return RecoveryTip(
        title: 'Stress Needs Priority',
        emoji: '🆘',
        description: 'High stress affects your recovery. Seek professional support if needed.',
        tips: [
          'Practice breathing techniques 3 times daily (minimum 5 min)',
          'Avoid stressful news before bedtime',
          'Prioritize calming activities (music, nature, pets)',
          'Talk to someone you trust or consider professional therapy',
          'Reduce caffeine and increase relaxing herbal teas',
          'If stress persists, consult a mental health professional',
          'Exercise regularly - even 10 minutes helps reduce stress hormones'
        ],
        scientific: 'Chronic stress increases body inflammation by 50%, weakens immune system, and delays injury recovery significantly.',
      );
    }
  }
}
