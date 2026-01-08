import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:osox/core/constants/app_assets.dart';
import 'package:osox/core/constants/app_strings.dart';
import 'package:osox/core/widgets/custom_button.dart';
import 'package:osox/features/onboarding/domain/models/onboarding_model.dart';
import 'package:osox/features/onboarding/presentation/cubit/onboarding_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      title: AppStrings.onboarding1Title,
      image: AppAssets.onboarding1,
    ),
    OnboardingModel(
      title: AppStrings.onboarding2Title,
      image: AppAssets.onboarding2,
    ),
    OnboardingModel(
      title: AppStrings.onboarding3Title,
      image: AppAssets.onboarding3,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      context.read<OnboardingCubit>().updateIndex(index);
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40.r),
                            bottomRight: Radius.circular(40.r),
                          ),
                          image: DecorationImage(
                            image: AssetImage(_pages[index].image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40.r),
                              bottomRight: Radius.circular(40.r),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pages[index].title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              BlocBuilder<OnboardingCubit, int>(
                                builder: (context, activeIndex) {
                                  return Row(
                                    children: List.generate(
                                      _pages.length,
                                      (idx) => Container(
                                        margin: EdgeInsets.only(right: 8.w),
                                        width: 8.w,
                                        height: 8.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: activeIndex == idx
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.withValues(
                                                  alpha: 0.5,
                                                ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: BlocBuilder<OnboardingCubit, int>(
                    builder: (context, activeIndex) {
                      final isLastPage = activeIndex == _pages.length - 1;
                      return CustomButton(
                        text: isLastPage
                            ? AppStrings.getStarted
                            : AppStrings.next,
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          if (isLastPage) {
                            context.go('/login');
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
