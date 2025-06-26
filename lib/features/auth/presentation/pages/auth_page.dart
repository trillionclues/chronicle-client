import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_event.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  static const String route = '/auth';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: BlocConsumer<UserBloc, UserState>(builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Chronicle",
                style: ChronicleTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ChronicleTextStyles.xl,
                ),
              ),
              const Spacer(),
              SvgPicture.asset("assets/images/login_image.svg"),
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: ChronicleSpacing.sm + 2),
                child: Text(
                  "Collaborate with friends and craft unique stories together.",
                  textAlign: TextAlign.center,
                  style: ChronicleTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: ChronicleTextStyles.lg,
                  ),
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              DefaultButton(
                  text: "Login with Google",
                  textColor: AppColors.surface,
                  backgroundColor: AppColors.primary,
                  loading: state.status == UserStatus.loading,
                  onPressed: () {
                    context.read<UserBloc>().add(LoginWithGoogleEvent());
                  },
                  padding: const EdgeInsets.all(ChronicleSpacing.sm))
            ],
          ),
        );
      }, listener: (context, state) {
        if (state.status == UserStatus.error) {
          ChronicleSnackBar.showError(
            context: context,
            message: state.errorMessage ?? "",
          );
        }
      })),
    );
  }
}
