import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:da_kanji_mobile/model/core/DrawingInterpreter.dart';
import 'package:da_kanji_mobile/model/core/Screens.dart';
import 'package:da_kanji_mobile/view/DaKanjiDrawer.dart';
import 'package:da_kanji_mobile/view/ChangelogScreen.dart';
import 'package:da_kanji_mobile/provider/PlatformDependentVariables.dart';
import 'package:da_kanji_mobile/locales_keys.dart';
import 'package:da_kanji_mobile/globals.dart';



/// The "about"-screen
/// 
/// Shows the *about.md* and a link to the "changelog"-screen 
class AboutScreen extends StatelessWidget {

  /// was this page opened by clicking on the tab in the drawer
  final bool openedByDrawer;

  final String about = LocaleKeys.AboutScreen_about_text.tr()
    .replaceAll("GITHUB_DESKTOP_REPO", GITHUB_DESKTOP_REPO)
    .replaceAll("GITHUB_MOBILE_REPO", GITHUB_MOBILE_REPO)
    .replaceAll("GITHUB_ML_REPO", GITHUB_ML_REPO)
    .replaceAll("GITHUB_ISSUES", GITHUB_ISSUES)
    .replaceAll("PRIVACY_POLICE", PRIVACY_POLICE)
    .replaceAll("RATE_ON_MOBILE_STORE", 
      GetIt.I<PlatformDependentVariables>().appStoreLink)
    .replaceAll("DAAPPLAB_STORE_PAGE", 
      GetIt.I<PlatformDependentVariables>().daapplabStorePage)
    .replaceAll("VERSION", "$VERSION#$BUILD_NR")
    .replaceAll("DISCORD_SERVER", DISCORD_INVITE)
    .replaceAll("BACKEND", GetIt.I<DrawingInterpreter>().usedBackend);

  AboutScreen(this.openedByDrawer);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DaKanjiDrawer(
        currentScreen: Screens.about,
        animationAtStart: !this.openedByDrawer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(image: AssetImage("media/banner.png"), width: 200,),
            // show the about.md
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: MarkdownBody(
                data: about,
                onTapLink: (text, url, title) {
                  launch(url);
                },
              ),
            ),
            // text with link to open the "changelog"-screen
            Row(
              children:[
                Container(
                  padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
                  child: GestureDetector(
                    child: Text(
                      LocaleKeys.AboutScreen_show_changelog.tr(),
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => ChangelogScreen()),
                    )
                  )
                )
              ]
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final InAppReview inAppReview = InAppReview.instance;

                        // TODO: add store id's
                        inAppReview.openStoreListing(
                          appStoreId: '...', 
                          microsoftStoreId: '...'
                        );
                      }, 
                      child: Text(LocaleKeys.AboutScreen_rate_this_app.tr())
                    ),
                  ),
                ],
              ),
            ),
          ]
        ),
      )
    );
  }
}
