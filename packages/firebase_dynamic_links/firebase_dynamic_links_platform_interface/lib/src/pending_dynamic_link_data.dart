import 'pending_dynamic_link_data_android.dart';
import 'pending_dynamic_link_data_ios.dart';

/// Provides data from received dynamic link.
class PendingDynamicLinkData {
  const PendingDynamicLinkData(this.link, this.android, this.ios);

  /// Provides Android specific data from received dynamic link.
  ///
  /// Can be null if [link] equals null or dynamic link was not received on an
  /// Android device.
  final PendingDynamicLinkDataAndroid? android;

  /// Provides iOS specific data from received dynamic link.
  ///
  /// Can be null if [link] equals null or dynamic link was not received on an
  /// iOS device.
  final PendingDynamicLinkDataIOS? ios;

  /// Deep link parameter of the dynamic link.
  final Uri link;
}
