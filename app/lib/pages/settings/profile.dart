import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omi/backend/preferences.dart';
import 'package:omi/pages/memories/page.dart';
import 'package:omi/pages/payments/payments_page.dart';
import 'package:omi/pages/settings/change_name_widget.dart';
import 'package:omi/pages/settings/language_selection_dialog.dart';
import 'package:omi/pages/settings/people.dart';
import 'package:omi/pages/settings/privacy.dart';
import 'package:omi/pages/speech_profile/page.dart';
import 'package:omi/providers/home_provider.dart';
import 'package:omi/utils/analytics/mixpanel.dart';
import 'package:omi/utils/other/temp.dart';
import 'package:provider/provider.dart';

import 'delete_account.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Future<void> _checkRecordingPermission() async {
  //   final permission = await getStoreRecordingPermission();
  //   if (mounted) {
  //     setState(() {
  //       if (permission != null) {
  //         SharedPreferencesUtil().permissionStoreRecordingsEnabled = permission;
  //       } else {
  //         SharedPreferencesUtil().permissionStoreRecordingsEnabled = false;
  //       }
  //     });
  //   }
  // }

  @override
  void initState() {
    // _checkRecordingPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
        child: ListView(
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
              title: const Text('Identifying Others', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Tell Omi who said it 🗣️'),
              trailing: const Icon(Icons.people, size: 20),
              onTap: () {
                routeToPage(context, const UserPeoplePage());
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
              title: Text(
                  SharedPreferencesUtil().givenName.isEmpty
                      ? 'About YOU'
                      : 'About ${SharedPreferencesUtil().givenName.toUpperCase()}',
                  style: const TextStyle(color: Colors.white)),
              subtitle: const Text('What Omi has learned about you 👀'),
              trailing: const Icon(Icons.self_improvement, size: 20),
              onTap: () {
                routeToPage(context, const MemoriesPage());
                MixpanelManager().pageOpened('Profile Facts');
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
              title: const Text('Speech Profile', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Teach Omi your voice'),
              trailing: const Icon(Icons.multitrack_audio, size: 20),
              onTap: () {
                routeToPage(context, const SpeechProfilePage());
                MixpanelManager().pageOpened('Profile Speech Profile');
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
              title: Text(
                SharedPreferencesUtil().givenName.isEmpty ? 'Set Your Name' : 'Change Your Name',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(SharedPreferencesUtil().givenName.isEmpty ? 'Not set' : SharedPreferencesUtil().givenName),
              trailing: const Icon(Icons.person, size: 20),
              onTap: () async {
                MixpanelManager().pageOpened('Profile Change Name');
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ChangeNameWidget();
                  },
                ).whenComplete(() => setState(() {}));
              },
            ),
            Consumer<HomeProvider>(
              builder: (context, homeProvider, _) {
                final languageName = homeProvider.userPrimaryLanguage.isNotEmpty
                    ? homeProvider.availableLanguages.entries
                        .firstWhere(
                          (element) => element.value == homeProvider.userPrimaryLanguage,
                        )
                        .key
                    : 'Not set';
                
                return ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
                  title: const Text('Primary Language', style: TextStyle(color: Colors.white)),
                  subtitle: Text(languageName),
                  trailing: const Icon(Icons.language, size: 20),
                  onTap: () async {
                    MixpanelManager().pageOpened('Profile Change Language');
                    // Force the dialog to show even if the user has already set a language
                    await LanguageSelectionDialog.show(context, isRequired: false, forceShow: true);
                    // Refresh the UI after language is updated
                    await homeProvider.setupUserPrimaryLanguage();
                    setState(() {});
                  },
                );
              },
            ),
            const SizedBox(height: 56),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CREATORS',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
              title: const Text('Payments', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Add or change your payment method'),
              trailing: const Icon(Icons.attach_money_outlined, size: 20),
              onTap: () {
                routeToPage(context, const PaymentsPage());
                // MixpanelManager().pageOpened('Profile Connect Stripe');
              },
            ),
            const SizedBox(height: 56),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'PREFERENCES',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    SharedPreferencesUtil().optInAnalytics = !SharedPreferencesUtil().optInAnalytics;
                    SharedPreferencesUtil().optInAnalytics
                        ? MixpanelManager().optInTracking()
                        : MixpanelManager().optOutTracking();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            routeToPage(context, const PrivacyInfoPage());
                            MixpanelManager().pageOpened('Share Analytics Data Details');
                          },
                          child: const Text(
                            'Help improve Omi by sharing anonymized analytics data',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: SharedPreferencesUtil().optInAnalytics
                              ? const Color.fromARGB(255, 150, 150, 150)
                              : Colors.transparent, // Fill color when checked
                          border: Border.all(
                            color: const Color.fromARGB(255, 150, 150, 150),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: 22,
                        height: 22,
                        child: SharedPreferencesUtil().optInAnalytics // Show the icon only when checked
                            ? const Icon(
                                Icons.check,
                                color: Colors.white, // Tick color
                                size: 18,
                              )
                            : null, // No icon when unchecked
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
            //   child: InkWell(
            //     onTap: () {
            //       routeToPage(context, const RecordingsStoragePermission());
            //     },
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(vertical: 12.0),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Expanded(
            //             child: GestureDetector(
            //               onTap: () {
            //                 routeToPage(context, const RecordingsStoragePermission());
            //               },
            //               child: const Text(
            //                 'Allow Omi to store recordings of your conversations',
            //                 style: TextStyle(
            //                   color: Colors.grey,
            //                   fontSize: 16,
            //                   decoration: TextDecoration.underline,
            //                 ),
            //               ),
            //             ),
            //           ),
            //           const SizedBox(
            //             width: 16,
            //           ),
            //           Container(
            //             decoration: BoxDecoration(
            //               color: SharedPreferencesUtil().permissionStoreRecordingsEnabled
            //                   ? const Color.fromARGB(255, 150, 150, 150)
            //                   : Colors.transparent,
            //               border: Border.all(
            //                 color: const Color.fromARGB(255, 150, 150, 150),
            //                 width: 2,
            //               ),
            //               borderRadius: BorderRadius.circular(12),
            //             ),
            //             width: 22,
            //             height: 22,
            //             child: SharedPreferencesUtil().permissionStoreRecordingsEnabled
            //                 ? const Icon(
            //                     Icons.check,
            //                     color: Colors.white,
            //                     size: 18,
            //                   )
            //                 : null,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 32),
            // Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'OTHER',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
              title: const Text('Your User ID', style: TextStyle(color: Colors.white)),
              subtitle: Text(SharedPreferencesUtil().uid),
              trailing: const Icon(Icons.copy_rounded, size: 20, color: Colors.white),
              onTap: () {
                Clipboard.setData(ClipboardData(text: SharedPreferencesUtil().uid));
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('User ID copied to clipboard')));
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
              title: const Text('Delete Account', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Delete your account and all data'),
              trailing: const Icon(
                Icons.warning,
                size: 20,
              ),
              onTap: () {
                MixpanelManager().pageOpened('Profile Delete Account Dialog');
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteAccount()));
              },
            )
          ],
        ),
      ),
    );
  }
}
