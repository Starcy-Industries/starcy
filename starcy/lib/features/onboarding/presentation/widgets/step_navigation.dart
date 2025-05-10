import 'package:flutter/material.dart';
import 'package:starcy/utils/sp.dart';

class StepNavigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLastStep;

  const StepNavigation({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onPrevious,
    required this.onNext,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.appSp),
        // Navigation buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.appSp),
          child: Row(
            children: [
              if (currentStep > 0)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrevious,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.appSp),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.appSp),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 15.appSp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
              SizedBox(width: 16.appSp),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.appSp),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.appSp, horizontal: 12.appSp),
                  ),
                  child: Text(
                    isLastStep ? 'Finish' : 'Next',
                    style: TextStyle(
                      fontSize: 16.appSp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
