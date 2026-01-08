import 'package:edara_hub_app/core/resources/UI_Utils.dart';
import 'package:edara_hub_app/core/routes_manager/routes.dart';
import 'package:edara_hub_app/core/widget/custom_elevated_button.dart';
import 'package:edara_hub_app/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';

import '../../../../core/resources/assets_manager.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/resources/values_manager.dart';
import '../../../../core/widget/main_text_field.dart';
import '../../../../core/widget/validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _employeeIdController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  String ipDevice = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _employeeIdController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _getIpAddress();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
  }

  Future<void> _getIpAddress() async {
    try {
      final response = await Dio().get('https://api.ipify.org?format=json');
      if (response.statusCode == 200) {
        setState(() {
          ipDevice = response.data['ip'];
        });
      }
    } catch (e) {
      debugPrint('Failed to get IP address: $e');
    }
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
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(
                  height: AppSize.s40.h,
                ),
                Center(
                    child:Image.asset(ImageAssets.logo,
                )
                ),
                SizedBox(
                  height: AppSize.s40.h,
                ),
                BuildTextField(
                  controller: _nameController,
                  backgroundColor: ColorManager.white,
                  hint: 'enter your full name',
                  label: 'Full Name',
                  textInputType: TextInputType.name,
                  validation: AppValidators.validateFullName,
                ),
                SizedBox(
                  height: AppSize.s18.h,
                ),
                BuildTextField(
                  controller: _employeeIdController,
                  hint: 'enter your code no.',
                  backgroundColor: ColorManager.white,
                  label: 'Code Number',
                  //validation: AppValidators.,
                  textInputType: TextInputType.phone,
                ),
                SizedBox(
                  height: AppSize.s18.h,
                ),
                BuildTextField(
                  controller: _emailController,
                  hint: 'enter your email',
                  backgroundColor: ColorManager.white,
                  label: 'E-mail address',
                  validation: AppValidators.validateEmail,
                  textInputType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: AppSize.s18.h,
                ),
                BuildTextField(
                  controller: _passwordController,
                  hint: 'enter your password',
                  backgroundColor: ColorManager.white,
                  label: 'password',
                  validation: AppValidators.validatePassword,
                  isObscured: true,
                  textInputType: TextInputType.text,
                ),
                SizedBox(
                  height: AppSize.s18.h,
                ),
                BuildTextField(
                  //controller: _passwordController,
                  hint: 're-enter your password',
                  backgroundColor: ColorManager.white,
                  label: 'Confirm password',
                  validation: AppValidators.validatePassword,
                  isObscured: true,
                  textInputType: TextInputType.text,
                ),
                SizedBox(
                  height: AppSize.s18.h,
                ),
                BuildTextField(
                  controller: _phoneController,
                  //validation: AppValidators.validatePhoneNumber(val),
                  hint: 'enter your mobile number',
                  backgroundColor: ColorManager.white,
                  label: 'Mobile Number',
                  isObscured: true,
                  textInputType: TextInputType.phone,
                ),
                SizedBox(
                  height: AppSize.s50.h,
                ),
                Center(
                  child: BlocListener<AuthCubit, AuthState>(
                         listener: (context, state){
                           if(state is RegisterLoading){
UIUtils.showLoading(context, isDismissible: false);
                           }
                           else if(state is RegisterError){
                             UIUtils.hideDialog(context);
                             UIUtils.showToastMessage(state.message, Colors.red);
                           }else if(state is RegisterSuccess){
                             UIUtils.hideDialog(context);
                             UIUtils.showToastMessage("Your Data Has Been Submitted", Colors.green);
                             Navigator.pushReplacementNamed(context, Routes.signInRoute);
                           }
                         },
                    child: SizedBox(
                      height: AppSize.s60.h,
                      width: MediaQuery.of(context).size.width * .9,
                      child: CustomElevatedButton(
                        // borderRadius: AppSize.s8,
                        label: 'Sign Up',
                        backgroundColor: ColorManager.white,
                        textStyle: getBoldStyle(
                            color: ColorManager.primary, fontSize: AppSize.s20),
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            BlocProvider.of<AuthCubit>(context).register(RegisterRequest(
                                email: _emailController.text,
                                employeeId: _employeeIdController.text,
                                ipDevice: ipDevice,
                                name: _nameController.text,
                                password: _passwordController.text,
                                phone: _phoneController.text)
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],

              ),
            ),
          ),
          ),
        ),
      ),
    ),
    );
  }
}
