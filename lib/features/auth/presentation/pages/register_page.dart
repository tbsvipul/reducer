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
import 'package:reducer/core/exceptions/auth_exception.dart';
import 'package:reducer/l10n/app_localizations.dart';

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

    await ref
        .read(authControllerProvider.notifier)
        .signUp(
          _emailController.text.trim(),
          _passwordController.text,
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
    ref.listen(authControllerProvider, (previous, next) {
      if (!next.isLoading && next.hasError) {
        final error = next.error;
        if (error is AuthException && error.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          debugPrint('[RegisterPage] Error: $error');
        }
      }
    });

    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
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
                _RegisterHeader(l10n: l10n),
                SizedBox(height: AppDimensions.xl3.h),
                _RegisterForm(
                  l10n: l10n,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  obscurePassword: _obscurePassword,
                  onTogglePassword: _togglePasswordVisibility,
                ),
                SizedBox(height: AppDimensions.xl4.h),
                AppButton(
                  label: l10n.register,
                  isFullWidth: true,
                  isLoading: authState.isLoading,
                  onPressed: _register,
                ),
                SizedBox(height: AppDimensions.xl2.h),
                _RegisterDivider(l10n: l10n),
                SizedBox(height: AppDimensions.xl2.h),
                _SocialRegisterSection(
                  isLoading: authState.isLoading,
                  l10n: l10n,
                ),
                SizedBox(height: AppDimensions.xl2.h),
                _LoginLink(l10n: l10n),
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
  const _RegisterHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.createAccount, style: AppTextStyles.displaySmall(context)),
        SizedBox(height: AppDimensions.xs.h),
        Text(
          l10n.joinAndStart,
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
    required this.l10n,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  final AppLocalizations l10n;
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
          label: l10n.fullName,
          prefix: Icon(Icons.person_outline, size: AppDimensions.iconMd.r),
          validator: RequiredValidator(errorText: l10n.pleaseEnterName).call,
        ),
        SizedBox(height: AppDimensions.xl.h),
        AppTextField(
          controller: emailController,
          label: l10n.emailAddress,
          prefix: Icon(Icons.email_outlined, size: AppDimensions.iconMd.r),
          keyboardType: TextInputType.emailAddress,
          validator: MultiValidator([
            RequiredValidator(errorText: l10n.pleaseEnterEmail),
            EmailValidator(errorText: l10n.pleaseEnterValidEmail),
          ]).call,
        ),
        SizedBox(height: AppDimensions.xl.h),
        AppTextField(
          controller: passwordController,
          label: l10n.password,
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
            RequiredValidator(errorText: l10n.pleaseEnterPassword),
            MinLengthValidator(8, errorText: l10n.passwordLengthErrorRegister),
          ]).call,
        ),
        SizedBox(height: AppDimensions.xl.h),
        AppTextField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          prefix: Icon(Icons.lock_outline, size: AppDimensions.iconMd.r),
          obscureText: obscurePassword,
          validator: (val) => MatchValidator(
            errorText: 'Passwords do not match',
          ).validateMatch(val ?? '', passwordController.text),
        ),
      ],
    );
  }
}

class _RegisterDivider extends StatelessWidget {
  const _RegisterDivider({required this.l10n});

  final AppLocalizations l10n;

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
            l10n.or,
            style: AppTextStyles.labelSmall(context).copyWith(color: color),
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

class _SocialRegisterSection extends ConsumerWidget {
  const _SocialRegisterSection({required this.isLoading, required this.l10n});

  final bool isLoading;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: l10n.registerWithGoogle,
      style: AppButtonStyle.outline,
      isFullWidth: true,
      isLoading: isLoading,
      iconWidget: Image.asset('assets/logo/google_g.png', height: 24.r),
      onPressed: () =>
          ref.read(authControllerProvider.notifier).signInWithGoogle(),
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.alreadyHaveAccount, style: AppTextStyles.bodyMedium(context)),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            l10n.login,
            style: AppTextStyles.labelLarge(
              context,
            ).copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
