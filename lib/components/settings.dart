import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starcy/components/setting_item.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:starcy/utils/sp.dart';
import 'package:url_launcher/url_launcher.dart';

enum SettingEvent {
  toggleMic,
  logout,
}

typedef SettingAction = void Function(SettingEvent event);

class Settings extends StatelessWidget {
  final String initials;
  final String email;
  final String name;
  final bool isMuted;
  final SettingAction onEvent;

  const Settings({
    super.key,
    required this.initials,
    required this.name,
    required this.email,
    required this.isMuted,
    required this.onEvent,
  });

  @override
  Widget build(BuildContext context) {
    // if (1.sw > 550) return _DesktopUI();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // background
          Positioned(
            left: 0,
            right: 0,
            bottom: -0.95.sw,
            child: Container(
              width: 1.5.sw,
              height: 1.5.sw,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.75,
                  colors: [
                    const Color(0xff424952).withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.5)
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),
          // foreground
          Positioned(
            left: 0,
            right: 0,
            bottom: 0.sw,
            child: SafeArea(
              bottom: false,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.appSp)
                    .copyWith(top: 16.appSp, bottom: 16.appSp),
                decoration: BoxDecoration(
                  color: const Color(0xff1E1E1E),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.grey.shade800.withOpacity(0.5),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile initials
                      Center(
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: 46.appSp, bottom: 8.appSp),
                          child: Stack(
                            children: [
                              Container(
                                width: 64.appSp,
                                height: 64.appSp,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 44, 44, 46),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Colors.grey.shade800.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.appSp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Profile email
                      Center(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.appSp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Section: Account
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16.appSp, top: 32.appSp, bottom: 4.appSp),
                        child: Text(
                          'ACCOUNT',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12.appSp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.appSp),
                        decoration: BoxDecoration(
                          color: const Color(0xff1E1E1E),
                          borderRadius: BorderRadius.circular(16.appSp),
                        ),
                        child: Column(
                          children: [
                            SettingItem(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              value: email,
                            ),
                            SettingItem(
                              icon: Icons.add_circle_outline,
                              title: 'Subscription',
                              value: 'Free Plan',
                            ),
                            SettingItem(
                              icon: Icons.person_outline,
                              title: 'Personalization',
                              showArrow: true,
                              onTap: () {
                                context.router
                                    .push(OnboardingRoute(isEdit: true));
                              },
                            ),
                            SettingItem(
                              icon: Icons.data_usage_outlined,
                              title: 'Data Controls',
                              showArrow: true,
                            ),
                          ],
                        ),
                      ),

                      // Section: Settings
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16.appSp, top: 32.appSp, bottom: 4.appSp),
                        child: Text(
                          'SETTINGS',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12.appSp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.appSp),
                        decoration: BoxDecoration(
                          color: const Color(0xff1E1E1E),
                          borderRadius: BorderRadius.circular(16.appSp),
                        ),
                        child: Column(
                          children: [
                            SettingItem(
                              icon: Icons.mic,
                              title: 'Mic',
                              value: isMuted ? "OFF" : "ON",
                              showArrow: false,
                              onTap: () => onEvent(SettingEvent.toggleMic),
                            ),
                          ],
                        ),
                      ),

                      // Section: About
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16.appSp, top: 24.appSp, bottom: 4.appSp),
                        child: Text(
                          'ABOUT',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12.appSp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.appSp),
                        decoration: BoxDecoration(
                          color: const Color(0xff1E1E1E),
                          borderRadius: BorderRadius.circular(16.appSp),
                        ),
                        child: Column(
                          children: [
                            SettingItem(
                              icon: Icons.help_outline,
                              title: 'Help Center',
                              showArrow: false,
                              onTap: () {
                                launchUrl(
                                  Uri.parse('https://starcyindustries.com'),
                                );
                              },
                            ),
                            SettingItem(
                              icon: Icons.book,
                              title: 'Terms of Use',
                              showArrow: false,
                              onTap: () {
                                launchUrl(
                                  Uri.parse(
                                      'https://starcyindustries.com/terms-of-use'),
                                );
                              },
                            ),
                            SettingItem(
                              icon: Icons.lock_rounded,
                              title: 'Privacy Policy',
                              showArrow: false,
                              onTap: () {
                                launchUrl(
                                  Uri.parse(
                                      'https://starcyindustries.com/privacy-policy'),
                                );
                              },
                            ),
                            SettingItem(
                              icon: Icons.fiber_manual_record,
                              title: 'Version',
                              value: '1.2025.012',
                              showArrow: false,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      // Section: Logout
                      SizedBox(height: 36.appSp),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.appSp),
                        child: Column(
                          children: [
                            SettingItem(
                              icon: Icons.login_rounded,
                              title: 'Log out',
                              showArrow: false,
                              isLast: true,
                              onTap: () => onEvent(SettingEvent.logout),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.appSp),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class _DesktopUI extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final user = Supabase.instance.client.auth.currentSession?.user;
//     final email = user?.email ?? 'N/A';
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Container(
//           alignment: Alignment.center,
//           constraints: const BoxConstraints(
//             maxWidth: 520,
//           ),
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: -0.95.sw,
//                 child: Container(
//                   width: 1.5.sw,
//                   height: 1.5.sw,
//                   decoration: BoxDecoration(
//                     gradient: RadialGradient(
//                       center: Alignment.center,
//                       radius: 0.75,
//                       colors: [
//                         const Color(0xff424952).withValues(alpha: 0.7),
//                         Colors.white.withValues(alpha: 0.5)
//                       ],
//                       stops: const [0.2, 1.0],
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   margin: EdgeInsets.symmetric(horizontal: 8.appSp)
//                       .copyWith(top: 12.appSp, bottom: 0.appSp),
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(28.appSp),
//                       topRight: Radius.circular(28.appSp),
//                     ),
//                     border: Border.all(
//                       color: Colors.grey.shade800.withOpacity(0.5),
//                       width: 0.5,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 15,
//                         spreadRadius: 1,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Center(
//                           child: Padding(
//                             padding:
//                                 EdgeInsets.only(top: 32.appSp, bottom: 8.appSp),
//                             child: Stack(
//                               children: [
//                                 // Profile image
//                                 Container(
//                                   width: 64.appSp,
//                                   height: 64.appSp,
//                                   decoration: BoxDecoration(
//                                     color:
//                                         const Color.fromARGB(255, 44, 44, 46),
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color:
//                                           Colors.grey.shade800.withOpacity(0.3),
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       user?.email?.split('')[0].toUpperCase() ??
//                                           '',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16.appSp,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         Center(
//                           child: FutureBuilder(
//                               future: Supabase.instance.client
//                                   .from('profiles')
//                                   .select('data')
//                                   .eq('id', user?.id ?? '')
//                                   .single(),
//                               builder: (context, response) {
//                                 final name = response.data?['data']?['name'];
//                                 return Text(
//                                   name ?? '',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 15.appSp,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 );
//                               }),
//                         ),
//
//                         // ACCOUNT SECTION
//                         Padding(
//                           padding: EdgeInsets.only(
//                               left: 16.appSp, top: 32.appSp, bottom: 4.appSp),
//                           child: Text(
//                             'ACCOUNT',
//                             style: TextStyle(
//                               color: Colors.grey.shade500,
//                               fontSize: 12.appSp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           margin: EdgeInsets.symmetric(horizontal: 16.appSp),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16.appSp),
//                           ),
//                           child: Column(
//                             children: [
//                               SettingItem(
//                                 icon: Icons.email_outlined,
//                                 title: 'Email',
//                                 value: email,
//                               ),
//                               SettingItem(
//                                 icon: Icons.add_circle_outline,
//                                 title: 'Subscription',
//                                 value: 'Free Plan',
//                               ),
//                               SettingItem(
//                                 icon: Icons.person_outline,
//                                 title: 'Personalization',
//                                 showArrow: true,
//                                 onTap: () {
//                                   context.router
//                                       .push(OnboardingRoute(isEdit: true));
//                                 },
//                               ),
//                               SettingItem(
//                                 icon: Icons.data_usage_outlined,
//                                 title: 'Data Controls',
//                                 showArrow: true,
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // SPEECH SECTION
//                         Padding(
//                           padding: EdgeInsets.only(
//                               left: 16.appSp, top: 24.appSp, bottom: 4.appSp),
//                           child: Text(
//                             'ABOUT',
//                             style: TextStyle(
//                               color: Colors.grey.shade500,
//                               fontSize: 12.appSp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           margin: EdgeInsets.symmetric(horizontal: 16.appSp),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16.appSp),
//                           ),
//                           child: Column(
//                             children: [
//                               SettingItem(
//                                 icon: Icons.help_outline,
//                                 title: 'Help Center',
//                                 showArrow: false,
//                               ),
//                               SettingItem(
//                                 icon: Icons.book,
//                                 title: 'Terms of Use',
//                                 showArrow: false,
//                                 onTap: () {
//                                   launchUrl(
//                                     Uri.parse(
//                                         'https://starcyindustries.com/terms-of-use'),
//                                   );
//                                 },
//                               ),
//                               SettingItem(
//                                 icon: Icons.lock_rounded,
//                                 title: 'Privacy Policy',
//                                 showArrow: false,
//                                 onTap: () {
//                                   launchUrl(
//                                     Uri.parse(
//                                         'https://starcyindustries.com/privacy-policy'),
//                                   );
//                                 },
//                               ),
//                               SettingItem(
//                                 icon: Icons.fiber_manual_record,
//                                 title: 'Version',
//                                 value: '1.2025.012',
//                                 showArrow: false,
//                                 isLast: true,
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 16.appSp),
//                         Container(
//                           margin: EdgeInsets.symmetric(horizontal: 16.appSp),
//                           child: Column(
//                             children: [
//                               SettingItem(
//                                 icon: Icons.login_rounded,
//                                 title: 'Log out',
//                                 showArrow: false,
//                                 isLast: true,
//                                 onTap: () async {
//                                   await Supabase.instance.client.auth.signOut();
//                                   if (context.mounted) {
//                                     context.router.push(const LoginRoute());
//                                   }
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 16.appSp),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
