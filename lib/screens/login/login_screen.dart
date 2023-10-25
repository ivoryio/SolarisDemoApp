// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:solarisdemo/config.dart';
import 'package:solarisdemo/infrastructure/auth/auth_presenter.dart';
import 'package:solarisdemo/models/auth/auth_error_type.dart';
import 'package:solarisdemo/models/auth/auth_type.dart';
import 'package:solarisdemo/redux/app_state.dart';
import 'package:solarisdemo/redux/auth/auth_action.dart';
import 'package:solarisdemo/screens/login/login_with_tan_screen.dart';
import 'package:solarisdemo/screens/login/modals/mobile_number_country_picker_popup.dart';
import 'package:solarisdemo/screens/onboarding/onboarding_stepper_screen.dart';
import 'package:solarisdemo/widgets/app_toolbar.dart';
import 'package:solarisdemo/widgets/checkbox.dart';
import 'package:solarisdemo/widgets/continue_button_controller.dart';
import 'package:solarisdemo/widgets/ivory_text_field.dart';
import 'package:solarisdemo/widgets/modal.dart';
import 'package:solarisdemo/widgets/screen_scaffold.dart';
import 'package:solarisdemo/widgets/screen_title.dart';
import 'package:solarisdemo/widgets/scrollable_screen_container.dart';

import '../../utilities/validator.dart';
import '../../widgets/button.dart';
import '../../widgets/tab_view.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = "/loginScreen";

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return StoreConnector<AppState, AuthViewModel>(
      onInit: (store) {
        store.dispatch(
          LoadCredentialsCommandAction(),
        );
      },
      onWillChange: (previousViewModel, newViewModel) {
        if (previousViewModel is AuthLoadingViewModel &&
            newViewModel is AuthInitializedViewModel &&
            newViewModel.authType == AuthType.withTan) {
          Navigator.pushNamed(
            context,
            LoginWithTanScreen.routeName,
          );
        }
        if (previousViewModel is AuthLoadingViewModel &&
            newViewModel is AuthErrorViewModel &&
            newViewModel.errorType == AuthErrorType.incompleteOnboarding) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            OnboardingStepperScreen.routeName,
            (route) => false,
          );
        }
      },
      converter: (store) => AuthPresenter.presentAuth(authState: store.state.authState),
      builder: (context, viewModel) {
        return ScreenScaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppToolbar(
                title: "Login",
                backButtonEnabled: viewModel is! AuthLoadingViewModel,
                scrollController: scrollController,
                padding: ClientConfig.getCustomClientUiSettings().defaultScreenHorizontalPadding,
                actions: const [
                  AppbarLogo(),
                ],
              ),
              Expanded(
                child: ScrollableScreenContainer(
                  padding: ClientConfig.getCustomClientUiSettings().defaultScreenPadding,
                  scrollController: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScreenTitle(
                        "Login",
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: TabView(
                          initialSelectedTabIndex: 1,
                          tabs: [
                            const TabViewItem(
                              text: "Mobile",
                              child: PhoneNumberLoginForm(),
                            ),
                            TabViewItem(
                              text: "Email",
                              child: EmailLoginForm(
                                viewModel: viewModel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class PhoneNumberLoginForm extends StatefulWidget {
  const PhoneNumberLoginForm({super.key});

  @override
  State<PhoneNumberLoginForm> createState() => _PhoneNumberLoginFormState();
}

class _PhoneNumberLoginFormState extends State<PhoneNumberLoginForm> {
  late IvoryTextFieldController _phoneInputController;
  late FocusNode _phoneInputFocusNode;
  late IvoryTextFieldController _passwordInputController;
  late ContinueButtonController _continueButtonController;
  late ValueNotifier<CountryPrefixItem> _selectedCountryNotifier;

  @override
  void initState() {
    super.initState();
    _phoneInputController = IvoryTextFieldController();
    _phoneInputFocusNode = FocusNode();
    _passwordInputController = IvoryTextFieldController(obscureText: true);
    _continueButtonController = ContinueButtonController();
    _phoneInputController.addListener(onChangedPhoneNumber);
    _passwordInputController.addListener(onChangedPassword);
    _selectedCountryNotifier = ValueNotifier<CountryPrefixItem>(
      CountryPrefixItem(
        name: "Germany",
        flagPath: "assets/images/germany_flag.png",
        phonePrefix: "+49",
      ),
    );
    _phoneInputController.text = _selectedCountryNotifier.value.phonePrefix;
  }

  void onChangedPhoneNumber() {
    final phoneIsValid = _phoneInputController.text.isNotEmpty;

    if (!phoneIsValid && !_phoneInputController.hasError) {
      _phoneInputController.setErrorText('Please input a valid phone number');
    } else if (phoneIsValid && _phoneInputController.hasError) {
      _phoneInputController.setError(false);
    }
    if ((_phoneInputController.hasError || _passwordInputController.hasError) && _continueButtonController.isEnabled) {
      _continueButtonController.setDisabled();
    }

    if (!_phoneInputController.hasError &&
        _passwordInputController.text.isNotEmpty &&
        !_passwordInputController.hasError &&
        !_continueButtonController.isEnabled) {
      _continueButtonController.setEnabled();
    }
  }

  void onChangedPassword() {
    final passwordIsValid = _passwordInputController.text.length >= 6;

    if (!passwordIsValid && !_passwordInputController.hasError) {
      _passwordInputController.setErrorText('Please input a valid password with at least 6 characters');
    } else if (passwordIsValid && _passwordInputController.hasError) {
      _passwordInputController.setError(false);
    }
    if ((_phoneInputController.hasError || _passwordInputController.hasError) && _continueButtonController.isEnabled) {
      _continueButtonController.setDisabled();
    }

    if (!_phoneInputController.hasError &&
        !_passwordInputController.hasError &&
        _phoneInputController.text.isNotEmpty &&
        !_continueButtonController.isEnabled) {
      _continueButtonController.setEnabled();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthViewModel>(
      converter: (store) => AuthPresenter.presentAuth(authState: store.state.authState),
      builder: (context, viewModel) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<CountryPrefixItem>(
                      valueListenable: _selectedCountryNotifier,
                      builder: (context, selectedCountry, child) {
                        return IvoryTextField(
                          label: 'Mobile number',
                          keyboardType: TextInputType.phone,
                          controller: _phoneInputController,
                          focusNode: _phoneInputFocusNode,
                          prefix: GestureDetector(
                            onTap: () {
                              showBottomModal(
                                addContentPadding: false,
                                context: context,
                                title: "Select mobile number prefix",
                                content: CountryPrefixPicker(
                                  onCountrySelected: (country) {
                                    _selectedCountryNotifier.value = country;
                                    _phoneInputController.text = country.phonePrefix;
                                  },
                                  selectedCountry: _selectedCountryNotifier.value,
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 48,
                              width: 80,
                              child: Row(
                                children: [
                                  Image.asset(selectedCountry.flagPath),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.expand_more,
                                    color: ClientConfig.getCustomColors().neutral700,
                                  ),
                                  VerticalDivider(
                                    color: _phoneInputFocusNode.hasFocus
                                        ? ClientConfig.getCustomColors().neutral900
                                        : ClientConfig.getCustomColors().neutral400,
                                    thickness: 1,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    IvoryTextField(
                      label: "Password",
                      controller: _passwordInputController,
                      onChanged: (inputValue) {},
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        CheckboxWidget(
                          isChecked: false,
                          onChanged: (bool value) {
                            _passwordInputController.setObscureText(!value);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text('Show password'),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Forgot your password?",
                      style: ClientConfig.getTextStyleScheme().labelMedium.copyWith(
                            color: viewModel is AuthLoadingViewModel
                                ? ClientConfig.getCustomColors().neutral500
                                : ClientConfig.getColorScheme().secondary,
                          ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      child: ListenableBuilder(
                        listenable: _continueButtonController,
                        builder: (context, child) {
                          return Button(
                            text: 'Continue',
                            disabledColor: ClientConfig.getCustomColors().neutral300,
                            color: ClientConfig.getColorScheme().tertiary,
                            textColor: ClientConfig.getColorScheme().surface,
                            isLoading: viewModel is AuthLoadingViewModel,
                            onPressed: _continueButtonController.isEnabled
                                ? () async {
                                    _continueButtonController.setDisabled();
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EmailLoginForm extends StatefulWidget {
  final AuthViewModel viewModel;
  const EmailLoginForm({
    super.key,
    required this.viewModel,
  });

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  late IvoryTextFieldController _emailInputController;
  late IvoryTextFieldController _passwordInputController;
  late ContinueButtonController _continueButtonController;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  final _hasAuthErrorNotifier = ValueNotifier<bool>(false);

  bool get hasAuthError => _hasAuthErrorNotifier.value;
  set hasAuthError(bool value) => _hasAuthErrorNotifier.value = value;

  @override
  void initState() {
    super.initState();
    _emailInputController = IvoryTextFieldController();
    _passwordInputController = IvoryTextFieldController(obscureText: true);
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _continueButtonController = ContinueButtonController();

    _emailInputController.addListener(onChangeEmail);
    _passwordInputController.addListener(onChangePassword);
    _emailFocusNode.addListener(onFocus);
    _passwordFocusNode.addListener(onFocus);
  }

  void onFocus() {
    if (_emailFocusNode.hasFocus && _emailInputController.hasError && hasAuthError) {
      _emailInputController.setError(false);
    }
    if (_passwordFocusNode.hasFocus && _passwordInputController.hasError && hasAuthError) {
      _passwordInputController.setError(false);
    }
    if (!_emailInputController.hasError && !_passwordInputController.hasError && hasAuthError) {
      setState(() {
        hasAuthError = false;
      });
    }
  }

  void onChangePassword() {
    String password = _passwordInputController.text;
    bool isPasswordInputValid = password.isNotEmpty && password.length >= 6;
    if (password.isNotEmpty) {
      if (!isPasswordInputValid && !_passwordInputController.hasError) {
        _passwordInputController.setErrorText('Please input a valid password with at least 6 characters');
        if (hasAuthError) {
          hasAuthError = false;
          _emailInputController.setError(false);
        }
      } else if (isPasswordInputValid && _passwordInputController.hasError && !hasAuthError) {
        _passwordInputController.setError(false);
      }

      if (((_emailInputController.hasError) || _passwordInputController.hasError) &&
          _continueButtonController.isEnabled) {
        _continueButtonController.setDisabled();
      }
      if (!_emailInputController.hasError &&
          !_passwordInputController.hasError &&
          _emailInputController.text.isNotEmpty &&
          !_continueButtonController.isEnabled) {
        _continueButtonController.setEnabled();
      }
    } else {
      if (_passwordInputController.hasError) {
        _passwordInputController.setError(false);
      }
      if (_continueButtonController.isEnabled) {
        _continueButtonController.setDisabled();
      }
    }
  }

  void onChangeEmail() {
    String emailAddress = _emailInputController.text;
    bool isEmailInputValid = emailAddress.isNotEmpty && Validator.isValidEmailAddress(emailAddress);

    if (emailAddress.isNotEmpty) {
      if (!isEmailInputValid && !_emailInputController.hasError) {
      _emailInputController.setErrorText('Please input a valid email address: example@gmail.com');
      if (hasAuthError) {
        hasAuthError = false;
        _passwordInputController.setError(false);
      }
    } else if (isEmailInputValid && _emailInputController.hasError && !hasAuthError) {
      _emailInputController.setError(false);
    }

    if ((_emailInputController.hasError || _passwordInputController.hasError) && _continueButtonController.isEnabled) {
      _continueButtonController.setDisabled();
    }
    if (!_emailInputController.hasError &&
        _passwordInputController.text.isNotEmpty &&
        !_passwordInputController.hasError &&
        !_continueButtonController.isEnabled) {
      _continueButtonController.setEnabled();
    }
    } else {
      if (_emailInputController.hasError) {
        _emailInputController.setError(false);
      }
      if (_continueButtonController.isEnabled) {
        _continueButtonController.setDisabled();
      }
    }
    
  }

  void handleAuthError() {
    if (mounted) {
      hasAuthError = true;
      if (!_emailInputController.hasError) {
        _emailInputController.setError(true);
      }
      if (!_passwordInputController.hasError) {
        _passwordInputController.setError(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthViewModel>(
      onDidChange: (previousViewModel, newViewModel) {
        if (newViewModel is AuthCredentialsLoadedViewModel) {
          _emailInputController.text = widget.viewModel.email!;
          _passwordInputController.text = widget.viewModel.password!;
        }
        if (previousViewModel is AuthLoadingViewModel && newViewModel is AuthErrorViewModel) {
          handleAuthError();
        }
      },
      converter: (store) => AuthPresenter.presentAuth(authState: store.state.authState),
      builder: (context, viewModel) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _hasAuthErrorNotifier,
                      builder: (context, hasAuthError, child) {
                        if (hasAuthError && viewModel is AuthErrorViewModel) {
                          return Column(
                            children: [
                              AuthErrorContainer(
                                errorType: viewModel.errorType!,
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox(height: 8);
                        }
                      },
                    ),
                    IvoryTextField(
                      label: 'Email address',
                      controller: _emailInputController,
                      focusNode: _emailFocusNode,
                      inputType: TextFieldInputType.email,
                    ),
                    if (_emailInputController.hasError) const SizedBox(height: 8),
                    if (_emailInputController.hasError)
                      Text(
                        'Please input a valid email address: example@gmail.com',
                        style: ClientConfig.getTextStyleScheme().bodySmallRegular.copyWith(
                              color: const Color(0xFFE61F27),
                            ),
                      ),
                    const SizedBox(
                      height: 24,
                    ),
                    const SizedBox(height: 8),
                    IvoryTextField(
                      label: 'Password',
                      controller: _passwordInputController,
                      focusNode: _passwordFocusNode,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        CheckboxWidget(
                          isChecked: false,
                          onChanged: (bool value) {
                            _passwordInputController.setObscureText(!value);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text('Show password'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Forgot your password?",
                      style: ClientConfig.getTextStyleScheme().labelMedium.copyWith(
                            color: viewModel is AuthLoadingViewModel
                                ? ClientConfig.getCustomColors().neutral500
                                : ClientConfig.getColorScheme().secondary,
                          ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ListenableBuilder(
                        listenable: _continueButtonController,
                        builder: (context, child) {
                          return Button(
                            text: 'Continue',
                            disabledColor: ClientConfig.getCustomColors().neutral300,
                            color: ClientConfig.getColorScheme().tertiary,
                            textColor: ClientConfig.getColorScheme().surface,
                            isLoading: viewModel is AuthLoadingViewModel,
                            onPressed: _continueButtonController.isEnabled
                                ? () async {
                                    _continueButtonController.setDisabled();
                                    _emailFocusNode.unfocus();
                                    _passwordFocusNode.unfocus();
                                    StoreProvider.of<AppState>(context).dispatch(
                                      InitUserAuthenticationCommandAction(
                                        email: _emailInputController.text.toLowerCase(),
                                        password: _passwordInputController.text,
                                      ),
                                    );
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AuthErrorContainer extends StatelessWidget {
  final AuthErrorType errorType;

  const AuthErrorContainer({
    Key? key,
    required this.errorType,
  }) : super(key: key);

  String getErrorTitle() {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        return 'Wrong email or password';
      case AuthErrorType.cantCreateConsent:
        return 'Consent Creation Failed';
      case AuthErrorType.cantCreateFingerprint:
        return 'Fingerprint Creation Failed';
      case AuthErrorType.biometricAuthFailed:
        return 'Biometric Authentication Failed';
      case AuthErrorType.cantGetPersonData:
        return 'Unable to Retrieve Person Data';
      case AuthErrorType.cantGetPersonAccountData:
        return 'Unable to Retrieve Account Data';
      default:
        return 'Unknown Error';
    }
  }

  String getErrorDescription() {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        return 'Please double-check the information you\'ve entered and try with a different email or password.';
      case AuthErrorType.cantCreateConsent:
      case AuthErrorType.cantCreateFingerprint:
      case AuthErrorType.biometricAuthFailed:
        return 'An error occurred while processing your request. Please try again.';
      case AuthErrorType.cantGetPersonData:
      case AuthErrorType.cantGetPersonAccountData:
        return 'There was a problem retrieving your data. Please check your network connection and try again.';
      default:
        return 'An unknown error occurred. Please try again or contact support.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0XFFFFE9EA),
        border: Border.all(
          width: 1,
          color: const Color(0xFFFFBDBF),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getErrorTitle(),
            style: ClientConfig.getTextStyleScheme().bodySmallBold,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            getErrorDescription(),
            style: ClientConfig.getTextStyleScheme().bodySmallRegular,
          ),
        ],
      ),
    );
  }
}
