// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'WellQ';

  @override
  String get tagline => 'Tu salud, nuestra prioridad';

  @override
  String get signUp => 'Crear cuenta';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get orContinueWith => 'o continúa con';

  @override
  String get loginCanceled => 'Inicio de sesión cancelado.';

  @override
  String loginError(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String get navHealth => 'Salud';

  @override
  String get navAnalytics => 'Analítica';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navCommit => 'Compromisos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSubtitle => 'Modo claro/oscuro';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsSubtitle => 'Configurar alertas';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageValueSystem => 'Seguir sistema';

  @override
  String get settingsLanguageValueEs => 'Español';

  @override
  String get settingsLanguageValueEn => 'Inglés';

  @override
  String get devTools => 'Herramientas de desarrollo';

  @override
  String get dbViewer => 'Visor de base de datos';

  @override
  String get dbViewerSubtitle => 'Ver y administrar la base de datos local';

  @override
  String get insertTestHealthData => 'Insertar datos de prueba';

  @override
  String get insertTestHealthDataSubtitle =>
      'Llenar Health Connect con datos de ejemplo';

  @override
  String get clearTestData => 'Borrar datos de prueba';

  @override
  String get clearTestDataSubtitle => 'Eliminar todos los datos de prueba';

  @override
  String get forceSaveMetrics => 'Forzar guardado de métricas';

  @override
  String get forceSaveMetricsSubtitle =>
      'Guardar datos de salud actuales en la base';

  @override
  String get confirmClearTitle => '¿Borrar datos de prueba?';

  @override
  String get confirmClearBody =>
      'Esto eliminará todos los datos de prueba de Health Connect. Tus hábitos y otros datos de la app se mantendrán.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get clear => 'Borrar';

  @override
  String get insertingTestData => 'Insertando datos de prueba...';

  @override
  String get insertOk => '¡Datos de prueba insertados correctamente!';

  @override
  String insertFail(String error) {
    return 'Error: $error';
  }

  @override
  String get clearOk => 'Datos de prueba eliminados';

  @override
  String clearFail(String error) {
    return 'Error: $error';
  }

  @override
  String get checkLogs => 'Revisa los logs para más detalles';

  @override
  String get dailyCommitmentsTitle => 'Compromisos diarios';

  @override
  String get todaysProgress => 'Progreso de hoy';

  @override
  String commitmentsCompleted(int done, int total) {
    return '$done/$total compromisos completados';
  }

  @override
  String get start => 'Iniciar';

  @override
  String get refreshData => 'Actualizar datos';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get todaysEvents => 'Eventos de hoy';

  @override
  String get noEventsToday => 'No hay eventos para hoy';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get aiSessionTitle => 'Sesión optimizada por IA';

  @override
  String aiSessionSubtitle(int minutes) {
    return 'Enfoque movilidad · $minutes min';
  }

  @override
  String get basedOnRecovery => 'Según tus datos de recuperación';

  @override
  String get healthVitals => 'Signos de salud';

  @override
  String get vitalsTab => 'Signos';

  @override
  String get metricsTab => 'Métricas';

  @override
  String get healthMetrics => 'Métricas de salud';

  @override
  String get stepsLabel => 'Pasos';

  @override
  String get sleepLabel => 'Sueño';

  @override
  String get weightLabel => 'Peso';

  @override
  String get weightUnitKg => 'kg';

  @override
  String get exerciseLabel => 'Ejercicio';

  @override
  String get stressLabel => 'Estrés';

  @override
  String get currentLabel => 'Actual';

  @override
  String get noData => 'Sin datos';

  @override
  String get statusLow => 'Bajo';

  @override
  String get statusModerate => 'Moderado';

  @override
  String get statusHigh => 'Alto';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusOptimal => 'Óptimo';

  @override
  String get statusLight => 'Ligero';

  @override
  String get usingMockData => 'Usando datos simulados';

  @override
  String updatedAgo(String time) {
    return 'Actualizado $time';
  }

  @override
  String get timeJustNow => 'justo ahora';

  @override
  String timeMinutes(int m) {
    return '$m min';
  }

  @override
  String timeHours(int h) {
    return '$h h';
  }

  @override
  String timeDays(int d) {
    return '$d d';
  }

  @override
  String get recoveryOptimization => 'Optimización de recuperación';

  @override
  String get recoveryLabel => 'Recuperación';

  @override
  String get heartRateLabel => 'Frecuencia cardiaca';

  @override
  String recoveryBreadcrumb(String program, int day) {
    return '$program • Día $day';
  }

  @override
  String weeklyChange(String percent) {
    return '$percent esta semana';
  }

  @override
  String get connectHealth => 'Conectar Health';

  @override
  String get boneLabel => 'Hueso';

  @override
  String get densityLabel => 'Densidad';

  @override
  String get muscleLabel => 'Músculo';

  @override
  String get strengthLabel => 'Fuerza';

  @override
  String get jointLabel => 'Articulación';

  @override
  String get mobilityLabel => 'Movilidad';

  @override
  String get cardioLabel => 'Cardio';

  @override
  String get vo2maxLabel => 'VO2 Máx';

  @override
  String get startStreak => 'Comenzar racha';

  @override
  String streakActiveDays(int days) {
    return 'Racha: $days días';
  }

  @override
  String get todaysHabitsTitle => 'Hábitos de hoy';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get pending => 'Pendiente';

  @override
  String get habitPending => 'Pendiente';

  @override
  String get habitDone => 'Completado';

  @override
  String minutes(int count) {
    return '$count minutos';
  }

  @override
  String get pause => 'Pausar';

  @override
  String get completeAction => 'Completar';

  @override
  String get completeEarly => 'Completar antes';

  @override
  String get skipToNext => 'Saltar al siguiente';

  @override
  String get completeNow => 'Completar ahora';

  @override
  String stepOfTotal(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get habitSnackStart => '¡Gran inicio! ¡Comienza tu racha!';

  @override
  String habitSnackNewRecord(int days) {
    return '¡Nuevo récord! ¡$days días de racha!';
  }

  @override
  String habitSnackAmazing(int days) {
    return '¡Asombroso! ¡$days días de racha!';
  }

  @override
  String habitSnackCompleted(int days) {
    return '¡Hábito completado! ¡$days días de racha!';
  }

  @override
  String get noHabitsYet => 'Aún no tienes hábitos';

  @override
  String get addFirstHabit => 'Añade tu primer hábito para comenzar';

  @override
  String get habitMorningStretches => 'Estiramientos matutinos';

  @override
  String get habitPhysicalTherapy => 'Fisioterapia';

  @override
  String get habitEveningWalk => 'Caminata vespertina';

  @override
  String get habitMeditation => 'Meditación';

  @override
  String get languageUpdated => 'Idioma actualizado';

  @override
  String get createAccountHeader => 'CREAR CUENTA';

  @override
  String get joinCommunity => 'Únete a nuestra comunidad de salud';

  @override
  String get usernameLabel => 'Usuario';

  @override
  String get usernameHint => 'Ingresa tu usuario';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Ingresa tu email';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordHint => 'Ingresa tu contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get confirmPasswordHint => 'Confirma tu contraseña';

  @override
  String get orSignUpWith => 'o regístrate con';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get createAccountCta => 'Crear cuenta';

  @override
  String get accountCreatedOk => '¡Cuenta creada correctamente!';

  @override
  String registrationFailed(String error) {
    return 'Registro fallido: $error';
  }

  @override
  String get pleaseEnterUsername => 'Ingresa tu nombre de usuario';

  @override
  String get pleaseEnterValidEmail => 'Ingresa un email válido';

  @override
  String passwordMinChars(int min) {
    return 'La contraseña debe tener al menos $min caracteres';
  }

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get pleaseAcceptTerms => 'Acepta los Términos y Condiciones';

  @override
  String get emailAlreadyRegistered => 'Este email ya está registrado';

  @override
  String get passwordTooWeak => 'La contraseña es demasiado débil';

  @override
  String get invalidEmailFormat => 'Formato de email inválido';

  @override
  String get registrationGenericError =>
      'No se pudo completar el registro. Intenta nuevamente.';

  @override
  String get enterEmailAndPassword => 'Ingresa email y contraseña';

  @override
  String get wrongCredentials => 'Email o contraseña incorrectos';

  @override
  String get userDisabled => 'Esta cuenta ha sido deshabilitada';

  @override
  String get tooManyRequests => 'Demasiados intentos. Intenta más tarde';

  @override
  String get networkError => 'Error de conexión. Verifica tu internet';

  @override
  String get signInGenericError =>
      'Error al iniciar sesión. Intenta nuevamente';

  @override
  String get signInButton => 'Iniciar sesión';

  @override
  String get unexpectedError => 'Error inesperado. Intenta nuevamente';

  @override
  String hiUser(String name) {
    return 'Hola, $name';
  }

  @override
  String get myTrainingOverline => 'Mi entrenamiento';

  @override
  String get progressLabel => 'Progreso';

  @override
  String sessionsXofY(int done, int total) {
    return 'Sesiones: $done/$total';
  }

  @override
  String planSessions(int count) {
    return 'Plan de $count sesiones';
  }

  @override
  String goalPerWeek(int count) {
    return 'Meta: $count/sem';
  }

  @override
  String get nextWorkoutOverline => 'Próximo entrenamiento';

  @override
  String get openMyWorkout => 'Abrir mi rutina';

  @override
  String todayWorkoutSubtitle(String time, String category) {
    return 'Hoy $time • Categoría $category';
  }

  @override
  String get seeOtherWorkouts => 'Ver otras opciones de entrenamiento';

  @override
  String get yourRoutineOverline => 'Tu rutina';

  @override
  String get consecutiveTrainingWeeks => 'Semanas\nconsecutivas';

  @override
  String get trainingCommitment => 'Compromiso\nde entrenamiento';

  @override
  String get treatmentCategoriesTitle => 'Categorías de tratamiento';

  @override
  String get recoveryProgramTitle => 'Programa de recuperación';

  @override
  String get therapeuticExercisesRehab =>
      'Ejercicios terapéuticos para rehabilitación';

  @override
  String recoveryExercisesCount(int count) {
    return '$count ejercicios de recuperación';
  }

  @override
  String get injuryLigamentTear => 'Desgarro de ligamento';

  @override
  String get injuryRotatorCuff => 'Manguito rotador';

  @override
  String get injuryTendinitis => 'Tendinitis';

  @override
  String categoryTitle(String letter) {
    return 'Categoría $letter';
  }

  @override
  String get therapeuticRecoveryExercises =>
      'Ejercicios terapéuticos de recuperación';

  @override
  String get tapForInstructions => 'Toca para ver instrucciones';

  @override
  String get completeSession => 'Completar sesión';

  @override
  String get sessionSaved => 'Sesión completada y guardada';

  @override
  String get exerciseInstructionsTitle => 'Instrucciones del ejercicio';

  @override
  String get stepByStepInstructions => 'Instrucciones paso a paso';

  @override
  String get safetyTips => 'Consejos de seguridad';

  @override
  String get backToExerciseList => 'Volver a la lista de ejercicios';

  @override
  String get todaysCheckInTitle => 'Chequeo de hoy';

  @override
  String get checkInSubtitle => 'Cuéntanos cómo te sientes tras la sesión.';

  @override
  String get painLevel => 'Nivel de dolor';

  @override
  String get stiffness => 'Rigidez';

  @override
  String get howDoYouFeelToday => '¿Cómo te sientes hoy?';

  @override
  String get anyObservationsHint => '¿Alguna observación?';

  @override
  String get send => 'Enviar';

  @override
  String get statusImproving => 'Mejorando';

  @override
  String get statusFlexible => 'Flexible';

  @override
  String get statusStable => 'Estable';

  @override
  String get statusStiff => 'Rígido';

  @override
  String get iAgreeTo => 'Acepto los ';

  @override
  String get termsAndConditions => 'Términos y Condiciones';

  @override
  String get and => 'y';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get calendarSubtitle =>
      'Programa y lleva el control de tus actividades de recuperación';

  @override
  String get reminderTakeMedication => 'Tomar medicamento';

  @override
  String get reminderIceTherapy => 'Sesión de terapia con hielo';

  @override
  String get reminderLogPainLevels => 'Registrar niveles de dolor';

  @override
  String dueIn(String time) {
    return 'Vence en $time';
  }

  @override
  String get healthPermsTitle => 'Se requieren permisos de salud';

  @override
  String get healthPermsBody =>
      'Concede acceso a Health Connect para registrar tus compromisos diarios y métricas de salud';

  @override
  String get grantPermissions => 'Conceder permisos';

  @override
  String get goToDashboard => 'Ir al panel';

  @override
  String commitDrinkWater(int liters) {
    return 'Beber $liters litros de agua';
  }

  @override
  String commitSleepHours(int hours) {
    return 'Duerme $hours horas';
  }

  @override
  String commitConsumeCalories(int kcals) {
    return 'Consume $kcals calorías';
  }

  @override
  String get unitSteps => 'pasos';

  @override
  String commitWalkSteps(int count) {
    return 'Camina $count pasos';
  }

  @override
  String commitDrinkWaterLiters(int liters) {
    return 'Bebe $liters litros de agua';
  }

  @override
  String get unitStepsShort => 'pasos';

  @override
  String get unitLitersShort => 'L';

  @override
  String get unitHours => 'horas';

  @override
  String get unitKcal => 'kcal';

  @override
  String get dayStreak => 'Racha de días';

  @override
  String longestStreak(int days) {
    return 'Tu racha más larga: $days días';
  }
}
