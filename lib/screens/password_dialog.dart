import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../utils/constants.dart';

class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key});

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _verifyPassword(SecurityProvider provider) {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Kata sandi tidak boleh kosong!';
      });
      return;
    }

    bool isSuccess = provider.verifyAndDisarm(password);
    
    if (isSuccess) {
      Navigator.of(context).pop();
    } else {
      if (provider.currentState == SecurityState.alert) {
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        _errorMessage = 'PIN Salah! (${provider.failedAttemptsCount}x percobaan)';
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SecurityProvider>(context, listen: false);
    final isAlert = provider.currentState == SecurityState.alert;

    return PopScope(
      canPop: !isAlert,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppConstants.cardColor.withAlpha(240),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isAlert 
                  ? AppConstants.primaryColor.withAlpha(128) 
                  : AppConstants.textColor.withAlpha(20),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isAlert 
                    ? AppConstants.primaryColor.withAlpha(30) 
                    : Colors.black.withAlpha(128),
                blurRadius: 30,
                spreadRadius: 5,
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAlert 
                          ? AppConstants.primaryColor.withAlpha(20) 
                          : AppConstants.textColor.withAlpha(5),
                      border: Border.all(
                        color: isAlert 
                            ? AppConstants.primaryColor.withAlpha(60) 
                            : AppConstants.textColor.withAlpha(10),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      isAlert ? Icons.gpp_bad_rounded : Icons.lock_rounded,
                      size: 56,
                      color: isAlert ? AppConstants.primaryColor : AppConstants.successColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    isAlert ? 'Sistem Terpicu!' : 'Nonaktifkan Sistem',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isAlert ? AppConstants.primaryColor : AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    isAlert 
                        ? 'Deteksi gerakan mencurigakan / charger dicabut. Masukkan kata sandi untuk menonaktifkan alarm.'
                        : 'Masukkan kata sandi Anda untuk menonaktifkan pengawasan keamanan.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppConstants.textMutedColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppConstants.textColor,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_open_rounded,
                        color: isAlert ? AppConstants.primaryColor.withAlpha(180) : AppConstants.textMutedColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: AppConstants.textMutedColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      hintText: 'Masukkan Kata Sandi',
                    ),
                    onSubmitted: (_) => _verifyPassword(provider),
                  ),
                  
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppConstants.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 28),
                  
                  Row(
                    children: [
                      if (!isAlert) ...[
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppConstants.textColor.withAlpha(30)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'BATAL',
                              style: TextStyle(
                                color: AppConstants.textColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAlert ? AppConstants.primaryColor : AppConstants.successColor,
                            shadowColor: isAlert ? AppConstants.primaryColor : AppConstants.successColor,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => _verifyPassword(provider),
                          child: Text(
                            isAlert ? 'MATIKAN' : 'KONFIRMASI',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
