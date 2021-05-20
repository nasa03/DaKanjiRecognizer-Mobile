import 'package:da_kanji_mobile/view/ChangelogScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get_it/get_it.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:da_kanji_mobile/provider/Settings.dart';
import 'package:da_kanji_mobile/provider/Changelog.dart';



/// The "home"-screen
/// 
/// If a new version was installed shows a popup with the CHANGELOG of this 
/// version. Otherwise navigates to the "draw"-screen.
class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  ScrollController _scrollController;

  @override
  void initState() { 
    super.initState();

    _scrollController = ScrollController();

    // after the page was build 
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // if a new version was installed open the what's new pop up 
      if(GetIt.I<Changelog>().showChangelog){
        GetIt.I<Changelog>().showChangelog = false;

        // what's new dialogue 
        showDialog(
          context: context,
          builder: (BuildContext context){ 
            return SimpleDialog(
              title: Center(child: Text("🎉 What's new 🎉")),
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(
                        child: Scrollbar(
                          isAlwaysShown: true,
                          controller: _scrollController,
                          child: Markdown(
                            selectable: false,
                            controller: _scrollController,
                            data: GetIt.I<Changelog>().newestChangelog,
                            onTapLink:
                            (String text, String url, String title) async {
                              if(await canLaunch(url))
                                launch(url);
                            },
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 3/4,
                        height: MediaQuery.of(context).size.height * 2/4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: 
                                MaterialStateProperty.all(
                                  Color.fromARGB(100, 150, 150, 150)
                                )
                            ),
                            onPressed: () => Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => ChangelogScreen()),
                            ),
                            child: Text("Complete log")
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: 
                                MaterialStateProperty.all(
                                  Color.fromARGB(100, 150, 150, 150)
                                )
                            ),
                            onPressed: () async {
                              GetIt.I<Settings>().save();
                              Navigator.pushNamedAndRemoveUntil(
                                context, "/home", (Route<dynamic> route) => false);
                            },
                            child: Text("close")
                          ),
                        ],
                      )
                    ]
                  )
                )
              ],
            );
          }
        ).then((value) {
          // save that the dialogue was shown and open the default screen
          GetIt.I<Settings>().save();
          Navigator.pushNamedAndRemoveUntil(
            context, "/home", (Route<dynamic> route) => false);
        });
      }
      // otherwise open the default screen
      else{
        Navigator.
          pushNamedAndRemoveUntil(context, "/drawing", (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold();
  }
}
