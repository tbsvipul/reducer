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
import 'package:reducer/l10n/app_localizations.dart';

/// Screen for user authentication via email or social providers.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SECTION: Actions
  // ─────────────────────────────────────────────

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(authControllerProvider.notifier)
        .signIn(_emailController.text.trim(), _passwordController.text);
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
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
            vertical: AppDimensions.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoginHeader(l10n: l10n),
                SizedBox(height: AppDimensions.xl5.h),
                _LoginForm(
                  l10n: l10n,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  onTogglePassword: _togglePasswordVisibility,
                ),
                SizedBox(height: AppDimensions.xl2.h),
                AppButton(
                  label: l10n.login,
                  isFullWidth: true,
                  isLoading: authState.isLoading,
                  onPressed: _login,
                ),
                SizedBox(height: AppDimensions.xl2.h),
                _LoginDivider(l10n: l10n),
                SizedBox(height: AppDimensions.xl2.h),
                _SocialLoginSection(isLoading: authState.isLoading, l10n: l10n),
                SizedBox(height: AppDimensions.xl4.h),
                _RegisterLink(l10n: l10n),
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

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.welcomeBack, style: AppTextStyles.displaySmall(context)),
        SizedBox(height: AppDimensions.xs.h),
        Text(
          l10n.loginContinue,
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.l10n,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  final AppLocalizations l10n;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          validator: RequiredValidator(
            errorText: l10n.pleaseEnterPassword,
          ).call,
        ),
        SizedBox(height: AppDimensions.sm.h),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push('/forgot-password'),
            child: Text(
              l10n.forgotPassword,
              style: AppTextStyles.labelLarge(
                context,
              ).copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginDivider extends StatelessWidget {
  const _LoginDivider({required this.l10n});

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

class _SocialLoginSection extends ConsumerWidget {
  const _SocialLoginSection({required this.isLoading, required this.l10n});

  final bool isLoading;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: l10n.continueWithGoogle,
      style: AppButtonStyle.outline,
      isFullWidth: true,
      isLoading: isLoading,
      iconWidget: Image.asset('assets/logo/google_g.png', height: 24.r),
      onPressed: () =>
          ref.read(authControllerProvider.notifier).signInWithGoogle(),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.dontHaveAccount, style: AppTextStyles.bodyMedium(context)),
        TextButton(
          onPressed: () => context.push('/register'),
          child: Text(
            l10n.register,
            style: AppTextStyles.labelLarge(
              context,
            ).copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
