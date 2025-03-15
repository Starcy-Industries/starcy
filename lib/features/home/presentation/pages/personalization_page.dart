import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:starcy/features/onboarding/presentation/models/form_steps.dart';
import 'package:starcy/features/onboarding/presentation/models/onboarding_model.dart';
import 'package:starcy/features/onboarding/presentation/widgets/form_fields.dart';
import 'package:starcy/utils/sp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({super.key});

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isDataLoaded = false;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _learningGoalsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _dailyRoutineController = TextEditingController();
  final _exerciseHabitsController = TextEditingController();
  final _caffeineConsumptionController = TextEditingController();
  final _professionController = TextEditingController();
  final _workStyleController = TextEditingController();
  final _careerGoalsController = TextEditingController();
  final _lifeGoalsController = TextEditingController();
  final _learningPrioritiesController = TextEditingController();
  final _motivatorsController = TextEditingController();
  final _healthGoalsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _wellnessPracticesController = TextEditingController();
  final _relationshipStatusController = TextEditingController();
  final _familyDetailsController = TextEditingController();
  final _socialEngagementController = TextEditingController();

  // State variables
  DateTime? _dateOfBirth;
  String _gender = '';
  String _timeZone = '';

  // Timezone options
  final List<String> _timeZoneOptions = [
    'UTC',
    'UTC+1',
    'UTC+2',
    'UTC+3',
    'UTC+4',
    'UTC+5',
    'UTC+6',
    'UTC+7',
    'UTC+8',
    'UTC+9',
    'UTC+10',
    'UTC+11',
    'UTC+12',
    'UTC-1',
    'UTC-2',
    'UTC-3',
    'UTC-4',
    'UTC-5',
    'UTC-6',
    'UTC-7',
    'UTC-8',
    'UTC-9',
    'UTC-10',
    'UTC-11',
    'UTC-12',
  ];

  // Gender options
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _hobbiesController.dispose();
    _learningGoalsController.dispose();
    _languagesController.dispose();
    _dailyRoutineController.dispose();
    _exerciseHabitsController.dispose();
    _caffeineConsumptionController.dispose();
    _professionController.dispose();
    _workStyleController.dispose();
    _careerGoalsController.dispose();
    _lifeGoalsController.dispose();
    _learningPrioritiesController.dispose();
    _motivatorsController.dispose();
    _healthGoalsController.dispose();
    _allergiesController.dispose();
    _wellnessPracticesController.dispose();
    _relationshipStatusController.dispose();
    _familyDetailsController.dispose();
    _socialEngagementController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentSession?.user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabase
          .from('profiles')
          .select('data')
          .eq('id', user.id)
          .single();

      final userData = response['data'] as Map<String, dynamic>;

      // Populate controllers with user data
      _nameController.text = userData['name'] ?? '';
      _ageController.text = userData['age']?.toString() ?? '';
      _dateOfBirth = userData['date_of_birth'] != null
          ? DateTime.parse(userData['date_of_birth'])
          : null;
      _gender = userData['gender'] ?? '';
      _locationController.text = userData['location'] ?? '';
      _timeZone = userData['time_zone'] ?? '';
      _hobbiesController.text = userData['hobbies'] ?? '';
      _learningGoalsController.text = userData['learning_goals'] ?? '';
      _languagesController.text = userData['languages'] ?? '';
      _dailyRoutineController.text = userData['daily_routine'] ?? '';
      _exerciseHabitsController.text = userData['exercise_habits'] ?? '';
      _caffeineConsumptionController.text =
          userData['caffeine_consumption'] ?? '';
      _professionController.text = userData['profession'] ?? '';
      _workStyleController.text = userData['work_style'] ?? '';
      _careerGoalsController.text = userData['career_goals'] ?? '';
      _lifeGoalsController.text = userData['life_goals'] ?? '';
      _learningPrioritiesController.text =
          userData['learning_priorities'] ?? '';
      _motivatorsController.text = userData['motivators'] ?? '';
      _healthGoalsController.text = userData['health_goals'] ?? '';
      _allergiesController.text = userData['allergies'] ?? '';
      _wellnessPracticesController.text = userData['wellness_practices'] ?? '';
      _relationshipStatusController.text =
          userData['relationship_status'] ?? '';
      _familyDetailsController.text = userData['family_details'] ?? '';
      _socialEngagementController.text = userData['social_engagement'] ?? '';

      setState(() {
        _isDataLoaded = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentSession?.user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create onboarding data model
      final onboardingData = OnboardingModel(
        name: _nameController.text.trim(),
        age: _ageController.text.isEmpty
            ? null
            : int.tryParse(_ageController.text),
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        location: _locationController.text.trim(),
        timeZone: _timeZone,
        hobbies: _hobbiesController.text.trim(),
        learningGoals: _learningGoalsController.text.trim(),
        languages: _languagesController.text.trim(),
        dailyRoutine: _dailyRoutineController.text.trim(),
        exerciseHabits: _exerciseHabitsController.text.trim(),
        caffeineConsumption: _caffeineConsumptionController.text.trim(),
        profession: _professionController.text.trim(),
        workStyle: _workStyleController.text.trim(),
        careerGoals: _careerGoalsController.text.trim(),
        lifeGoals: _lifeGoalsController.text.trim(),
        learningPriorities: _learningPrioritiesController.text.trim(),
        motivators: _motivatorsController.text.trim(),
        healthGoals: _healthGoalsController.text.trim(),
        allergies: _allergiesController.text.trim(),
        wellnessPractices: _wellnessPracticesController.text.trim(),
        relationshipStatus: _relationshipStatusController.text.trim(),
        familyDetails: _familyDetailsController.text.trim(),
        socialEngagement: _socialEngagementController.text.trim(),
        isOnboarded: true,
      );

      // Get existing data to preserve other fields
      final response = await supabase
          .from('profiles')
          .select('data')
          .eq('id', user.id)
          .single();

      final existingData = response['data'] as Map<String, dynamic>;

      // Update Supabase
      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'data': {
          ...existingData,
          'name': onboardingData.name,
          'age': onboardingData.age,
          'date_of_birth': onboardingData.dateOfBirth?.toIso8601String(),
          'gender': onboardingData.gender,
          'location': onboardingData.location,
          'time_zone': onboardingData.timeZone,
          'hobbies': onboardingData.hobbies,
          'learning_goals': onboardingData.learningGoals,
          'languages': onboardingData.languages,
          'daily_routine': onboardingData.dailyRoutine,
          'exercise_habits': onboardingData.exerciseHabits,
          'caffeine_consumption': onboardingData.caffeineConsumption,
          'profession': onboardingData.profession,
          'work_style': onboardingData.workStyle,
          'career_goals': onboardingData.careerGoals,
          'life_goals': onboardingData.lifeGoals,
          'learning_priorities': onboardingData.learningPriorities,
          'motivators': onboardingData.motivators,
          'health_goals': onboardingData.healthGoals,
          'allergies': onboardingData.allergies,
          'wellness_practices': onboardingData.wellnessPractices,
          'relationship_status': onboardingData.relationshipStatus,
          'family_details': onboardingData.familyDetails,
          'social_engagement': onboardingData.socialEngagement,
          'updated_at': DateTime.now().toIso8601String(),
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.router.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Personalization'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          if (_isDataLoaded)
            TextButton(
              onPressed: _isLoading ? null : _saveUserData,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.appSp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading && !_isDataLoaded
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.appSp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildAllSections(),
                        SizedBox(height: 32.appSp),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildAllSections() {
    final List<Widget> sections = [];

    for (final step in FormSteps.steps) {
      sections.add(
        Padding(
          padding: EdgeInsets.only(bottom: 24.appSp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 20.appSp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.appSp),
              ...step.fields.map((field) => _buildField(field)).toList(),
            ],
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildField(String field) {
    switch (field) {
      case 'name':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Name',
            hintText: 'Enter your name',
            controller: _nameController,
            validator: (value) {
              if (value?.trim() == null || value?.trim().isEmpty == true) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
        );
      case 'age':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingNumberField(
            label: 'Age',
            hintText: 'Enter your age',
            controller: _ageController,
          ),
        );
      case 'dateOfBirth':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: FormField<DateTime?>(
            validator: (_) {
              if (_dateOfBirth == null) {
                return 'Please select your date of birth';
              }
              return null;
            },
            initialValue: _dateOfBirth,
            builder: (FormFieldState<DateTime?> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingDatePicker(
                    label: 'Date Of Birth',
                    selectedDate: _dateOfBirth,
                    onDateSelected: (date) {
                      setState(() {
                        _dateOfBirth = date;
                      });
                      state.didChange(date);
                    },
                  ),
                  if (state.hasError)
                    Padding(
                      padding: EdgeInsets.only(left: 16.appSp, top: 8.appSp),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.appSp,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      case 'gender':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingDropdown(
            label: 'Gender',
            value: _gender,
            items: _genderOptions,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _gender = value;
                });
              }
            },
            validator: (_) {
              if (_gender.isEmpty) {
                return 'Please select your gender';
              }
              return null;
            },
          ),
        );
      case 'location':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Location',
            hintText: 'Enter your city',
            controller: _locationController,
          ),
        );
      case 'timeZone':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingDropdown(
            label: 'Time Zone',
            value: _timeZone,
            items: _timeZoneOptions,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _timeZone = value;
                });
              }
            },
            validator: (_) {
              if (_timeZone.isEmpty) {
                return 'Please select your time zone';
              }
              return null;
            },
          ),
        );
      case 'hobbies':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Hobbies',
            hintText: 'What do you enjoy doing?',
            controller: _hobbiesController,
          ),
        );
      case 'learningGoals':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Learning Goals',
            hintText: 'What do you want to learn?',
            controller: _learningGoalsController,
          ),
        );
      case 'languages':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Languages',
            hintText: 'What languages do you speak?',
            controller: _languagesController,
          ),
        );
      case 'dailyRoutine':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Daily Routine',
            hintText: 'Describe your typical day',
            controller: _dailyRoutineController,
          ),
        );
      case 'exerciseHabits':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Exercise Habits',
            hintText: 'How often do you exercise?',
            controller: _exerciseHabitsController,
          ),
        );
      case 'caffeineConsumption':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Caffeine Consumption',
            hintText: 'How much caffeine do you consume daily?',
            controller: _caffeineConsumptionController,
          ),
        );
      case 'profession':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Profession',
            hintText: 'What is your profession?',
            controller: _professionController,
          ),
        );
      case 'workStyle':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Work Style',
            hintText: 'Describe your work style',
            controller: _workStyleController,
          ),
        );
      case 'careerGoals':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Career Goals',
            hintText: 'What are your career goals?',
            controller: _careerGoalsController,
          ),
        );
      case 'lifeGoals':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Life Goals',
            hintText: 'What are your life goals?',
            controller: _lifeGoalsController,
          ),
        );
      case 'learningPriorities':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Learning Priorities',
            hintText: 'What are your learning priorities?',
            controller: _learningPrioritiesController,
          ),
        );
      case 'motivators':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Motivators',
            hintText: 'What motivates you?',
            controller: _motivatorsController,
          ),
        );
      case 'healthGoals':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Health Goals',
            hintText: 'What are your health goals?',
            controller: _healthGoalsController,
          ),
        );
      case 'allergies':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Allergies',
            hintText: 'Do you have any allergies?',
            controller: _allergiesController,
          ),
        );
      case 'wellnessPractices':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Wellness Practices',
            hintText: 'What wellness practices do you follow?',
            controller: _wellnessPracticesController,
          ),
        );
      case 'relationshipStatus':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Relationship Status',
            hintText: 'What is your relationship status?',
            controller: _relationshipStatusController,
          ),
        );
      case 'familyDetails':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Family Details',
            hintText: 'Tell us about your family',
            controller: _familyDetailsController,
          ),
        );
      case 'socialEngagement':
        return Padding(
          padding: EdgeInsets.only(bottom: 16.appSp),
          child: OnboardingTextField(
            label: 'Social Engagement',
            hintText: 'How do you engage socially?',
            controller: _socialEngagementController,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}