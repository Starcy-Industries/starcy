import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:starcy/core/services/timezone_service.dart';
import 'package:starcy/features/onboarding/presentation/models/form_steps.dart';
import 'package:starcy/features/onboarding/presentation/models/onboarding_model.dart';
import 'package:starcy/features/onboarding/presentation/widgets/form_fields.dart';
import 'package:starcy/features/onboarding/presentation/widgets/step_navigation.dart';
import 'package:starcy/utils/sp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/background_task_handler.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, @PathParam('id') this.isEdit, this.onBack});

  final bool? isEdit;
  final VoidCallback? onBack;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isInit = false;

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
  bool _isLoadingTimezone = false;

  // Add relationship status options
  final List<String> _relationshipStatusOptions = [
    "Single",
    "In a Relationship",
    "Engaged",
    "Married",
    "Separated",
    "Divorced",
    "Widowed",
    "It's Complicated",
    "Prefer Not to Say",
  ];

  // Add age calculation function
  int? calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;

    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Gender options
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isInit = true;
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

      if ((userData['time_zone']?.toString() ?? '').isEmpty) {
        _timeZone = DateTime.now().timeZoneName;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInit = false;
        });
      }
    }
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

  void _nextStep() {
    // Validate the current step's fields before proceeding
    if (!_formKey.currentState!.validate()) return;

    if (_currentStep < FormSteps.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _submitForm() async {
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

      // Save to Supabase
      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'data': {
          'step': 'home',
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
          'is_onboarded': onboardingData.isOnboarded,
          'updated_at': DateTime.now().toIso8601String(),
        }
      });

      if (mounted) {
        if (widget.isEdit == true) {
          widget.onBack!();
        } else {
          if (!kIsWeb) {
            await _startAutoRecording();
          }
          context.router.replace(const UserTermsRoute());
        }
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

  Future<void> _startAutoRecording() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    await Permission.microphone.request();
    BackgroundRecordService backgroundRecordService = BackgroundRecordService();
    backgroundRecordService.startRecord();
  }

  Widget _buildCurrentStep() {
    final currentStepData = FormSteps.steps[_currentStep];
    final fields = currentStepData.fields;

    return Padding(
      padding: EdgeInsets.all(24.appSp).copyWith(top: 8.appSp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Step ${_currentStep + 1} of ${FormSteps.steps.length}: ${currentStepData.title}',
              style: TextStyle(
                fontSize: 14.appSp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.appSp),
          ...fields.map((field) => _buildField(field)).toList(),
        ],
      ),
    );
  }

  Widget _buildField(String field) {
    switch (field) {
      case 'name':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Name',
            hintText: 'Enter your name',
            isEdit: widget.isEdit,
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
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingNumberField(
            label: 'Age',
            isEdit: widget.isEdit,
            hintText: 'Enter your age',
            controller: _ageController,
          ),
        );
      case 'dateOfBirth':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: FormField<DateTime?>(
            validator: (_) {
              if (_dateOfBirth == null) {
                return 'Please select your date of birth';
              }
              final age = calculateAge(_dateOfBirth);
              if (age != null && age < 13) {
                return 'You must be at least 13 years old';
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
                    isEdit: widget.isEdit,
                    selectedDate: _dateOfBirth,
                    onDateSelected: (date) {
                      setState(() {
                        _dateOfBirth = date;

                        final calculatedAge = calculateAge(date);
                        if (calculatedAge != null) {
                          _ageController.text = calculatedAge.toString();
                        }
                      });
                      state.didChange(date);
                    },
                    // Add maxDate to restrict future dates
                    maxDate: DateTime(DateTime.now().year - 13),
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
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingDropdown(
            label: 'Gender',
            value: _gender,
            isEdit: widget.isEdit,
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
          padding: EdgeInsets.only(bottom: 4.appSp),
          child: OnboardingTextField(
            label: 'Location',
            hintText: 'Enter your city',
            isEdit: widget.isEdit,
            controller: _locationController,
            onChanged: (value) async {
              if (value.length > 2) {
                setState(() {
                  _isLoadingTimezone = true;
                });
                try {
                  final timezone =
                      await TimezoneService.getTimezoneFromCity(value);
                  setState(() {
                    _timeZone = timezone;
                  });
                } catch (e) {
                  print('Error getting timezone: $e');
                } finally {
                  setState(() {
                    _isLoadingTimezone = false;
                  });
                }
              }
            },
          ),
        );
      case 'timeZone':
        return Padding(
          padding: EdgeInsets.only(bottom: 0.appSp),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.appSp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Zone',
                  style: TextStyle(
                    fontSize: 12.appSp,
                    fontWeight: FontWeight.w700,
                    color: widget.isEdit == true ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8.appSp),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.appSp,
                    vertical: 8.appSp,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.appSp),
                      border: Border.all(color: Colors.grey, width: 0.0)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _timeZone,
                          style: TextStyle(
                            fontSize: 12.appSp,
                            color: widget.isEdit == true
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      if (_isLoadingTimezone)
                        SizedBox(
                          width: 16.appSp,
                          height: 16.appSp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey.shade400,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case 'hobbies':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Hobbies',
            isEdit: widget.isEdit,
            hintText: 'What do you enjoy doing?',
            controller: _hobbiesController,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Please enter at least one hobby';
              }
              if (value!.trim().length < 3) {
                return 'Please provide more detail about your hobbies';
              }
              return null;
            },
          ),
        );
      case 'learningGoals':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Learning Goals',
            isEdit: widget.isEdit,
            hintText: 'What do you want to learn?',
            controller: _learningGoalsController,
          ),
        );
      case 'languages':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Languages',
            isEdit: widget.isEdit,
            hintText: 'What languages do you speak?',
            controller: _languagesController,
          ),
        );
      case 'dailyRoutine':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Daily Routine',
            isEdit: widget.isEdit,
            hintText: 'Describe your typical day',
            controller: _dailyRoutineController,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Please describe your daily routine';
              }
              if (value!.trim().length < 10) {
                return 'Please provide more detail about your daily routine';
              }
              return null;
            },
          ),
        );
      case 'exerciseHabits':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Exercise Habits',
            isEdit: widget.isEdit,
            hintText: 'How often do you exercise?',
            controller: _exerciseHabitsController,
          ),
        );
      case 'caffeineConsumption':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Caffeine Consumption',
            isEdit: widget.isEdit,
            hintText: 'How much caffeine do you consume daily?',
            controller: _caffeineConsumptionController,
          ),
        );
      case 'profession':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Profession',
            hintText: 'What is your profession?',
            isEdit: widget.isEdit,
            controller: _professionController,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Please enter your profession';
              }
              if (value!.trim().length < 3) {
                return 'Please provide a valid profession';
              }
              return null;
            },
          ),
        );
      case 'workStyle':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Work Style',
            isEdit: widget.isEdit,
            hintText: 'Describe your work style',
            controller: _workStyleController,
          ),
        );
      case 'careerGoals':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Career Goals',
            isEdit: widget.isEdit,
            hintText: 'What are your career goals?',
            controller: _careerGoalsController,
          ),
        );
      case 'lifeGoals':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Life Goals',
            isEdit: widget.isEdit,
            hintText: 'What are your life goals?',
            controller: _lifeGoalsController,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Please enter your life goals';
              }
              if (value!.trim().length < 10) {
                return 'Please provide more detail about your life goals';
              }
              return null;
            },
          ),
        );
      case 'learningPriorities':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Learning Priorities',
            isEdit: widget.isEdit,
            hintText: 'What are your learning priorities?',
            controller: _learningPrioritiesController,
          ),
        );
      case 'motivators':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Motivators',
            isEdit: widget.isEdit,
            hintText: 'What motivates you?',
            controller: _motivatorsController,
          ),
        );
      case 'healthGoals':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Health Goals',
            isEdit: widget.isEdit,
            hintText: 'What are your health goals?',
            controller: _healthGoalsController,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Please enter your health goals';
              }
              if (value!.trim().length < 10) {
                return 'Please provide more detail about your health goals';
              }
              return null;
            },
          ),
        );
      case 'allergies':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Allergies',
            isEdit: widget.isEdit,
            hintText: 'Do you have any allergies?',
            controller: _allergiesController,
          ),
        );
      case 'wellnessPractices':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Wellness Practices',
            isEdit: widget.isEdit,
            hintText: 'What wellness practices do you follow?',
            controller: _wellnessPracticesController,
          ),
        );
      case 'relationshipStatus':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingDropdown(
            label: 'Relationship Status',
            value: _relationshipStatusController.text,
            isEdit: widget.isEdit,
            items: _relationshipStatusOptions,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _relationshipStatusController.text = value;
                });
              }
            },
            validator: (_) {
              if (_relationshipStatusController.text.isEmpty) {
                return 'Please select your relationship status';
              }
              return null;
            },
          ),
        );
      case 'familyDetails':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Family Details',
            isEdit: widget.isEdit,
            hintText: 'Tell us about your family',
            controller: _familyDetailsController,
          ),
        );
      case 'socialEngagement':
        return Padding(
          padding: EdgeInsets.only(bottom: 12.appSp),
          child: OnboardingTextField(
            label: 'Social Engagement',
            isEdit: widget.isEdit,
            hintText: 'How do you engage socially?',
            controller: _socialEngagementController,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = DeviceUtils.getDeviceType() == DeviceType.desktop;
    return widget.isEdit == true
        ? _centerFormWidget()
        : Scaffold(
            backgroundColor: Colors.white,
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: SafeArea(
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isDesktop) SizedBox(height: 65.appSp),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 24.appSp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 32.appSp,
                                      child: Image.asset(
                                        'assets/images/starcy_logo.png',
                                      ),
                                    ),
                                    Text(
                                      'Make your first Artificial\nIntelligence Friend, StarCy',
                                      style: TextStyle(
                                        fontSize: 18.appSp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              // Form content
                              Flexible(
                                child: Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    child: _buildCurrentStep(),
                                  ),
                                ),
                              ),
                              // Navigation buttons
                              _isLoading
                                  ? Padding(
                                      padding: EdgeInsets.all(24.appSp)
                                          .copyWith(top: 0.appSp),
                                      child: const CircularProgressIndicator(),
                                    )
                                  : StepNavigation(
                                      currentStep: _currentStep,
                                      totalSteps: FormSteps.steps.length,
                                      onPrevious: _previousStep,
                                      onNext: _nextStep,
                                      isEdit: widget.isEdit,
                                      isLastStep: _currentStep ==
                                          FormSteps.steps.length - 1,
                                    ),
                              if (isDesktop) SizedBox(height: 65.appSp),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
  }

  Widget _centerFormWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              BackButton(
                color: Colors.white,
                onPressed: widget.onBack,
              ),
              Text(
                "Personalization",
                style: TextStyle(color: Colors.white, fontSize: 18.appSp),
              )
            ],
          ),
        ),
        Flexible(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: _buildCurrentStep(),
            ),
          ),
        ),
        // Navigation buttons
        _isLoading
            ? Padding(
                padding: EdgeInsets.all(24.appSp).copyWith(top: 0.appSp),
                child: const CircularProgressIndicator(),
              )
            : StepNavigation(
                currentStep: _currentStep,
                totalSteps: FormSteps.steps.length,
                onPrevious: _previousStep,
                onNext: _nextStep,
                isLastStep: _currentStep == FormSteps.steps.length - 1,
                isEdit: widget.isEdit,
              )
      ],
    );
  }
}
