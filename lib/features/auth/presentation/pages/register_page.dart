import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:reducer/common/widgets/app_text_field.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

/// Screen for new user registration.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SECTION: Actions
  // ─────────────────────────────────────────────

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authControllerProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  // ─────────────────────────────────────────────
  // SECTION: Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
            size: AppDimensions.iconLg.r,
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
            vertical: AppDimensions.sm,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RegisterHeader(),
                SizedBox(height: AppDimensions.xl3.h),
                _RegisterForm(
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  obscurePassword: _obscurePassword,
                  onTogglePassword: _togglePasswordVisibility,
                ),
                SizedBox(height: AppDimensions.xl4.h),
                AppButton(
                  label: 'Register',
                  isFullWidth: true,
                  isLoading: authState.isLoading,
                  onPressed: _register,
                ),
                SizedBox(height: AppDimensions.xl2.h),
                const _RegisterDivider(),
                SizedBox(height: AppDimensions.xl2.h),
                _SocialRegisterSection(isLoading: authState.isLoading),
                SizedBox(height: AppDimensions.xl2.h),
                const _LoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION: Sub-widgets
// ─────────────────────────────────────────────

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: AppTextStyles.displaySmall(context),
        ),
        SizedBox(height: AppDimensions.xs.h),
        Text(
          'Fill in your details to get started',
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.onDarkSurfaceVariant
                : AppColors.onLightSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: nameController,
          label: 'Full Name',
          hint: 'enter your name',
          prefix: Icon(Icons.person_outline, size: AppDimensions.iconMd.r),
          validator: RequiredValidator(errorText: 'Full name is required').call,
        ),
        SizedBox(height: AppDimensions.xl.h),
        AppTextField(
          controller: emailController,
          label: 'Email Address',
          hint: 'enter your email',
          prefix: Icon(Icons.email_outlined, size: AppDimensions.iconMd.r),
          keyboardType: TextInputType.emailAddress,
          validator: MultiValidator([
            RequiredValidator(errorText: 'Email is required'),
            EmailValidator(errorText: 'Enter a valid email address'),
          ]).call,
        ),
        SizedBox(height: AppDimensions.xl.h),
        AppTextField(
          controller: passwordController,
          label: 'Password',
          hint: 'create a password',
          prefix: Icon(Icons.lock_outline, size: AppDimensions.iconMd.r),
          obscureText: obscurePassword,
          suffix: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              size: AppDimensions.iconLg.r,
            ),
            onPressed: onTogglePassword,
          ),
          validator: MultiValidator([
            RequiredValidator(errorText: 'Password is required'),
            MinLengthValidator(6, errorText: 'Password must be at least 6 characters long'),
          ]).call,
        ),
        SizedBox(height: AppDimensions.xl.h),
        AppTextField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          hint: 'repeat your password',
          prefix: Icon(Icons.lock_outline, size: AppDimensions.iconMd.r),
          obscureText: obscurePassword,
          validator: (val) => MatchValidator(errorText: 'Passwords do not match')
              .validateMatch(val ?? '', passwordController.text),
        ),
      ],
    );
  }
}

class _RegisterDivider extends StatelessWidget {
  const _RegisterDivider();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: Text(
            'OR',
            style: AppTextStyles.labelSmall(context).copyWith(color: color),
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

class _SocialRegisterSection extends ConsumerWidget {
  const _SocialRegisterSection({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Sign up with Google',
      style: AppButtonStyle.outline,
      isFullWidth: true,
      isLoading: isLoading,
      iconWidget: Image.asset('assets/logo/google_g.png', height: 24.r),
      onPressed: () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: AppTextStyles.bodyMedium(context),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Login',
            style: AppTextStyles.labelLarge(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
