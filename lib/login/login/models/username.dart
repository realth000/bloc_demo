import 'package:formz/formz.dart';

/// Error kinds for username validate.
enum UsernameValidationError { empty }

/// Username model.
///
/// In fact it is a string, but we derive it from [FormzInput] so related validate error kinds are also defined.
class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure() : super.pure('');

  const Username.dirty([super.value = '']) : super.dirty();

  @override
  UsernameValidationError? validator(String value) {
    if (value.isEmpty) {
      return UsernameValidationError.empty;
    }

    // Pass the validation.
    return null;
  }
}
