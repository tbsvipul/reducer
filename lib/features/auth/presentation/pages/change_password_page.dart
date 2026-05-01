import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:reducer/common/widgets/app_text_field.dart';
import 'package:reducer/common/widgets/app_snackbar.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(authControllerProvider.notifier)
          .changePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
          );

      if (mounted) {
        final state = ref.read(authControllerProvider);
        if (state.hasError) {
          debugPrint('Change Password Error: ${state.error}');
        } else {
          AppSnackbar.show(
            context,
            'Password updated successfully!',
            type: AppSnackbarType.success,
          );
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
            vertical: AppDimensions.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Password',
                  style: AppTextStyles.titleLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  'For security, please enter your current password before choosing a new one.',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: isDark
                        ? AppColors.onDarkSurfaceVariant
                        : AppColors.onLightSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.xl2),
                AppTextField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  hint: 'enter current password',
                  prefix: Icon(Icons.lock_open, size: AppDimensions.iconSm.r),
                  obscureText: _obscureText,
                  validator: RequiredValidator(
                    errorText: 'Current password is required',
                  ).call,
                ),
                const SizedBox(height: AppDimensions.lg),
                AppTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hint: 'enter new password',
                  prefix: Icon(
                    Icons.lock_outline,
                    size: AppDimensions.iconSm.r,
                  ),
                  obscureText: _obscureText,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  ),
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'New password is required'),
                    MinLengthValidator(
                      6,
                      errorText: 'Password must be at least 6 characters long',
                    ),
                  ]).call,
                ),
                const SizedBox(height: AppDimensions.lg),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  hint: 'repeat new password',
                  prefix: Icon(
                    Icons.lock_outline,
                    size: AppDimensions.iconSm.r,
                  ),
                  obscureText: _obscureText,
                  validator: (val) => MatchValidator(
                    errorText: 'Passwords do not match',
                  ).validateMatch(val ?? '', _newPasswordController.text),
                ),
                const SizedBox(height: AppDimensions.xl3),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
