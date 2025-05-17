import 'package:flutter/material.dart';
import 'package:starcy/utils/sp.dart';

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool showArrow;
  final bool isLast;
  final Function()? onTap;

  SettingItem({
    required this.icon,
    required this.title,
    this.value,
    this.showArrow = true,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            onTap?.call();
          },
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 0.appSp, vertical: 8.appSp),
            child: Row(
              children: [
                // Leading icon
                Container(
                  padding: EdgeInsets.all(4.appSp),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 44, 44, 46),
                    borderRadius: BorderRadius.circular(8.appSp),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.grey.shade400,
                    size: 20.appSp,
                    weight: 350,
                  ),
                ),
                SizedBox(width: 16.appSp),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.appSp,
                  ),
                ),
                SizedBox(width: 16.appSp),
                // Value and arrow
                if (value != null || showArrow)
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (value != null)
                          Expanded(
                            child: Text(
                              value!,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14.appSp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        if (showArrow)
                          Padding(
                            padding: EdgeInsets.only(left: 4.appSp),
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade600,
                              size: 22.appSp,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
