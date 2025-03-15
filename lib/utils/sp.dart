import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SizeExtension on num {
  double get appSp => (
          //
          this *
              min(
                  //
                  min(550, ScreenUtil().screenWidth) /
                      ScreenUtil.defaultSize.width
                  //
                  ,
                  max(ScreenUtil().screenHeight, 700) /
                      ScreenUtil.defaultSize.height
                  //
                  )
      //
      );
}
