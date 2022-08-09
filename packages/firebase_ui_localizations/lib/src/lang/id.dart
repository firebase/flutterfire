import '../default_localizations.dart';

class IdLocalizations extends FirebaseUILocalizationLabels {
  @override
  final String emailInputLabel;
  @override
  final String passwordInputLabel;
  @override
  final String signInActionText;
  @override
  final String registerActionText;
  @override
  final String linkEmailButtonText;

  @override
  final String signInWithPhoneButtonText;
  @override
  final String signInWithGoogleButtonText;
  @override
  final String signInWithAppleButtonText;
  @override
  final String signInWithFacebookButtonText;
  @override
  final String signInWithTwitterButtonText;
  @override
  final String phoneVerificationViewTitleText;
  @override
  final String verifyPhoneNumberButtonText;
  @override
  final String verifyCodeButtonText;

  @override
  final String unknownError;
  @override
  final String smsAutoresolutionFailedError;

  @override
  final String verifyingSMSCodeText;
  @override
  final String enterSMSCodeText;
  @override
  final String emailIsRequiredErrorText;
  @override
  final String isNotAValidEmailErrorText;
  @override
  final String userNotFoundErrorText;
  @override
  final String emailTakenErrorText;
  @override
  final String accessDisabledErrorText;
  @override
  final String wrongOrNoPasswordErrorText;
  @override
  final String signInText;
  @override
  final String registerText;
  @override
  final String registerHintText;
  @override
  final String signInHintText;
  @override
  final String signOutButtonText;
  @override
  final String phoneInputLabel;
  @override
  final String phoneNumberIsRequiredErrorText;
  @override
  final String phoneNumberInvalidErrorText;
  @override
  final String profile;
  @override
  final String name;
  @override
  final String deleteAccount;
  @override
  final String passwordIsRequiredErrorText;
  @override
  final String confirmPasswordIsRequiredErrorText;
  @override
  final String confirmPasswordDoesNotMatchErrorText;
  @override
  final String confirmPasswordInputLabel;
  @override
  final String forgotPasswordButtonLabel;
  @override
  final String forgotPasswordViewTitle;
  @override
  final String resetPasswordButtonLabel;
  @override
  final String verifyItsYouText;
  @override
  final String differentMethodsSignInTitleText;
  @override
  final String findProviderForEmailTitleText;
  @override
  final String continueText;
  @override
  final String countryCode;

  @override
  final String invalidCountryCode;
  @override
  final String chooseACountry;
  @override
  final String enableMoreSignInMethods;
  @override
  final String signInMethods;
  @override
  final String provideEmail;
  @override
  final String goBackButtonLabel;
  @override
  final String passwordResetEmailSentText;
  @override
  final String forgotPasswordHintText;
  @override
  final String emailLinkSignInButtonLabel;
  @override
  final String signInWithEmailLinkViewTitleText;
  @override
  final String signInWithEmailLinkSentText;
  @override
  final String sendLinkButtonLabel;
  @override
  final String arrayLabel;
  @override
  final String booleanLabel;
  @override
  final String mapLabel;
  @override
  final String nullLabel;
  @override
  final String numberLabel;
  @override
  final String stringLabel;
  @override
  final String typeLabel;
  @override
  final String valueLabel;
  @override
  final String cancelLabel;
  @override
  final String updateLabel;
  @override
  final String northInitialLabel;
  @override
  final String southInitialLabel;
  @override
  final String westInitialLabel;
  @override
  final String eastInitialLabel;
  @override
  final String timestampLabel;
  @override
  final String latitudeLabel;
  @override
  final String longitudeLabel;
  @override
  final String geopointLabel;
  @override
  final String referenceLabel;

  const IdLocalizations({
    this.emailInputLabel = 'Surel',
    this.passwordInputLabel = 'Kata Sandi',
    this.signInActionText = 'Masuk',
    this.registerActionText = 'Daftar',
    this.linkEmailButtonText = 'Selanjutnya',
    this.signInWithPhoneButtonText = 'Masuk dengan Seluler',
    this.signInWithGoogleButtonText = 'Masuk dengan Google',
    this.signInWithAppleButtonText = 'Masuk dengan Apple',
    this.signInWithTwitterButtonText = 'Masuk dengan Twitter',
    this.signInWithFacebookButtonText = 'Masuk dengan Facebook',
    this.phoneVerificationViewTitleText = 'Masukkan nomor telepon',
    this.verifyPhoneNumberButtonText = 'Selanjutnya',
    this.verifyCodeButtonText = 'Verifikasi',
    this.unknownError = 'Terjadi masalah tidak terduga',
    this.smsAutoresolutionFailedError =
        'Gagal mendapatkan kode SMS otomatis. Mohon masukkan secara manual',
    this.verifyingSMSCodeText = 'Memverifikasi kode SMS...',
    this.enterSMSCodeText = 'Masukkan kode SMS',
    this.emailIsRequiredErrorText = 'Surel diperlukan',
    this.isNotAValidEmailErrorText = 'Masukkan surel yang valid',
    this.userNotFoundErrorText = 'Akun tidak tersedia',
    this.emailTakenErrorText = 'Email sudah digunakan oleh akun lainnya',
    this.accessDisabledErrorText =
        'Akses ke akun ini tidak tersedia untuk sementara',
    this.wrongOrNoPasswordErrorText =
        'Kata sandi tidak tepat atau pengguna tidak memiliki kata sandi',
    this.signInText = 'Masuk',
    this.registerText = 'Daftar',
    this.registerHintText = 'Tidak memiliki akun?',
    this.signInHintText = 'Sudah memiliki akun?',
    this.signOutButtonText = 'Keluar',
    this.phoneInputLabel = 'Nomor Telepon',
    this.phoneNumberInvalidErrorText = 'Nomor telepon tidak valid',
    this.phoneNumberIsRequiredErrorText = 'Nomor telepon diperlukan',
    this.profile = 'Profil',
    this.name = 'Nama',
    this.deleteAccount = 'Hapus Akun',
    this.passwordIsRequiredErrorText = 'Kata sandi diperlukan',
    this.confirmPasswordIsRequiredErrorText = 'Konfirmasi kata sandi',
    this.confirmPasswordDoesNotMatchErrorText = 'Kata sandi tidak sama',
    this.confirmPasswordInputLabel = 'Konfirmasi kata sandi',
    this.forgotPasswordButtonLabel = 'Lupa kata sandi?',
    this.forgotPasswordViewTitle = 'Lupa kata sandi',
    this.resetPasswordButtonLabel = 'Atur ulang kata sandi',
    this.verifyItsYouText = 'Verifikasi ini adalah Anda',
    this.differentMethodsSignInTitleText =
        'Gunakan salah satu metode untuk masuk dibawah ini',
    this.findProviderForEmailTitleText = 'Masukkan surel untuk melanjutkan',
    this.continueText = 'Lanjutkan',
    this.countryCode = 'Kode',
    this.invalidCountryCode = 'Kode tidak valid',
    this.chooseACountry = 'Pilih negara',
    this.enableMoreSignInMethods = 'Aktifkan lebih banyak metode masuk',
    this.signInMethods = 'Metode masuk',
    this.provideEmail = 'Sediakan surel dan kata sandi Anda',
    this.goBackButtonLabel = 'Kembali',
    this.passwordResetEmailSentText =
        'Kami telah mengirim tautan untuk mengatur ulang kata sandi ke surel Anda. Mohon periksa surel Anda.',
    this.forgotPasswordHintText =
        'Masukkan surel Anda, dan kami akan mengirimkan tautan untuk mengatur ulang kata sandi ke email Anda',
    this.emailLinkSignInButtonLabel = 'Masuk dengan magic link',
    this.signInWithEmailLinkViewTitleText = 'Masuk dengan magic link',
    this.signInWithEmailLinkSentText =
        'Kami telah mengirim magic link ke surel Anda. Periksa email Anda dan ikuti tautan untuk masuk',
    this.sendLinkButtonLabel = 'Kirim magic link',
    this.arrayLabel = 'himpunan',
    this.booleanLabel = 'boolean',
    this.mapLabel = 'peta',
    this.nullLabel = 'tidak ada',
    this.numberLabel = 'angka',
    this.stringLabel = 'teks',
    this.typeLabel = 'tipe',
    this.valueLabel = 'nilai',
    this.cancelLabel = 'batalkan',
    this.updateLabel = 'perbarui',
    this.northInitialLabel = 'U', // utara
    this.southInitialLabel = 'S', // selatan
    this.westInitialLabel = 'B', // barat
    this.eastInitialLabel = 'T', // timur
    this.timestampLabel = 'waktu',
    this.longitudeLabel = 'garis bujur',
    this.latitudeLabel = 'garis lintang',
    this.geopointLabel = 'geografis',
    this.referenceLabel = 'referensi',
  });
}
