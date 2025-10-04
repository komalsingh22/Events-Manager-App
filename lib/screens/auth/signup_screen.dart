import 'package:flutter/material.dart';
import 'package:campus/models/user.dart';
import 'package:campus/models/club.dart';
import 'package:campus/services/auth_service.dart';
import 'package:campus/services/club_service.dart';
import 'package:campus/screens/auth/login_screen.dart';
import 'package:campus/screens/home/home_screen.dart';
import 'package:campus/utils/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  final _clubService = ClubService();

  bool _isLoading = false;
  bool _isLoadingClubs = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.student;
  String? _selectedClubId;
  List<Club> _clubs = [];

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    setState(() {
      _isLoadingClubs = true;
    });

    await _clubService.initialize();
    final result = await _clubService.getClubs();

    if (mounted) {
      setState(() {
        _isLoadingClubs = false;
        if (result.isSuccess && result.data != null) {
          _clubs = result.data!;
        }
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildSignupForm(theme),
              const SizedBox(height: 24),
              _buildSignupButton(theme),
              const SizedBox(height: 16),
              _buildLoginLink(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add,
            size: 40,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Join GatherUp',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account to start discovering events',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignupForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFirstNameField(theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildLastNameField(theme)),
            ],
          ),
          const SizedBox(height: 16),
          _buildEmailField(theme),
          const SizedBox(height: 16),
          _buildPasswordField(theme),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(theme),
          const SizedBox(height: 16),
          _buildRoleSelector(theme),
          if (_selectedRole == UserRole.clubAdmin) ...[
            const SizedBox(height: 16),
            _buildClubSelector(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildFirstNameField(ThemeData theme) {
    return TextFormField(
      controller: _firstNameController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      validator: Validators.name,
      decoration: InputDecoration(
        labelText: 'First Name',
        hintText: 'John',
        prefixIcon: const Icon(Icons.person_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
      ),
    );
  }

  Widget _buildLastNameField(ThemeData theme) {
    return TextFormField(
      controller: _lastNameController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      validator: Validators.name,
      decoration: InputDecoration(
        labelText: 'Last Name',
        hintText: 'Doe',
        prefixIcon: const Icon(Icons.person_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: Validators.email,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'john.doe@university.edu',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      validator: Validators.password,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter a strong password',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
      ),
    );
  }

  Widget _buildConfirmPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      validator: (value) =>
          Validators.confirmPassword(value, _passwordController.text),
      onFieldSubmitted: (_) => _handleSignup(),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
      ),
    );
  }

  Widget _buildRoleSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Account Type',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ...UserRole.values.map(
            (role) => RadioListTile<UserRole>(
              title: Text(role.displayName),
              subtitle: Text(_getRoleDescription(role)),
              value: role,
              groupValue: _selectedRole,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                    // Reset club selection when role changes
                    if (value != UserRole.clubAdmin) {
                      _selectedClubId = null;
                    }
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Discover and register for events';
      case UserRole.clubAdmin:
        return 'Manage events for your club';
      case UserRole.superAdmin:
        return 'Full administrative access';
    }
  }

  Widget _buildClubSelector(ThemeData theme) {
    if (_isLoadingClubs) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainer,
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Select Your Club*',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          if (_clubs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No clubs available. Please contact an administrator.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: DropdownButtonFormField<String>(
                value: _selectedClubId,
                decoration: InputDecoration(
                  hintText: 'Choose a club',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                items: _clubs
                    .map(
                      (club) => DropdownMenuItem(
                        value: club.id,
                        child: Text(club.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClubId = value;
                  });
                },
                validator: (value) {
                  if (_selectedRole == UserRole.clubAdmin &&
                      (value == null || value.isEmpty)) {
                    return 'Please select a club';
                  }
                  return null;
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSignupButton(ThemeData theme) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                'Create Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: Text(
            'Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      role: _selectedRole,
      clubId: _selectedRole == UserRole.clubAdmin ? _selectedClubId : null,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showErrorDialog(result.error ?? 'Signup failed');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signup Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
