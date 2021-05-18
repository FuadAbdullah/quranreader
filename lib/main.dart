import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:arabic_numbers/arabic_numbers.dart';

void main() {
  runApp(ApiCall());
}

class ApiCall extends StatelessWidget {
  const ApiCall({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "API Call Application", home: ApiCallCore());
  }
}

class ApiCallCore extends StatefulWidget {
  const ApiCallCore({Key key}) : super(key: key);

  @override
  _ApiCallCoreState createState() => _ApiCallCoreState();
}

class _ApiCallCoreState extends State<ApiCallCore> {
  final domain = "api.alquran.cloud";
  var reqUrl = "v1/surah/1/ar.alafasy";
  var fontList = ["Noor E Hidayat", "Quran Me", "Maddina", "Amiri"];
  var surahList = [];
  var displayFont = "Quran Me";
  var displaySurah = "1";
  final bismillah = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";

  // Future<Album> futureAlbum;
  Future<Surah> futureSurah;

  // Future<http.Response> fetchAlbum() {
  //   return http.get(Uri.https('jsonplaceholder.typicode.com', 'albums/1'));
  // }

  Future<http.Response> fetchSurah() {
    return http.get(Uri.https(domain, reqUrl));
  }

  // Future<http.Response> fetchSurah() {
  //   return http.get(Uri.https('api.alquran.cloud', 'v1/ayah/2:255/ar.alafasy'));
  // }

  // Future<Album> initAlbum() async {
  //   final res = await fetchAlbum();
  //
  //   if (res.statusCode == 200) {
  //     return Album.fromJson(jsonDecode(res.body));
  //   } else {
  //     throw Exception('Failed to load Album');
  //   }
  // }

  Future<Surah> initSurah() async {
    final res = await fetchSurah();
    if (res.statusCode == 200) {
      var surah = Surah.fromJson(jsonDecode(res.body));
      var excludeBismillah = surah.verses[0]['text'].replaceAll(bismillah, "");
      if (displaySurah != "1") {
        surah.verses[0]['text'] = excludeBismillah;
      }
      return surah;
    } else {
      throw Exception("Failed to load Surah");
    }
  }

  @override
  void initState() {
    super.initState();
    // futureAlbum = initAlbum();
    surahPop();
    futureSurah = initSurah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Quran Reader App"),
          centerTitle: true,
        ),
        endDrawer: Drawer(),
        body: Body());
  }

  void surahPop() {
    for (int i = 1; i <= 114; i++) {
      surahList.add(i.toString());
    }
    print(surahList);
  }

  String arabicNum(num) {
    var arNum = ArabicNumbers().convert(num);
    return arNum;
  }

  Widget Body() {
    return Container(
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
          // FutureBuilder<Album>(
          //   future: futureAlbum,
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return Text(snapshot.data.title);
          //     } else if (snapshot.hasError) {
          //       return Text(snapshot.error);
          //     }
          //
          //     return CircularProgressIndicator();
          //   },
          // )

          DropdownButtonFormField(
            items: surahList.map((surah) {
              return DropdownMenuItem(
                  value: surah,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(surah),
                      )
                    ],
                  ));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                displaySurah = newValue;
                reqUrl = "v1/surah/$displaySurah/ar.alafasy";
                futureSurah = initSurah();
              });
            },
            value: displaySurah,
          ),
          DropdownButtonFormField(
            items: fontList.map((String font) {
              return DropdownMenuItem(
                  value: font,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(font),
                      )
                    ],
                  ));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                displayFont = newValue;
              });
            },
            value: displayFont,
          ),
          FutureBuilder<Surah>(
              future: futureSurah,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // return Text(snapshot.data.text);
                  return Expanded(
                    child: Scrollbar(
                      isAlwaysShown: true,
                      hoverThickness: 20.0,
                      thickness: 10.0,
                      radius: Radius.circular(2.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          for (int i = 0; i < snapshot.data.numberOfAyat; i++)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.shade300, spreadRadius: 1.0)
                                    ]),
                                child: RichText(
                                  text: TextSpan(
                                      style: fontStyling(displayFont),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${snapshot.data.verses[i]['text']} \uFD3F${arabicNum(i + 1)}\uFD3E",
                                        ),
                                        // WidgetSpan(
                                        //     child: Padding(
                                        //         padding:
                                        //             const EdgeInsets.symmetric(
                                        //                 horizontal: 2.0,
                                        //                 vertical: 10.0),
                                        //         child: Icon(Icons.star)))
                                      ]),
                                  textAlign: TextAlign.right,
                                  softWrap: true,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              })
        ]));
  }

  fontStyling(font) {
    if (font == "Amiri") {
      return GoogleFonts.amiri(
          fontWeight: FontWeight.normal, fontSize: 28, color: Colors.black);
    } else {
      return TextStyle(
          fontFamily: "$font",
          fontWeight: FontWeight.normal,
          fontSize: 28,
          color: Colors.black);
    }
  }
}

//
// class Album {
//   final int userId;
//   final int id;
//   final String title;
//
//   Album({@required this.userId, @required this.id, @required this.title});
//
//   factory Album.fromJson(Map<String, dynamic> json) {
//     return Album(userId: json['userId'], id: json['id'], title: json['title']);
//   }
// }

class Surah {
  final int code;
  final String status;
  final verses;
  final title;
  final titleEn;
  final numberOfAyat;

  Surah(
      {@required this.code,
      @required this.status,
      @required this.verses,
      @required this.title,
      @required this.titleEn,
      @required this.numberOfAyat});

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
        code: json['code'],
        status: json['status'],
        verses: json['data']['ayahs'],
        title: json['data']['name'],
        titleEn: json['data']['englishName'],
        numberOfAyat: json['data']['numberOfAyahs']);
  }
}

//
// class Surah {
//   final int code;
//   final String status;
//   final text;
//   final title;
//   final titleEn;
//
//   Surah(
//       {@required this.code,
//         @required this.status,
//         @required this.text,
//         @required this.title,
//         @required this.titleEn});
//
//   factory Surah.fromJson(Map<String, dynamic> json) {
//     return Surah(
//         code: json['code'],
//         status: json['status'],
//         text: json['data']['text'],
//         title: json['data']['surah']['name'],
//         titleEn: json['data']['surah']['englishName']);
//   }
// }
