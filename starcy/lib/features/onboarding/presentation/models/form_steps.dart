class FormStep {
  final String title;
  final List<String> fields;

  const FormStep({
    required this.title,
    required this.fields,
  });
}

class FormSteps {
  static const List<FormStep> steps = [
    FormStep(
      title: "Personal Information",
      fields: ["name", "age", "dateOfBirth", "gender", "location", "timeZone"],
    ),
    FormStep(
      title: "Preferences and Interests",
      fields: ["hobbies", "learningGoals", "languages"],
    ),
    FormStep(
      title: "Lifestyle and Daily Habits",
      fields: ["dailyRoutine", "exerciseHabits", "caffeineConsumption"],
    ),
    FormStep(
      title: "Professional Information",
      fields: ["profession", "workStyle", "careerGoals"],
    ),
    FormStep(
      title: "Personal Goals and Aspirations",
      fields: ["lifeGoals", "learningPriorities", "motivators"],
    ),
    FormStep(
      title: "Health and Wellness",
      fields: ["healthGoals", "allergies", "wellnessPractices"],
    ),
    FormStep(
      title: "Relationship Dynamics",
      fields: ["relationshipStatus", "familyDetails", "socialEngagement"],
    ),
  ];
}