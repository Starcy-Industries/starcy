class OnboardingModel {
  final String name;
  final int? age;
  final DateTime? dateOfBirth;
  final String gender;
  final String location;
  final String timeZone;
  final String hobbies;
  final String learningGoals;
  final String languages;
  final String dailyRoutine;
  final String exerciseHabits;
  final String caffeineConsumption;
  final String profession;
  final String workStyle;
  final String careerGoals;
  final String lifeGoals;
  final String learningPriorities;
  final String motivators;
  final String healthGoals;
  final String allergies;
  final String wellnessPractices;
  final String relationshipStatus;
  final String familyDetails;
  final String socialEngagement;
  final bool isOnboarded;

  OnboardingModel({
    this.name = '',
    this.age,
    this.dateOfBirth,
    this.gender = '',
    this.location = '',
    this.timeZone = '',
    this.hobbies = '',
    this.learningGoals = '',
    this.languages = '',
    this.dailyRoutine = '',
    this.exerciseHabits = '',
    this.caffeineConsumption = '',
    this.profession = '',
    this.workStyle = '',
    this.careerGoals = '',
    this.lifeGoals = '',
    this.learningPriorities = '',
    this.motivators = '',
    this.healthGoals = '',
    this.allergies = '',
    this.wellnessPractices = '',
    this.relationshipStatus = '',
    this.familyDetails = '',
    this.socialEngagement = '',
    this.isOnboarded = false,
  });

  OnboardingModel copyWith({
    String? name,
    int? age,
    DateTime? dateOfBirth,
    String? gender,
    String? location,
    String? timeZone,
    String? hobbies,
    String? learningGoals,
    String? languages,
    String? dailyRoutine,
    String? exerciseHabits,
    String? caffeineConsumption,
    String? profession,
    String? workStyle,
    String? careerGoals,
    String? lifeGoals,
    String? learningPriorities,
    String? motivators,
    String? healthGoals,
    String? allergies,
    String? wellnessPractices,
    String? relationshipStatus,
    String? familyDetails,
    String? socialEngagement,
    bool? isOnboarded,
  }) {
    return OnboardingModel(
      name: name ?? this.name,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      timeZone: timeZone ?? this.timeZone,
      hobbies: hobbies ?? this.hobbies,
      learningGoals: learningGoals ?? this.learningGoals,
      languages: languages ?? this.languages,
      dailyRoutine: dailyRoutine ?? this.dailyRoutine,
      exerciseHabits: exerciseHabits ?? this.exerciseHabits,
      caffeineConsumption: caffeineConsumption ?? this.caffeineConsumption,
      profession: profession ?? this.profession,
      workStyle: workStyle ?? this.workStyle,
      careerGoals: careerGoals ?? this.careerGoals,
      lifeGoals: lifeGoals ?? this.lifeGoals,
      learningPriorities: learningPriorities ?? this.learningPriorities,
      motivators: motivators ?? this.motivators,
      healthGoals: healthGoals ?? this.healthGoals,
      allergies: allergies ?? this.allergies,
      wellnessPractices: wellnessPractices ?? this.wellnessPractices,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      familyDetails: familyDetails ?? this.familyDetails,
      socialEngagement: socialEngagement ?? this.socialEngagement,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}