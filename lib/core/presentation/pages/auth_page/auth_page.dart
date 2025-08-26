import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_genius/core/data/repositories/user_repository_impl.dart';
import 'package:gym_genius/di.dart';
import 'package:gym_genius/theme/context_getters.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _loginController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            _buildWelcomeSection(),
            const SizedBox(height: 32),
            _buildFormFields(),
            const SizedBox(height: 32),
            _buildSignUpButton(),
            const SizedBox(height: 16),
            _buildLoginPrompt(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Icon(
          CupertinoIcons.person_circle_fill,
          size: 80,
          color: context.colors.accent,
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome to Gym Genius',
          style: context.txt.display,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account to get started',
          style: context.txt.body.copyWith(
            color: context.colors.inactive,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildInputField(
          controller: _nameController,
          placeholder: 'First Name',
          prefixIcon: CupertinoIcons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your first name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _surnameController,
          placeholder: 'Last Name',
          prefixIcon: CupertinoIcons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your last name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _loginController,
          placeholder: 'Username',
          prefixIcon: CupertinoIcons.at,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a username';
            }
            // if (value.length < 3) {
            //   return 'Username must be at least 3 characters';
            // }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _emailController,
          placeholder: 'Email',
          prefixIcon: CupertinoIcons.mail,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            // if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            //   return 'Please enter a valid email';
            // }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _passwordController,
          placeholder: 'Password',
          prefixIcon: CupertinoIcons.lock,
          obscureText: _obscurePassword,
          suffixIcon: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            child: Icon(
              _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              color: context.colors.inactive,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _confirmPasswordController,
          placeholder: 'Confirm Password',
          prefixIcon: CupertinoIcons.lock,
          obscureText: _obscureConfirmPassword,
          suffixIcon: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            child: Icon(
              _obscureConfirmPassword
                  ? CupertinoIcons.eye
                  : CupertinoIcons.eye_slash,
              color: context.colors.inactive,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoFormRow(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: CupertinoTextFormFieldRow(
          style: context.txt.bodySmall,
          controller: controller,
          placeholder: placeholder,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          prefix: Icon(
            prefixIcon,
            color: context.colors.inactive,
            size: 20,
          ),
          decoration: const BoxDecoration(),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return CupertinoButton.filled(
      onPressed: _isLoading ? null : _handleSignUp,
      child: _isLoading
          ? CupertinoActivityIndicator(color: context.colors.white)
          : Text(
              'Create Account',
              style: context.txt.label.copyWith(
                color: Colors.black,
              ),
            ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: context.txt.label,
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Navigate to login page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const _LoginPage(),
              ),
            );
          },
          child: Text(
            'Log In',
            style: context.txt.label.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      unawaited(
        getIt<UserRepositoryImpl>().createUser(
            name: _nameController.text.trim(),
            surname: _surnameController.text.trim(),
            password: _passwordController.text,
            email: _emailController.text.trim(),
            login: _loginController.text.trim()),
      );

      await Future.delayed(const Duration(milliseconds: 1203));
    } catch (error) {
      // if (mounted) {
      //   _showErrorDialog(error.toString());
      // }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          Navigator.pop(context);
        });
      }
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colors = context.colors;

    return CupertinoNavigationBar(
      backgroundColor: colors.secondary,
      middle: Text(
        'Create Account',
        style: context.txt.title.copyWith(color: colors.onSurface),
      ),
    );
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage();

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            _buildWelcomeSection(),
            const SizedBox(height: 32),
            _buildFormFields(),
            const SizedBox(height: 32),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    // context.txt.headline
    return Column(
      children: [
        Icon(
          CupertinoIcons.person_circle_fill,
          size: 80,
          color: context.colors.accent,
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome back!',
          style: context.txt.headline,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildInputField(
          controller: _emailController,
          placeholder: 'Login',
          prefixIcon: CupertinoIcons.at,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            // if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            //   return 'Please enter a valid email';
            // }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _passwordController,
          placeholder: 'Password',
          prefixIcon: CupertinoIcons.lock,
          obscureText: _obscurePassword,
          suffixIcon: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            child: Icon(
              _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              color: context.colors.inactive,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            // if (value.length < 8) {
            //   return 'Password must be at least 8 characters';
            // }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CupertinoFormRow(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: CupertinoTextFormFieldRow(
          style: context.txt.body.copyWith(color: colors.onSurface),
          controller: controller,
          placeholder: placeholder,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          prefix: Icon(
            prefixIcon,
            color: context.colors.inactive,
            size: 20,
          ),
          decoration: const BoxDecoration(),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return CupertinoButton.filled(
      onPressed: _isLoading ? null : _handleSignUp,
      child: _isLoading
          ? CupertinoActivityIndicator(color: context.colors.white)
          : Text(
              'Log in',
              style: context.txt.label.copyWith(
                color: Colors.black,
              ),
            ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      unawaited(
        getIt<UserRepositoryImpl>().loginUser(
          login: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1500));
    } catch (error) {
      // if (mounted) {
      //   _showErrorDialog(error.toString());
      // }
    } finally {
      if (mounted) Navigator.pop(context);
      // if (mounted) {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // }
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colors = context.colors;

    return CupertinoNavigationBar(
      backgroundColor: colors.secondary,
      middle: Text(
        'Login',
        style: context.txt.title.copyWith(color: colors.onSurface),
      ),
    );
  }
}
