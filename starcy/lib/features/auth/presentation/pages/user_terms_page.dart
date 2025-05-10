import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:starcy/utils/sp.dart';

@RoutePage()
class UserTermsPage extends StatelessWidget {
  const UserTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(
              maxWidth: 550,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.all(24.appSp).copyWith(bottom: 0.appSp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to',
                              style: TextStyle(
                                fontSize: 26.appSp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'StarCy',
                              style: TextStyle(
                                fontSize: 26.appSp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.appSp),
                            Text(
                              'This official app is free, syncs your history across devices, and brings you the latest emotional chat improvements.',
                              style: TextStyle(
                                fontSize: 14.appSp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(24.appSp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSection(
                              'Chats feel super human-like',
                              'StarCy may provide incredibly natural responses, but they might not always be 100% accurate about people, places, or facts.',
                            ),
                            SizedBox(height: 24.appSp),
                            _buildSection(
                              'Keep it personal',
                              'You can share sensitive info if thats what you want. Your chats are private, secure, and never reviewed or used to train our models unless you opt in.',
                            ),
                            SizedBox(height: 24.appSp),
                            _buildSection(
                              'Just Say "Hey StarCy" to Talk',
                              'Start chatting anytime by saying "Hey StarCy"—your friendly AI is always ready to listen and chat, hands-free!',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(24.appSp),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48.appSp,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.router.replace(const HomeRoute()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(44),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.appSp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.only(top: 4.appSp),
              width: 30.appSp,
              height: 30.appSp,
              alignment: Alignment.center,
              child: Icon(
                title == 'Chats feel super human-like'
                    ? Icons.search_rounded
                    : title == 'Keep it personal'
                        ? Icons.lock
                        : Icons.settings,
                size: 30.appSp,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 12.appSp),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.appSp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 42.appSp),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 14.appSp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
