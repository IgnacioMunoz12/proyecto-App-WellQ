// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WellQ';

  @override
  String get tagline => 'Your Health, Our Priority';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get loginCanceled => 'Sign-in canceled.';

  @override
  String loginError(String error) {
    return 'Error signing in: $error';
  }

  @override
  String get navHealth => 'Health';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navCommit => 'Commit';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Light/Dark mode';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Configure alerts';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageValueSystem => 'Follow system';

  @override
  String get settingsLanguageValueEs => 'Spanish';

  @override
  String get settingsLanguageValueEn => 'English';

  @override
  String get devTools => 'Developer Tools';

  @override
  String get dbViewer => 'Database Viewer';

  @override
  String get dbViewerSubtitle => 'View and manage local database';

  @override
  String get insertTestHealthData => 'Insert Test Health Data';

  @override
  String get insertTestHealthDataSubtitle =>
      'Populate Health Connect with sample data';

  @override
  String get clearTestData => 'Clear Test Data';

  @override
  String get clearTestDataSubtitle => 'Remove all test health data';

  @override
  String get forceSaveMetrics => 'Force Save Metrics';

  @override
  String get forceSaveMetricsSubtitle => 'Save current health data to database';

  @override
  String get confirmClearTitle => 'Clear Test Data?';

  @override
  String get confirmClearBody =>
      'This will delete all test health data from Health Connect. Your habits and other app data will remain safe.';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get insertingTestData => 'Inserting test data...';

  @override
  String get insertOk => 'Test data inserted successfully!';

  @override
  String insertFail(String error) {
    return 'Error: $error';
  }

  @override
  String get clearOk => 'Test data cleared';

  @override
  String clearFail(String error) {
    return 'Error: $error';
  }

  @override
  String get checkLogs => 'Check logs for details';

  @override
  String get dailyCommitmentsTitle => 'Daily Commitments';

  @override
  String get todaysProgress => 'Today\'s Progress';

  @override
  String commitmentsCompleted(int done, int total) {
    return '$done/$total commitments completed';
  }

  @override
  String get start => 'Start';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get todaysEvents => 'Today\'s Events';

  @override
  String get noEventsToday => 'No events for today';

  @override
  String get reminders => 'Reminders';

  @override
  String get aiSessionTitle => 'AI-Optimized Session';

  @override
  String aiSessionSubtitle(int minutes) {
    return 'Mobility focus · $minutes min';
  }

  @override
  String get basedOnRecovery => 'Based on your recovery data';

  @override
  String get healthVitals => 'Health Vitals';

  @override
  String get vitalsTab => 'Vitals';

  @override
  String get metricsTab => 'Metrics';

  @override
  String get healthMetrics => 'Health Metrics';

  @override
  String get stepsLabel => 'Steps';

  @override
  String get sleepLabel => 'Sleep';

  @override
  String get weightLabel => 'Weight';

  @override
  String get weightUnitKg => 'kg';

  @override
  String get exerciseLabel => 'Exercise';

  @override
  String get stressLabel => 'Stress';

  @override
  String get currentLabel => 'Current';

  @override
  String get noData => 'No data';

  @override
  String get statusLow => 'Low';

  @override
  String get statusModerate => 'Moderate';

  @override
  String get statusHigh => 'High';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusOptimal => 'Optimal';

  @override
  String get statusLight => 'Light';

  @override
  String get usingMockData => 'Using mock data';

  @override
  String updatedAgo(String time) {
    return 'Updated $time';
  }

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutes(int m) {
    return '${m}m';
  }

  @override
  String timeHours(int h) {
    return '${h}h';
  }

  @override
  String timeDays(int d) {
    return '${d}d';
  }

  @override
  String get recoveryOptimization => 'Recovery Optimization';

  @override
  String get recoveryLabel => 'Recovery';

  @override
  String get heartRateLabel => 'Heart Rate';

  @override
  String recoveryBreadcrumb(String program, int day) {
    return '$program • Day $day';
  }

  @override
  String weeklyChange(String percent) {
    return '$percent this week';
  }

  @override
  String get connectHealth => 'Connect Health';

  @override
  String get boneLabel => 'Bone';

  @override
  String get densityLabel => 'Density';

  @override
  String get muscleLabel => 'Muscle';

  @override
  String get strengthLabel => 'Strength';

  @override
  String get jointLabel => 'Joint';

  @override
  String get mobilityLabel => 'Mobility';

  @override
  String get cardioLabel => 'Cardio';

  @override
  String get vo2maxLabel => 'VO2 Max';

  @override
  String get startStreak => 'Start streak';

  @override
  String streakActiveDays(int days) {
    return '$days-day streak';
  }

  @override
  String get todaysHabitsTitle => 'Today\'s Habits';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get pending => 'Pending';

  @override
  String get habitPending => 'Pending';

  @override
  String get habitDone => 'Completed';

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String get pause => 'Pause';

  @override
  String get completeAction => 'Complete';

  @override
  String get completeEarly => 'Complete Early';

  @override
  String get skipToNext => 'Skip to Next';

  @override
  String get completeNow => 'Complete Now';

  @override
  String stepOfTotal(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get habitSnackStart => 'Great start! Begin your streak!';

  @override
  String habitSnackNewRecord(int days) {
    return 'New record! $days-day streak!';
  }

  @override
  String habitSnackAmazing(int days) {
    return 'Amazing! $days-day streak!';
  }

  @override
  String habitSnackCompleted(int days) {
    return 'Habit completed! $days-day streak!';
  }

  @override
  String get noHabitsYet => 'No habits yet';

  @override
  String get addFirstHabit => 'Add your first habit to get started';

  @override
  String get habitMorningStretches => 'Morning Stretches';

  @override
  String get habitPhysicalTherapy => 'Physical Therapy';

  @override
  String get habitEveningWalk => 'Evening Walk';

  @override
  String get habitMeditation => 'Meditation';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get createAccountHeader => 'CREATE ACCOUNT';

  @override
  String get joinCommunity => 'Join our health community';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get orSignUpWith => 'or sign up with';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get createAccountCta => 'Create Account';

  @override
  String get accountCreatedOk => 'Account created successfully!';

  @override
  String registrationFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String passwordMinChars(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get pleaseAcceptTerms => 'Please accept Terms & Conditions';

  @override
  String get emailAlreadyRegistered => 'This email is already registered';

  @override
  String get passwordTooWeak => 'Password is too weak';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get registrationGenericError =>
      'Registration failed. Please try again.';

  @override
  String get enterEmailAndPassword => 'Please enter email and password';

  @override
  String get wrongCredentials => 'Incorrect email or password';

  @override
  String get userDisabled => 'This account has been disabled';

  @override
  String get tooManyRequests => 'Too many attempts. Try again later';

  @override
  String get networkError => 'Connection error. Check your internet';

  @override
  String get signInGenericError => 'Failed to sign in. Try again';

  @override
  String get signInButton => 'Sign In';

  @override
  String get unexpectedError => 'Unexpected error. Try again';

  @override
  String hiUser(String name) {
    return 'Hi, $name';
  }

  @override
  String get myTrainingOverline => 'My training';

  @override
  String get progressLabel => 'Progress';

  @override
  String sessionsXofY(int done, int total) {
    return 'Sessions: $done/$total';
  }

  @override
  String planSessions(int count) {
    return '$count-session plan';
  }

  @override
  String goalPerWeek(int count) {
    return 'Goal: $count/week';
  }

  @override
  String get nextWorkoutOverline => 'Next workout';

  @override
  String get openMyWorkout => 'Open my workout';

  @override
  String todayWorkoutSubtitle(String time, String category) {
    return 'Today $time • Category $category';
  }

  @override
  String get seeOtherWorkouts => 'See other workout options';

  @override
  String get yourRoutineOverline => 'Your routine';

  @override
  String get consecutiveTrainingWeeks => 'Consecutive\ntraining weeks';

  @override
  String get trainingCommitment => 'Training\ncommitment';

  @override
  String get treatmentCategoriesTitle => 'Treatment Categories';

  @override
  String get recoveryProgramTitle => 'Recovery Program';

  @override
  String get therapeuticExercisesRehab =>
      'Therapeutic exercises for rehabilitation';

  @override
  String recoveryExercisesCount(int count) {
    return '$count recovery exercises';
  }

  @override
  String get injuryLigamentTear => 'Ligament Tear';

  @override
  String get injuryRotatorCuff => 'Rotator Cuff Issues';

  @override
  String get injuryTendinitis => 'Tendinitis';

  @override
  String categoryTitle(String letter) {
    return 'Category $letter';
  }

  @override
  String get therapeuticRecoveryExercises => 'Therapeutic recovery exercises';

  @override
  String get tapForInstructions => 'Tap for instructions';

  @override
  String get completeSession => 'Complete session';

  @override
  String get sessionSaved => 'Session completed and saved';

  @override
  String get exerciseInstructionsTitle => 'Exercise Instructions';

  @override
  String get stepByStepInstructions => 'Step-by-step instructions';

  @override
  String get safetyTips => 'Safety tips';

  @override
  String get backToExerciseList => 'Back to exercise list';

  @override
  String get todaysCheckInTitle => 'Today\'s check-in';

  @override
  String get checkInSubtitle => 'Tell us how you feel after the session.';

  @override
  String get painLevel => 'Pain level';

  @override
  String get stiffness => 'Stiffness';

  @override
  String get howDoYouFeelToday => 'How do you feel today?';

  @override
  String get anyObservationsHint => 'Any observations?';

  @override
  String get send => 'Send';

  @override
  String get statusImproving => 'Improving';

  @override
  String get statusFlexible => 'Flexible';

  @override
  String get statusStable => 'Stable';

  @override
  String get statusStiff => 'Stiff';

  @override
  String get iAgreeTo => 'I agree to the ';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get calendarSubtitle => 'Schedule and track your recovery activities';

  @override
  String get reminderTakeMedication => 'Take medication';

  @override
  String get reminderIceTherapy => 'Ice therapy session';

  @override
  String get reminderLogPainLevels => 'Log pain levels';

  @override
  String dueIn(String time) {
    return 'Due in $time';
  }

  @override
  String get healthPermsTitle => 'Health Permissions Required';

  @override
  String get healthPermsBody =>
      'Please grant access to Health Connect to track your daily commitments and health metrics';

  @override
  String get grantPermissions => 'Grant Permissions';

  @override
  String get goToDashboard => 'Go to Dashboard';

  @override
  String commitDrinkWater(int liters) {
    return 'Drink $liters liters of water';
  }

  @override
  String commitSleepHours(int hours) {
    return 'Sleep $hours hours';
  }

  @override
  String commitConsumeCalories(int kcals) {
    return 'Consume $kcals calories';
  }

  @override
  String get unitSteps => 'steps';

  @override
  String commitWalkSteps(int count) {
    return 'Walk $count steps';
  }

  @override
  String commitDrinkWaterLiters(int liters) {
    return 'Drink $liters liters of water';
  }

  @override
  String get unitStepsShort => 'steps';

  @override
  String get unitLitersShort => 'L';

  @override
  String get unitHours => 'hours';

  @override
  String get unitKcal => 'kcal';

  @override
  String get dayStreak => 'Day Streak';

  @override
  String longestStreak(int days) {
    return 'Your longest streak: $days days';
  }
}
