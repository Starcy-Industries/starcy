import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starcy/utils/sp.dart';

class OnboardingTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const OnboardingTextField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.appSp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.appSp),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14.appSp,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.appSp),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.appSp,
              vertical: 14.appSp,
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const OnboardingDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.appSp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.appSp),
        FormField<String>(
          validator: validator,
          initialValue: value.isEmpty ? null : value,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.appSp),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.appSp),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value.isEmpty ? null : value,
                      hint: Text(
                        'Select ${label.toLowerCase()}',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14.appSp,
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.appSp,
                      ),
                      onChanged: (newValue) {
                        onChanged(newValue);
                        state.didChange(newValue);
                      },
                      items: items.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
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
      ],
    );
  }
}

class OnboardingDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const OnboardingDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.appSp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.appSp),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.appSp,
              vertical: 14.appSp,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.appSp),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Select your date of birth',
                  style: TextStyle(
                    color: selectedDate != null
                        ? Colors.black
                        : Colors.grey.shade400,
                    fontSize: 14.appSp,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18.appSp,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingNumberField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const OnboardingNumberField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.appSp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.appSp),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14.appSp,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.appSp),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.appSp,
              vertical: 14.appSp,
            ),
          ),
        ),
      ],
    );
  }
}
