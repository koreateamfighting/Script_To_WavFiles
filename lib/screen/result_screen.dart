//  Created by Jinwoo.Choi ,PD1 Team on 2024. 01. 25
//  Copyright © 2024 MediaZen Co. All rights reserved.

import "package:flutter/material.dart";
import "package:script_to_wavfiles/model/WavFileModel.dart";
import 'package:audioplayers/audioplayers.dart';
import "package:script_to_wavfiles/screen/home_screen.dart";
import 'dart:io';

class ResultScreen extends StatefulWidget { //HomeScreen으로부터 전달받은 엔진경로, wavfile 모델을 가져다 쓸 것이다.
  const ResultScreen(
      {super.key,
      required this.vocalizerEngineDir,
      required this.wavfilemodels});

  final String vocalizerEngineDir;
  final List<WavFileModel> wavfilemodels;

  State<ResultScreen> createState() => _ResultScreen();
}

class _ResultScreen extends State<ResultScreen> {
  AudioPlayer player = AudioPlayer(); //오디오 재생을 위한 라이브러리.
  late List<WavFileModel> wavfilemodels = widget.wavfilemodels;
  late String vocalizerEngineDir = widget.vocalizerEngineDir;
  List<ListTile> ResultList = [];  //리스트 타일로 출력하기 위한 리스트
  bool loadingScreen = true; // 로딩상태 플래그 on/off

  void initState() {
    super.initState();
    loadingStateFinish();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Row(
          children: [
            IconButton(
                onPressed: () {
                  AlertDialog alert = AlertDialog(
                    content: Text("화면 내 정보들이 사라집니다.\n 첫 화면으로 이동하시겠습니까?"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => HomeScreen(
                                      vocalizerEngineDir: vocalizerEngineDir,
                                    )));
                          },
                          child: Text("예",
                              style: TextStyle(
                                color: Colors.blueAccent,
                              ))),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("아니오",
                              style: TextStyle(
                                color: Colors.blueAccent,
                              ))),
                    ],
                  );
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                },
                icon: const Icon(Icons.arrow_back)),
            SizedBox(
              width: 20,
            ),
            Icon(Icons.my_library_music),
            Text(
              "  Wav 파일 변환 결과  ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Icon(Icons.my_library_music),
            SizedBox(
              width: 20,
            ),
            Text("\n※ 생성된 wav 파일은 ${vocalizerEngineDir}\\output에 저장됩니다. \n",
                //수정 요망.
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        Container(
          child: loadingScreen
              ? Column(
                  children: [
                    SizedBox(
                      height: 200,
                    ),
                    Center(
                        child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: const [
                          CircularProgressIndicator(
                            strokeWidth: 10,
                            backgroundColor: Colors.black,
                            color: Colors.blueAccent,
                          ),
                          Center(
                            child: Text(
                              "wav파일들을\n 생성중입니다.",
                              style: TextStyle(fontSize: 20),
                            ),
                          )
                        ],
                      ),
                    ))
                  ],
                )
              : Expanded(
                  child: ListView(
                  children: showList(),
                )),
        )
      ],
    ));
  }

  List<ListTile> showList() {
    for (var wavfile in wavfilemodels) {
      ResultList.add(ListTile(
          title: Text(wavfile.index),
          subtitle: Text(wavfile.content),
          trailing: Wrap(
            spacing: 12,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 10),
                ),
                child: const Text('Play'),
                onPressed: () async {
                  player.play(DeviceFileSource(wavfile.wavfile));
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 10),
                ),
                child: const Text('Stop'),
                onPressed: () async {
                  player.stop();
                },
              ),
            ],
          )));
    }

    return ResultList;
  }

  Future<void> loadingStateFinish() async { //☆ 로딩 상황에서 다운로드가 잘 진행중인지 판단하여 , 성공시 loading 상태를 해제 해주고, 실패 시에는 오류 출력
    while (true) {
      await Future.delayed(Duration(seconds: 30));
      if (!File(wavfilemodels.first.wavfile).existsSync()) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(DownloadFailAlertMessageSnackBar());

        });
        break;
      }
      if (File(wavfilemodels.last.wavfile).existsSync()) {

        setState(() {
          loadingScreen = false;
          ScaffoldMessenger.of(context).showSnackBar(DownloadCompleteAlertMessageSnackBar());
        });
        print("다운 로드 완료!");
        break;

      }
      await Future.delayed(Duration(seconds: 3));

    }



  }

  SnackBar DownloadCompleteAlertMessageSnackBar() {
    return SnackBar(
      duration: Duration(seconds: 2),
      content: Text("다운로드 완료."),
      action: SnackBarAction(
        onPressed: () {},
        label: "Done",
        textColor: Colors.blue,
      ),
    );
  }

  SnackBar DownloadFailAlertMessageSnackBar() {
    return SnackBar(
      duration: Duration(seconds:120),
      content: Text("다운로드에 실패하였습니다. 엔진 버전이 정상인지 혹은 디렉토리 구성에 문제가 있는지 확인해주십시오."),
      action: SnackBarAction(
        onPressed: () {},
        label: "Done",
        textColor: Colors.blue,
      ),
    );
  }
}
