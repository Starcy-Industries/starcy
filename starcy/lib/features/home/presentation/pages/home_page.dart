import 'package:auto_route/auto_route.dart';
import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starcy/features/home/presentation/pages/setting_page.dart';
import 'package:starcy/utils/sp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingPage();
    return CupertinoPageScaffold(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        drawer: _buildDrawer(context),
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(
              maxWidth: 550,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App header with logo and beta tag
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.appSp, vertical: 12.appSp),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 15, 15, 15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menu button with improved touch target
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12.appSp),
                        ),
                        child: Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu_rounded,
                                color: Colors.white),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            iconSize: 22.appSp,
                            padding: EdgeInsets.all(8.appSp),
                            constraints: BoxConstraints(
                                minWidth: 40.appSp, minHeight: 40.appSp),
                          ),
                        ),
                      ),

                      // Logo and app name with better alignment
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36.appSp,
                            height: 36.appSp,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepOrange,
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 2.0.appSp, right: 1.appSp),
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.appSp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.appSp),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Grok 3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.appSp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2.appSp),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.appSp,
                              vertical: 2.appSp,
                            ),
                            margin: EdgeInsets.only(left: 8.appSp),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(4.appSp),
                            ),
                            child: Text(
                              'beta',
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 10.appSp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Document edit button with improved styling
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12.appSp),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit_document,
                              color: Colors.white),
                          onPressed: () {},
                          iconSize: 22.appSp,
                          padding: EdgeInsets.all(8.appSp),
                          constraints: BoxConstraints(
                              minWidth: 40.appSp, minHeight: 40.appSp),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expanded area (empty for now)
                Expanded(child: Container()),

                // Bottom input field
                Padding(
                  padding: EdgeInsets.all(16.appSp),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.appSp,
                      vertical: 12.appSp,
                    ).copyWith(top: 6.appSp),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade900,
                          Colors.grey.shade800.withOpacity(0.8),
                          Colors.grey.shade900.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(24.appSp),
                      border: Border.all(
                        color: Colors.grey.shade800.withOpacity(0.5),
                        width: 2,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // First row - Text field with 'Ask Anything' hint
                        Container(
                          height: 40.appSp,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ask Anything',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16.appSp,
                            ),
                          ),
                        ),

                        // Second row - Action buttons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_rounded,
                                  color: Colors.grey),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            SizedBox(width: 8.appSp),
                            Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                SizedBox(width: 4.appSp),
                                Text(
                                  'DeepSearch',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.appSp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16.appSp),
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_outline,
                                    color: Colors.grey),
                                SizedBox(width: 4.appSp),
                                Text(
                                  'Think',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.appSp,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.mic, color: Colors.grey),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            SizedBox(width: 8.appSp),
                            Container(
                              width: 32.appSp,
                              height: 32.appSp,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey.shade800,
                                    Colors.grey.shade700,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16.appSp),
                              ),
                              child: const Icon(Icons.graphic_eq,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.appSp),
          child: Column(
            children: [
              // Search bar at the top
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.appSp),
                child: Container(
                  height: 44.appSp,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10.appSp),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.appSp),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: Colors.grey.shade400, size: 20.appSp),
                      SizedBox(width: 10.appSp),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16.appSp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation items
              _buildDrawerItem(
                icon: Icons.build_circle_rounded,
                label: 'Starcy',
                isSelected: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 16.appSp),

              _buildDrawerItem(
                icon: Icons.grid_view_rounded,
                label: 'Explore GPTs',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 40.appSp),

              // No chats message
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.appSp,
                      height: 80.appSp,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16.appSp),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey.shade600,
                        size: 40.appSp,
                      ),
                    ),
                    SizedBox(height: 12.appSp),
                    Text(
                      'No chats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.appSp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.appSp),
                    Text(
                      'As you talk with ChatGPT, your\nconversations will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14.appSp,
                      ),
                    ),
                    SizedBox(height: 24.appSp),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.appSp,
                          vertical: 16.appSp,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.appSp),
                        ),
                      ),
                      child: Text(
                        'Start new chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.appSp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // User profile at the bottom
              Builder(builder: (context) {
                final user = Supabase.instance.client.auth.currentSession?.user;
                // if (user == null) {
                //   return Container();
                // }
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // open setting
                    showCupertinoModalSheet(
                      context: context,
                      builder: (context) => const SettingPage(),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.appSp),
                    child: Row(
                      children: [
                        Container(
                          width: 32.appSp,
                          height: 32.appSp,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user?.email?.split('')[0] ?? 'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.appSp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.appSp),
                        Text(
                          '${user?.email?.split('@')[0]}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.appSp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.more_horiz, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey.shade400,
        size: 24.appSp,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade400,
          fontSize: 16.appSp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Colors.grey.shade900.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.appSp),
      ),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.appSp, vertical: 4.appSp),
    );
  }
}
