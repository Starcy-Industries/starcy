import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum DeviceType { mobile, tablet, desktop }

class DeviceUtils {
  static DeviceType getDeviceType() {
    double width = ScreenUtil().screenWidth;

    if (width >= 1200) {
      return DeviceType.desktop;
    } else if (width >= 700) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}

/// Extension for responsive font sizes
extension SizeExtension on num {
  double get appSp {
    DeviceType deviceType = DeviceUtils.getDeviceType();

    double scaleFactor;
    switch (deviceType) {
      case DeviceType.desktop:
        scaleFactor = 0.8;
        break;
      case DeviceType.tablet:
        scaleFactor = 0.9;
        break;
      case DeviceType.mobile:
        scaleFactor = 1;
    }

    return (this *
            scaleFactor *
            min(
              ScreenUtil().screenWidth / ScreenUtil.defaultSize.width,
              ScreenUtil().screenHeight / ScreenUtil.defaultSize.height,
            ))
        .clamp(this * 0.85, this * 1.15);
  }
}
