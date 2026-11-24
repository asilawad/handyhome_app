// ignore: constant_identifier_names
const String IMAGE_PATH = "assets/images";
const String baseIconUrl = 'assets/icons/';

class ImagePath {
  static const String splashBackground = "$IMAGE_PATH/splash.png";
  static const String iconHome = "$IMAGE_PATH/iconHome.svg";
  static const String wordHome = "$IMAGE_PATH/homeword.svg";
  static const String takeCare = "$IMAGE_PATH/takecare.svg";
  static const String onboarding = "$IMAGE_PATH/onBording.png";
  static const String plumbingIcon = "$IMAGE_PATH/plumbingIcon.svg";
  static const String resetPasswordImage = "$IMAGE_PATH/resetPassword.png";
  static const String undrawVerified = "$IMAGE_PATH/undraw_verified.png";
  static const String cleaningIcon = "$IMAGE_PATH/cleaningIcon.svg";
  static const String newPasswordImage = "$IMAGE_PATH/newPassword.png";
  static const String onboarding1 = "$IMAGE_PATH/onboarding1.png";
  static const String onboarding2 = "$IMAGE_PATH/onboarding2.png";
  static const String onboarding3 = "$IMAGE_PATH/onboarding3.png";

  /// Fallback photo for a service without its own image.
  static const String serviceImage = "$IMAGE_PATH/services/tools.jpg";

  static const Map<int, String> _serviceImages = {
    1: "$IMAGE_PATH/services/home_cleaning.jpg",
    2: "$IMAGE_PATH/services/sofa_cleaning.jpg",
    3: "$IMAGE_PATH/services/electrical_wiring.jpg",
    4: "$IMAGE_PATH/services/lighting_installation.jpg",
    5: "$IMAGE_PATH/services/leak_repair.jpg",
    6: "$IMAGE_PATH/services/water_heater.jpg",
    7: "$IMAGE_PATH/services/furniture_moving.jpg",
    8: "$IMAGE_PATH/services/furniture_assembly.jpg",
    9: "$IMAGE_PATH/services/laptop_repair.jpg",
    10: "$IMAGE_PATH/services/software_setup.jpg",
    11: "$IMAGE_PATH/services/network_cabling.jpg",
    12: "$IMAGE_PATH/services/router_setup.jpg",
  };

  /// Photo for the service with [id], or [serviceImage] if it has none.
  static String serviceImageFor(int? id) => _serviceImages[id] ?? serviceImage;

  static const String doneImage = "$IMAGE_PATH/done_image.png";
  static const String customServiceImage =
      "$IMAGE_PATH/custom_service_image.png";
  static const String codeVerificationImage =
      "$IMAGE_PATH/code_verification_image.png";
}

class IconPath {
  static const String bookingIcon = '${baseIconUrl}booking_icon.svg';
  static const String homeIcon = '${baseIconUrl}home_icon.svg';
  static const String notificationIcon = '${baseIconUrl}notification_icon.svg';
  static const String profileIcon = '${baseIconUrl}profile_icon.svg';
  static const String searchIcon = '${baseIconUrl}search_icon.svg';
  static const String dollarIcon = '${baseIconUrl}dollar_icon.svg';
  static const String logoutIcon = '${baseIconUrl}logout_icon.svg';
  static const String mobilePrefixIcon = '${baseIconUrl}mobile_prefix_icon.svg';
  static const String loadingIcon = '${baseIconUrl}loading_icon.svg';
}
