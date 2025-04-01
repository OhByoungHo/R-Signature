import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_strategy/url_strategy.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'package:r_signature/consts.dart';

void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        Uri uri = Uri.parse(settings.name ?? "");
        String? arg = uri.queryParameters['arg'];

        return MaterialPageRoute(
          builder: (context) => MyHomePage(arg: arg),
        );
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      title: "R-Signature Service",
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String? arg;

  const MyHomePage({super.key, this.arg});

  @override
  Widget build(BuildContext context) {
    // TODO: arg 를 확인, 실제로 생성된 요청인지 조회하여 [유효한 / 유효하지 않은 URL ] 구분 필요
    // TODO: 예) MU_KEY = 'MU0141885' , AGENCY_GRP_CD = 'ITBAY' , RVW_FL_NO = '2025-03-24-002' 값으로 테이블(서명 요청) 조회하여 [ CNT > 0 ] 체크
    final argument = arg != null ? arg!.split('_') : [];
    final firstArg = argument.isNotEmpty ? argument[0] ?? '없음' : '없음';
    final secondArg = argument.length > 1 ? argument[1] ?? '없음' : '없음';
    final thirdArg = argument.length > 2 ? argument[2] ?? '없음' : '없음';

    GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

    Future<void> _saveAndUploadSignature(ui.Image image) async {
      try {

        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();
        var fileName = '${firstArg}_${secondArg}_${thirdArg}';

        // var url = Uri.parse('$SERVER_BASE_URL/signature/upload');
        // var request = http.MultipartRequest('POST', url)
        //   ..fields['firstArg'] = firstArg
        //   ..fields['secondArg'] = secondArg
        //   ..fields['thirdArg'] = thirdArg
        //   ..files.add(http.MultipartFile.fromBytes('file',pngBytes, filename:'$fileName.png'));
        //
        // print("request.fields : ${request.fields}");
        // print("request.files : ${request.files}");
        // print("request.headers : ${request.headers}");
        // print("request.method : ${request.method}");
        //
        // var response = await request.send();
        //
        // if (response.statusCode == 200) {
        //   print("업로드 성공");
        // } else {
        //   print("업로드 실패: ${response.statusCode}");
        // }
        String msg = '전송 처리가 완료되었습니다.';
        String action = await showAlertDialogOkConfirm(context, Icon(Icons.warning_outlined, color: Color(0XFFFEC337)), msg);
        Navigator.of(context).pop(true);
        html.window.closed;

      } catch (e) {
        print("에러 발생: $e");
      }
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ARGUMENT : [0] $firstArg [1] $secondArg [2] $thirdArg',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: Text(
                  textAlign: TextAlign.center,
                  INFOMATION,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
              LayoutBuilder(builder: (context, constraints) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(blurRadius: 10, color: Color(0XFFDDDDDD))
                        ],
                        color: Colors.white,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.indigo)),
                        child: SfSignaturePad(
                          key: _signaturePadKey,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: 600,
                          minWidth: 250,
                          maxHeight: 300,
                          minHeight: 125,
                        ),
                        height: constraints.maxWidth * 0.4,
                        width: constraints.maxWidth * 0.8,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                            child: Text("Save Signature"),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigo,
                            ).copyWith(
                              elevation: WidgetStateProperty.all(2),
                            ),
                            onPressed: () async {
                              ui.Image image = await _signaturePadKey.currentState!.toImage();
                              _saveAndUploadSignature(image);
                            },
                          ),
                        ),
                        SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                            child: Text("Clear Signature"),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigo,
                            ).copyWith(
                              elevation: WidgetStateProperty.all(2),
                            ),
                            onPressed: () async {
                              _signaturePadKey.currentState?.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future showAlertDialogOkConfirm(BuildContext context, Widget icon, String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        Size size = MediaQuery.of(context).size;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          actionsPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          contentTextStyle: TextStyle(fontSize: 14, letterSpacing: -1, color: Colors.black),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
            ],
          ),
          content:
          IntrinsicHeight(child: Container(alignment: Alignment.center, width: size.width * 0.5, child: Text(msg, textAlign: TextAlign.center))),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    child: const Text('확인', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
                    onPressed: () {
                      Navigator.pop(context, "OK");
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
