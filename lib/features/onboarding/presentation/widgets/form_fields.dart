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
  final bool? isEdit;

  const OnboardingTextField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.isEdit,
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
            fontWeight: FontWeight.w700,
            color: isEdit == true ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 8.appSp),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(
              fontSize: 12.appSp,
              color: isEdit == true ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.0),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent, width: 0.0),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent, width: 0.0),
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12.appSp,
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.appSp,
              vertical: 10.appSp,
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
  final bool? isEdit;

  const OnboardingDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = DeviceUtils.getDeviceType() == DeviceType.desktop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.appSp,
            fontWeight: FontWeight.w700,
            color: isEdit == true ? Colors.white : Colors.black,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.appSp,
                    vertical: isDesktop ? 4.appSp : 7.appSp,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.appSp),
                      border: Border.all(color: Colors.grey, width: 0.0)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value.isEmpty ? null : value,
                      hint: Text(
                        'Select ${label.toLowerCase()}',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12.appSp,
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      isDense: true,
                      style: TextStyle(
                        color: isEdit == true ? Colors.white : Colors.black,
                        fontSize: 12.appSp,
                      ),
                      onChanged: (newValue) {
                        onChanged(newValue);
                        state.didChange(newValue);
                      },
                      items:
                          items.map<DropdownMenuItem<String>>((String value) {
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
  final DateTime? maxDate;
  final bool? isEdit;

  const OnboardingDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.maxDate,
    this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = DeviceUtils.getDeviceType() == DeviceType.desktop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.appSp,
            fontWeight: FontWeight.w700,
            color: isEdit == true ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 8.appSp),
        GestureDetector(
          onTap: () async {
            // Calculate minimum date for 13 years age restriction
            final minDate = DateTime.now()
                .subtract(const Duration(days: 365 * 120)); // 120 years max age
            final maxDate = this.maxDate ??
                DateTime.now().subtract(
                    const Duration(days: 365 * 13)); // 13 years minimum age

            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? maxDate,
              firstDate: minDate,
              lastDate: maxDate,
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.appSp,
              vertical: isDesktop ? 7.appSp : 10.appSp,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.appSp),
                border: Border.all(color: Colors.grey, width: 0.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18.appSp,
                  color: Colors.grey.shade700,
                ),
                Text(
                  selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Select your date of birth',
                  style: TextStyle(
                    color: selectedDate != null
                        ? isEdit == true
                            ? Colors.white
                            : Colors.black
                        : Colors.grey.shade400,
                    fontSize: 12.appSp,
                  ),
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
  final bool? isEdit;

  const OnboardingNumberField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.validator,
    this.onChanged,
    this.isEdit,
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
            fontWeight: FontWeight.w700,
            color: isEdit == true ? Colors.white : Colors.black,
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
          style: TextStyle(
            fontSize: 12.appSp,
            color: isEdit == true ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12.appSp,
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.0),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent, width: 0.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.0),
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.appSp,
              vertical: 10.appSp,
            ),
          ),
        ),
      ],
    );
  }
}
