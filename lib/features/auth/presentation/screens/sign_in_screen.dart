
import 'package:edara_hub_app_123/core/resources/UI_Utils.dart';
import 'package:edara_hub_app_123/core/resources/assets_manager.dart';
import 'package:edara_hub_app_123/core/resources/color_manager.dart';
import 'package:edara_hub_app_123/core/resources/values_manager.dart';
import 'package:edara_hub_app_123/core/routes_manager/routes.dart';
import 'package:edara_hub_app_123/core/widget/custom_elevated_button.dart';
import 'package:edara_hub_app_123/core/widget/main_text_field.dart';
import 'package:edara_hub_app_123/core/widget/validators.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/resources/font_manager.dart';
import '../../../../core/resources/styles_manager.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

 late TextEditingController _codeNumberController;
 late TextEditingController _passwordController;
 @override
  void initState() {
    // TODO: implement initState
    _codeNumberController =TextEditingController();
    _passwordController = TextEditingController();
  }
  @override
  void dispose() {
    _codeNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ColorManager.primary, ColorManager.grey2],
          ),
        ),
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: AppSize.s40.h,
                ),
                Center(child: Image.asset(ImageAssets.logo)),
                SizedBox(
                  height: AppSize.s40.h,
                ),
                Text(
                  'Welcome Back To Edara Hub',
                  style: getBoldStyle(color: ColorManager.white)
                      .copyWith(fontSize: FontSize.s24.sp),
                ),
                Text(
                  'Please sign in with your mail',
                  style: getLightStyle(color: ColorManager.white)
                      .copyWith(fontSize: FontSize.s16.sp),
                ),
                SizedBox(
                  height: AppSize.s50.h,
                ),
                BuildTextField(
                  controller: _codeNumberController,
                  backgroundColor: ColorManager.white,
                  hint: 'enter your code number',
                  label: 'Code Number',
                  textInputType: TextInputType.text,
                  //validation: AppValidators.validateEmail,
                ),
                SizedBox(
                  height: AppSize.s28.h,
                ),
                BuildTextField(
                  controller: _passwordController,
                  hint: 'enter your password',
                  backgroundColor: ColorManager.white,
                  label: 'Password',
                  validation: AppValidators.validatePassword,
                  isObscured: true,
                  textInputType: TextInputType.text,
                ),
                SizedBox(
                  height: AppSize.s8.h,
                ),
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Forget password?',
                          style: getMediumStyle(color: ColorManager.white)
                              .copyWith(fontSize: FontSize.s18.sp),
                        )),
                  ],
                ),
                SizedBox(
                  height: AppSize.s60.h,
                ),
                Center(
                  child: BlocListener<AuthCubit, AuthState>(
                    listener: (context,state){
                      if(state is LoginLoading){
                        UIUtils.showLoading(context, isDismissible: false);
                      }
                      else if(state is LoginPendingApproval){
                        UIUtils.hideDialog(context);
                        // Show approval pending dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            title: const Text('Account Pending Approval'),
                            content: Text(state.message),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                      else if(state is LoginError){
                        UIUtils.hideDialog(context);
                        UIUtils.showToastMessage(state.message, Colors.red);
                      }
                      else if(state is LoginSuccess){
                        UIUtils.hideDialog(context);
                        UIUtils.showToastMessage("User Logged In Successfully", Colors.green);
                        Navigator.pushReplacementNamed(context, Routes.mainRoute);
                      }
                    },
                    child: SizedBox(
                      // width: MediaQuery.of(context).size.width * .8,
                      child: CustomElevatedButton(
                        // borderRadius: AppSize.s8,
                        isStadiumBorder: false,
                        label: 'Login',
                        backgroundColor: ColorManager.white,
                        textStyle: getBoldStyle(
                            color: ColorManager.primary, fontSize: AppSize.s18),
                        onTap: () {
                          if (_codeNumberController.text.isEmpty || _passwordController.text.isEmpty) {
                            UIUtils.showToastMessage("Please enter both code number and password", Colors.red);
                            return;
                          }
                          BlocProvider.of<AuthCubit>(context).login(LoginRequest(
                              employeeId: _codeNumberController.text,
                              password: _passwordController.text)
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don’t have an account?',
                      style: getSemiBoldStyle(color: ColorManager.white)
                          .copyWith(fontSize: FontSize.s16.sp),
                    ),
                    SizedBox(
                      width: AppSize.s8.w,
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.signUpRoute),
                      child: Text(
                        'Create Account',
                        style: getSemiBoldStyle(color: ColorManager.white)
                            .copyWith(fontSize: FontSize.s16.sp),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
