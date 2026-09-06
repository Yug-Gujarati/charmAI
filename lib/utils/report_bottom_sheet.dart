import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'custom_text.dart';
import 'theme.dart';

enum ReportReason {
  nuditySexual,
  violence,
  harassmentImpersonation,
  hate,
  other,
}

extension ReportReasonLabel on ReportReason {
  String get apiValue {
    switch (this) {
      case ReportReason.nuditySexual:
        return 'nudity_sexual';
      case ReportReason.violence:
        return 'violence';
      case ReportReason.harassmentImpersonation:
        return 'harassment_impersonation';
      case ReportReason.hate:
        return 'hate';
      case ReportReason.other:
        return 'other';
    }
  }

  String get displayLabel {
    switch (this) {
      case ReportReason.nuditySexual:
        return 'Nudity or sexual content';
      case ReportReason.violence:
        return 'Violence';
      case ReportReason.harassmentImpersonation:
        return 'Harassment or impersonation';
      case ReportReason.hate:
        return 'Hateful content';
      case ReportReason.other:
        return 'Other';
    }
  }
}

class ReportBottomSheet extends StatefulWidget {
  const ReportBottomSheet({super.key,});

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  ReportReason? _selectedReason;
  final _detailController = TextEditingController();
  final _emailController = TextEditingController();

  bool _submitting = false;
  bool _submitted = false;
  String? _errorText;



  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _detailController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Future<void> _submit() async {
  //   if (_selectedReason == null) {
  //     setState(() => _errorText = 'Please choose a reason.');
  //     return;
  //   }
  //
  //   final email = _emailController.text.trim();
  //   final detail = _detailController.text.trim();
  //
  //   setState(() {
  //     _submitting = true;
  //     _errorText = null;
  //   });
  //
  //   try {
  //     final String reasonLabel = _selectedReason!.displayLabel;
  //     final String subject = Uri.encodeComponent('Report Content');
  //     final String body = Uri.encodeComponent(
  //       'Reason: $reasonLabel\n'
  //       'User Email: ${email.isNotEmpty ? email : 'Not provided'}\n'
  //       'Details: ${detail.isNotEmpty ? detail : 'None'}'
  //     );
  //
  //     final Uri emailLaunchUri = Uri.parse('mailto:yuj192001@gmail.com?subject=$subject&body=$body');
  //
  //     if (await canLaunchUrl(emailLaunchUri)) {
  //       await launchUrl(emailLaunchUri);
  //       setState(() {
  //         _submitting = false;
  //         _submitted = true;
  //       });
  //     } else {
  //       setState(() {
  //         _submitting = false;
  //         _errorText = 'Could not launch email app.';
  //       });
  //     }
  //   } catch (_) {
  //     setState(() {
  //       _submitting = false;
  //       _errorText = 'Something went wrong. Please try again.';
  //     });
  //   }
  // }


  Future<void> _submit() async {
    if (_selectedReason == null) {
      setState(() => _errorText = 'Please choose a reason.');
      return;
    }

    final email = _emailController.text.trim();
    final detail = _detailController.text.trim();

    if (email.isNotEmpty && !_emailRegex.hasMatch(email)) {
      setState(() => _errorText = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await FirebaseFirestore.instance.collection('content_reports').add({
        'reason': _selectedReason!.apiValue,
        'reasonLabel': _selectedReason!.displayLabel,
        'email': email.isNotEmpty ? email : null,
        'details': detail.isNotEmpty ? detail : null,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': 'android',
        'appVersion': '1.0.0',
      });

      if (!mounted) return;

      setState(() {
        _submitting = false;
        _submitted = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _errorText = 'Could not submit the report. Please try again.';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SafeArea(
        top: false,
        child: _submitted ? _buildConfirmation() : _buildForm(),
      ),
    );
  }

  Widget _buildConfirmation() {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 100.sp, color: AppColors.successHighlight),
                SizedBox(height: 10.h),
                Text(
                  'Thanks — your report has been sent.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40.sp, color: AppColors.primaryText),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close', style: TextStyle(color: AppColors.skyBlue, fontSize: 40.sp)),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 200.w,
                height: 6.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.secondaryText.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            CustomText(
               text: 'Report this content',
                textColor: AppColors.primaryText,
               fontSize: 50,
                fontFamily: "bold",
                width: 900,
                maxline: 1,
            ),

            SizedBox(height: 4.h),
            CustomText(
              text:   'Let us know what\'s wrong. Our team reviews every report.',
              textColor: AppColors.primaryText,
              fontSize: 40,
              fontFamily: "regular",
              width: 900,
              maxline: 3,
            ),

            SizedBox(height: 12.h),
            ...ReportReason.values.map(
                  (reason) => Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: AppColors.secondaryText,
                ),
                child: RadioListTile<ReportReason>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.skyBlue,
                  title:  CustomText(
                    text:   reason.displayLabel,
                    textColor: AppColors.primaryText,
                    fontSize: 40,
                    fontFamily: "regular",
                    width: 900,
                    maxline: 3,
                  ),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) => setState(() {
                    _selectedReason = value;
                    _errorText = null;
                  }),
                ),
              ),
            ),
            SizedBox(height: 10.h),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: AppColors.primaryText, fontSize: 40.sp),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'So we can follow up if needed',
                  labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 40.sp),
                  hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 40.sp),
                  filled: true,
                  fillColor: AppColors.mainAppBackground,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
            SizedBox(height: 20.h),

            TextField(
              controller: _detailController,
              maxLength: 500,
              maxLines: 3,
              style: TextStyle(color: AppColors.primaryText, fontSize: 40.sp),
              decoration: InputDecoration(
                labelText: 'Additional details (optional)',
                labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 40.sp),
                hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 40.sp),
                filled: true,
                fillColor: AppColors.mainAppBackground,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.skyBlue),
                ),
              ),
            ),
            if (_errorText != null) ...[
              SizedBox(height: 4.h),
              Text(
                _errorText!,
                style: TextStyle(color: AppColors.errorDestructive, fontSize: 13.sp),
              ),
            ],
            SizedBox(height: 30.h),
            Container(
              width: double.infinity,
              height: 120.h,
              decoration: BoxDecoration(
                gradient: AppColors.primaryActionGradient,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                ),
                child: _submitting
                    ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryText),
                )
                    : CustomText(
                  text:    'Submit report',
                  fontSize: 50,
                  fontFamily: 'medium',
                  width: 500,
                  textColor: AppColors.buttonText,
                  maxline: 1,
                  align: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
