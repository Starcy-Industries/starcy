import 'package:flutter/material.dart';
import 'package:starcy/utils/sp.dart';

class StepNavigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLastStep;
  final bool? isEdit;

  const StepNavigation({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onPrevious,
    required this.onNext,
    this.isLastStep = false,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.appSp),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 12.appSp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.appSp),
                  ),
                  side: BorderSide(
                    color: isEdit == true ? Colors.white : Colors.grey,
                  ), // Outline color
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    fontSize: 14.appSp,
                    fontWeight: FontWeight.w500,
                    color: isEdit == true ? Colors.white : Colors.black,
                  ),
                ),
              ),
            )
          else
            const Spacer(flex: 2),
          SizedBox(width: 16.appSp),
          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.appSp),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.appSp),
              ),
              child: Text(
                isLastStep ? 'Finish' : 'Next',
                style: TextStyle(
                  fontSize: 14.appSp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
