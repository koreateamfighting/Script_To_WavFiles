//  Created by Jinwoo.Choi ,PD1 Team on 2024. 01. 25
//  Copyright © 2024 MediaZen Co. All rights reserved.


import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:process_run/shell.dart';
import 'result_screen.dart';
import 'package:script_to_wavfiles/model/WavFileModel.dart';
import 'package:script_to_wavfiles/model/LanguageModel.dart';
import 'package:intl/intl.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key,
    required this.vocalizerEngineDir,
  });

  final String vocalizerEngineDir; // ★ 보컬라이저 엔진 디렉토리 경로 변수 (이 프로그램에서 가장 핵심 변수)

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            IconTheme(
              data: IconThemeData(color: Colors.black),
              child: Icon(Icons.my_library_music_sharp),
            ),
            SizedBox(
              width: 15,
            ),
            Text('Script to WaveFiles')
          ],
        ),
        backgroundColor: Colors.blueAccent.withOpacity(0.6),
      ),
      body: Center(
        child: SettingView(vocalizerEngineDir: vocalizerEngineDir,),
      ),
    );
  }
}

class SettingView extends StatefulWidget {
  const SettingView({super.key,
    required this.vocalizerEngineDir,
  });

  final String vocalizerEngineDir; // ★ 보컬라이저 엔진 디렉토리 경로 변수 (이 프로그램에서 가장 핵심 변수, 새 클래스에서 재사용 하기 때문에 변수 재선언)

  _SettingView createState() => _SettingView();
}
enum Item { p6_ccic, wide_p5, mobis , s5_s5w } // ★ radiobutton으로 플랫폼 선택을 위한 enum data

class _SettingView extends State<SettingView> {
//========================================변수 선언부 시작 =======================================================================================
  Item? seletedItem = Item.p6_ccic; // 초기 설정은 p6_ccic로 한다.
  late String vocalizerEngineDir = widget.vocalizerEngineDir; // ★ 보컬라이저 엔진 디렉토리 경로 변수
  String mainEngineVersion = 'Ver3'; // ★ Ver1, Ver3 활용 초기값은 Ver3으로 셋팅.
  String guideString = "Vocalizer 엔진 경로를 불러오세요."; //★ 프로그램 상단의 안내 문구 (특정 분기마다 값은 변경 될 것임)
  String scriptFilePath = '파일을 선택해주세요.'; //★ 스크립트 파일 경로가 기재된 변수
  String activePromptDBPath = '파일을 선택해주세요.'; //★ ActivePrompt DB 파일 경로가 기재된 변수
  String ruleSetPath = '파일을 선택해주세요.'; //★ Ruleset 파일 경로가 기재된 변수
  String scriptResult = ''; //★ 불러온 스크립트를 프로그램에서 read, 최초 읽혀진 파일내용이 담겨 있다.
  Map<String, String> scriptList = {}; // ★ scriptResult 내용에 있는 인덱스와 문구들을 Map데이터로 가공한 자료형 ex({210 : 'A route including an EV charging ....'})
  List<String> voices = []; //★ 사용 가능한 voice들을 담는 리스트
  String language = ''; //★ 스크립트 파일에 기재된 language를 담는 변수
  String selectedVoice = ''; //★ 화면 내 dropdownValue에서 현재 선택한 Voice를 담는 변수
  String ver1_VoiceModel = ''; //★ Vocalizer ver1에서는 "full_vssq5f22","full_155mrf22" 둘 중 사용 가능한데 이들 중 하나를 지정해주는 변수
  String selectedPlatform = ''; //★ radiobutton(플랫폼 선택)에서 각 플랫폼 선택시 특정분기로 이동(버전 선택)을 돕기 위한 변수
  String ver1_LanguageFullVerName = ''; //★ Vocalizer 1버전에서는 "1.3.1&1.5.1" ,"1.4.1" 총 2개로 갈린다. 둘 중 하나를 지정 해주는 변수.
  //List<String> definitelyExistsDirectoryList = []; //★ Vocalizer 엔진 검증을 위한 engineValidCheck함수에서 특정 디렉토리 일치 여부를 판독하기 위한 변수 (지금은 테스트중이라 쓰이지 않음)

  String batchFileContent = ''; //★ 이 프로그램은 배치파일을 실행하는 원리인데, batch.bat 파일에 들어갈 내용을 담는 변수
  var shell = Shell(); //★ CMD에서 셸 스크립트를 실행하기 위한 특수 변수.
  bool _visibility = false; //★ 스크립트 파일 선택 노출/미노출 플래그
  bool _visibility2 = false; //★ Voice선택,apdb,rulse 파일 선택 노출/미노출 플래그
  bool _engineValidCheck = false; //★ Vocalizer 엔진 검증 합격(t)/불합격(f)
  bool _scriptValidCheck = false; //★ 스크립트 파일 검증 합격(t)/불합격(f)
  bool _apdbValidCheck = false; //★ apdb 파일 검증 합격(t)/불합격(f)
  bool _ruleSetValidCheck = false;//★ 룰셋 파일 검증 합격(t)/불합격(f)
  bool _isDisabled = false; //★ 엔진 디렉토리 browse 활성/비활성
  bool _isDisabled2 = false;//★ 스크립트 디렉토리 browse 활성/비활성
  bool _isDisabled3 = false;//★ apdb 파일 browse 활성/비활성
  bool _isDisabled4 = false;//★ apdb 파일 browse 활성/비활성
  int totalSize = 0; //★ engineValidCheck 함수에서 쓰이는 변수로써, 디렉토리내 모든 파일 총 용량을 담는 변수.
  int directoryNum = 0; //★ engineValidCheck 함수에서 쓰이는 변수로써, 메인 디렉토리 내 서브 디렉토리가 몇 개 인지를 알려주는 변수.
  List<WavFileModel> wavfilemodels = []; //★ 생성된 음원 파일의 인덱스번호, 문장, Wav파일경로를 리스트 형태로 보관하기 위한 변수.
  String mkdirTimeStamp = DateFormat("yyMMddHHmm").format(DateTime.now()); //★ 현재 시간 출력.
//========================================변수 선언부 끝 =======================================================================================

 //========================================변수 초기화 관련 함수 시작 =======================================================================================
  void initState() { //☆ 프로그램 최초 실행시 변수 초기화
    super.initState();
    print("프로그램 시작");
    guideString = "Vocalizer 엔진 경로를 선택하시고 ,해당하는 플랫폼도 선택해주세요.";
    seletedItem = Item.p6_ccic;
    //vocalizerEngineDir = '경로를 선택해주세요.';
    scriptFilePath = '파일을 선택해주세요.';
    scriptResult = '';
    scriptList = {};
    voices.clear();
    selectedVoice = '';
    batchFileContent = '';
    selectedPlatform = 'p6_ccic';
    ver1_LanguageFullVerName = '';
    //definitelyExistsDirectoryList.clear();
    shell = Shell();
    _visibility = false;
    _visibility2 = false;
    _isDisabled = false;
    _isDisabled2 = false;
    _isDisabled3 = false;
    _isDisabled4 = false;
    language = '';
    _engineValidCheck = false;
    _scriptValidCheck = false;
    _apdbValidCheck = false;
    _ruleSetValidCheck = false;
    totalSize = 0;
    directoryNum = 0;
    mkdirTimeStamp = DateFormat("yyMMddHHmm").format(DateTime.now());

    if (vocalizerEngineDir != '경로를 선택해주세요.') {
      _showScriptFile();
      setState(() {
        _isDisabled = true;
        guideString = "script file을 불러오세요.";
      });
    }
  }

  void restart() { //☆ 프로그램 초기화하거나 , 재시작시 변수들 최초 실행시 상황 처럼 초기화
    debugPrint("초기화 및 프로그램 재시작");
    setState(() {
      seletedItem = Item.p6_ccic;
      guideString = "Vocalizer 엔진 경로를 불러오세요.";
      vocalizerEngineDir = '경로를 선택해주세요.';
      scriptFilePath = '파일을 선택해주세요.';
      mainEngineVersion = 'Ver3';
      scriptResult = '';
      scriptList = {};
      selectedPlatform = 'p6_ccic';
      voices.clear();
      selectedVoice = '';
      batchFileContent = '';
      ver1_VoiceModel= '';
      ver1_LanguageFullVerName = '';
      //definitelyExistsDirectoryList.clear();
      shell = Shell();
      _visibility = false;
      _visibility2 = false;
      _isDisabled = false;
      _isDisabled2 = false;
      _isDisabled3 = false;
      _isDisabled4 = false;
      language = '';
      _engineValidCheck = false;
      _scriptValidCheck = false;
      _apdbValidCheck = false;
      _ruleSetValidCheck = false;
      totalSize = 0;
      directoryNum = 0;
      DateFormat("yyMMddHHmm").format(DateTime.now());
    });
  }
//========================================변수 초기화 관련 함수 끝 =======================================================================================

//========================================위젯 선언 시작 =======================================================================================
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: [
            Text(
              "${guideString}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Text("1.엔진 디렉토리 경로",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.blueGrey.shade100,
                  width: 700,
                  height: 30,
                  child: Text("${vocalizerEngineDir}"),
                ),
                TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          side: BorderSide(
                            color: _isDisabled ? Colors.grey : Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    onPressed: _isDisabled
                        ? null
                        : () async {
                      await _vocalizerEnginePath();
                      //await Future.delayed(Duration(seconds: 1));
                      setState(() {
                        vocalizerEngineDir = vocalizerEngineDir;
                      });
                      if (vocalizerEngineDir != "null") {
                        engineValidCheck(vocalizerEngineDir);
                        if (_engineValidCheck == true) {
                          //파일 검증 성공시
                          _showScriptFile();
                          tempFilesRemove();
                          setState(() {
                            _isDisabled = true;
                            guideString = "script file을 불러오세요.";
                          });
                        } else {
                          //파일 검증 실패시
                          ScaffoldMessenger.of(context).showSnackBar(
                              invalidEngineAlertMessageSnackBar());

                          setState(() {
                            restart();
                            _isDisabled = false;
                          });
                        }
                      }
                    },
                    child: Text(
                      "Browse",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isDisabled ? Colors.grey : Colors.blueAccent),
                    )),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Text("2.플랫폼 선택",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(child:
                RadioListTile<Item>(
                  value: Item.p6_ccic,
                  groupValue: seletedItem,
                  onChanged: (Item? value) {
                    mainEngineVersion = 'Ver3';
                    setState(() {
                      seletedItem = value;
                      selectedPlatform = 'p6_ccic';
                      debugPrint("선택한 플랫폼은 ${selectedPlatform}");

                    });
                  },
                  title: const Text('고6/CCIC',),

                ),
                ),

                Expanded(child:
                RadioListTile<Item>(
                  value: Item.wide_p5,
                  groupValue: seletedItem,
                  onChanged: (Item? value) {
                    mainEngineVersion = 'Ver1';
                    setState(() {
                      seletedItem = value;
                      selectedPlatform = 'wide_p5';
                      debugPrint("선택한 플랫폼은 ${selectedPlatform}");
                    });
                  },
                  title: const Text('WIDE/고5'),

                ),
                ),
                Expanded(
                  child: RadioListTile<Item>(
                    value: Item.mobis,
                    groupValue: seletedItem,
                    onChanged: (Item? value) {
                      mainEngineVersion = 'Ver1';
                      setState(() {
                        seletedItem = value;
                        selectedPlatform = 'mobis';
                        debugPrint("선택한 플랫폼은 ${selectedPlatform}");
                      });
                    },
                    title: const Text('MOBIS'),

                  ),
                ),

                Expanded(child: RadioListTile<Item>(
                  value: Item.s5_s5w,
                  groupValue: seletedItem,
                  onChanged: (Item? value) {
                    mainEngineVersion = 'Ver1';
                    setState(() {
                      seletedItem = value;
                      selectedPlatform = 's5_s5w';
                      debugPrint("선택한 플랫폼은 ${selectedPlatform}");


                    });
                  },
                  title: const Text('표5/표5w'),

                ),),

              ],
            ),



            SizedBox(
              height: 30,
            ),
            Visibility(
              visible: _visibility,
              child: Text("3.Script 파일 선택",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            Visibility(
              visible: _visibility,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.blueGrey.shade100,
                    width: 700,
                    height: 30,
                    child: Text("${scriptFilePath}"),
                  ),
                  TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            side: BorderSide(
                              color: _isDisabled2 ? Colors.grey : Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: _isDisabled2
                          ? null
                          : () async {
                        await _scriptFilePathPick();
                        await Future.delayed(Duration(seconds: 1));
                        setState(() {
                          tempFilesRemove();
                          scriptFilePath = scriptFilePath;
                          readFileAsync(scriptFilePath);
                        });
                        await Future.delayed(Duration(seconds: 1));

                        if (scriptFilePath != "null") {
                          scriptValidCheck(scriptResult);

                          if (_scriptValidCheck == true) {
                            makeScriptList(scriptResult);
                            _showETC();
                            guideString =
                            "voice 선택 및 active prompt db, ruleset을 셋팅하세요.";
                            _isDisabled2 = true;
                            voices =
                                selectVoices(vocalizerEngineDir,mainEngineVersion, language,selectedPlatform);
                            selectedVoice = voices[0];
                          } else {
                            removeScriptFilePath();
                            ScaffoldMessenger.of(context).showSnackBar(
                                invalidScriptAlertMessageSnackBar());
                            setState(() {
                              scriptFilePath = '';
                              _isDisabled2 = false;
                            });
                          }
                        }
                        //print(scriptList);
                      },
                      child: Text(
                        "Browse",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isDisabled2 ? Colors.grey : Colors
                                .blueAccent),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),

            Visibility(
              visible: _visibility2,
              child: Text("4.Voice Announcer 선택",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            Visibility(
              visible: _visibility2,
              child: Center(
                child: Container(
                    color: Colors.blueGrey.shade100,
                    width: 200,
                    height: 30,
                    child: (_apdbValidCheck == true ||
                        _ruleSetValidCheck == true)
                        ? Text("${selectedVoice}",)
                        : DropdownButton(
                      isExpanded: true,
                      icon: Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                        ),
                      ),
                      dropdownColor: Colors.blueGrey.shade100,
                      value: selectedVoice,
                      items: voices
                          .map((e) =>
                          DropdownMenuItem(
                            child: Row(
                              children: [
                                Text(
                                  "${e}(${language})",
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            value: e,
                          ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedVoice = value!;
                        });
                      },
                    )),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Visibility(
              visible: _visibility2,
              child: Text("5.Active Prompt DB 선택 (선택사항)",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            Visibility(
              visible: _visibility2,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.blueGrey.shade100,
                      width: 700,
                      height: 30,
                      child: Text("${activePromptDBPath}"),
                    ),
                    TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              side: BorderSide(
                                color: _isDisabled3 ? Colors.grey : Colors.blue,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: _isDisabled3
                            ? null
                            : () async {
                          await _activePromptDBPathPick();
                          await Future.delayed(Duration(seconds: 1));
                          setState(() {
                            activePromptDBPath = activePromptDBPath;
                          });
                          await Future.delayed(Duration(seconds: 1));

                          if (activePromptDBPath != "null" &&
                              activePromptDBPath != '파일을 선택해주세요.') {
                            apdbValidCheck(activePromptDBPath);

                            if (_apdbValidCheck == true) {
                              _isDisabled3 = true;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  invalidActivePromptDBAlertMessageSnackBar());
                              setState(() {
                                activePromptDBPath = '파일을 선택해주세요.';
                                _isDisabled3 = false;
                              });
                            }
                          }
                          //print(scriptList);
                        },
                        child: Text(
                          "Browse",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                              _isDisabled3 ? Colors.grey : Colors.blueAccent),
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Visibility(
              visible: _visibility2,
              child: Text("6.Ruleset 선택 (선택사항)",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            Visibility(
              visible: _visibility2,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.blueGrey.shade100,
                      width: 700,
                      height: 30,
                      child: Text("${ruleSetPath}"),
                    ),
                    TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              side: BorderSide(
                                color: _isDisabled4 ? Colors.grey : Colors.blue,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: _isDisabled4
                            ? null
                            : () async {
                          await _ruleSetPathPick();
                          await Future.delayed(Duration(seconds: 1));
                          setState(() {
                            ruleSetPath = ruleSetPath;
                          });
                          await Future.delayed(Duration(seconds: 1));

                          if (ruleSetPath != "null" &&
                              ruleSetPath != '파일을 선택해주세요.') {
                            ruleSetValidCheck(ruleSetPath);

                            if (_ruleSetValidCheck == true) {
                              _isDisabled4 = true;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  invalidRuleSetAlertMessageSnackBar());
                              setState(() {
                                ruleSetPath = '파일을 선택해주세요.';
                                _isDisabled4 = false;
                              });
                            }
                          }
                          //print(scriptList);
                        },
                        child: Text(
                          "Browse",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                              _isDisabled4 ? Colors.grey : Colors.blueAccent),
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Visibility(
                visible: _visibility2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: () {
                        restart();
                        _isDisabled = false;
                        _isDisabled2 = false;
                        setState(() {
                          guideString = "Vocalizer 엔진 경로를 불러오세요.";
                        });
                      },
                      child: Text("초기화",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent)),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: () {
                        // print(vocalizerEngineDir);
                        // print(scriptFilePath);
                        // print(_selectedLanguage);
                        // print(selectedVoice);
                        //print(scriptList);
                        Future.delayed(Duration(seconds: 10));
                        if(mainEngineVersion == 'Ver3') {
                          makeBatchFileVer3();
                        }
                        else if(mainEngineVersion == 'Ver1'){
                          makeBatchFileVer1();
                        }

                        Future.delayed(Duration(seconds: 5));
                        if(mainEngineVersion == 'Ver3') {
                          executeBatchFileVer3();
                        }
                        else if(mainEngineVersion == 'Ver1'){
                          executeBatchFileVer1();
                        }
                        Future.delayed(Duration(seconds: 10));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ResultScreen(
                                    vocalizerEngineDir: vocalizerEngineDir,
                                    wavfilemodels: wavfilemodels,
                                  )),
                        );
                      },
                      child: Text("확인",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent)),
                    ),
                  ],
                )),
          ],
        ));
  }
//========================================위젯 선언 끝 =======================================================================================

//========================================함수 선언부 시작 =======================================================================================
  Future<String> _vocalizerEnginePath() async {
    final path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Vocalizer 엔진 메인 디렉토리를 선택하세요 (ve_engine_MZver)");
    vocalizerEngineDir = await path.toString();

    debugPrint("선택한 엔진디렉토리 경로는 ${vocalizerEngineDir}입니다.");

    return vocalizerEngineDir;
  }

  Future<String> _scriptFilePathPick() async {
    final path2 = await FilePicker.platform.pickFiles(
        allowedExtensions: ['txt'],
        dialogTitle: "스크립트 파일(txt)을 선택하세요."
    );
    if (path2 != null) {
      PlatformFile file = path2.files.first;

      scriptFilePath = await file.path.toString();
    } else {
      scriptFilePath = await 'null';
    }

    //print(scriptFilePath);

    return scriptFilePath;
  }

  Future<String> _activePromptDBPathPick() async {
    final path3 = await FilePicker.platform.pickFiles(
        allowedExtensions: ['dat'],
        dialogTitle: ".dat 확장자인 activityPromptFile을 선택하세요."
    );
    if (path3 != null) {
      PlatformFile file = path3.files.first;

      activePromptDBPath = await file.path.toString();
    } else {
      activePromptDBPath = await 'null';
    }

    return activePromptDBPath;
  }

  Future<String> _ruleSetPathPick() async {
    final path4 = await FilePicker.platform.pickFiles(
        allowedExtensions: ['rst'],
        dialogTitle: ".rst 확장자인 ruleSet 파일을 선택하세요."
    );
    if (path4 != null) {
      PlatformFile file = path4.files.first;

      ruleSetPath = await file.path.toString();
    } else {
      ruleSetPath = await 'null';
    }

    return ruleSetPath;
  }

  void readFileAsync(String scriptFilePath) {
    File file = new File(scriptFilePath);
    Future<String> futureContent = file.readAsString();
    futureContent.then((c) => scriptResult = c);

  }

  void makeScriptList(String scriptResult) {
    scriptResult = scriptResult.replaceAll(
        "\r", ""); //UTF-8 BOM에는 \r 이라는게 들어가있음. 형식을 맞추기 위해 제거해야함.
    language = scriptResult.substring(88, 91);
    print("이 스크립트의 언어는 : ${language}입니다.");
    scriptResult = scriptResult.substring(98);

    List<String> tempList = [];
    tempList = scriptResult.split("\n");

    for (int i = 0; i < tempList.length; i++) {
      tempList.remove("");
    }
    //print("=========================스크립트 일부 내용 확인===========================");
    //print(tempList[0]);
    //print(tempList[1]);
    //print(tempList[2]);
    //print(tempList[3]);
    //print(tempList[4]);
    //print(tempList[5]);
    //print("========================================================================");
    for (int i = 0; i < tempList.length; i++) {
      if (i % 2 != 0) {
        scriptList.addAll(
            ({'${tempList[i - 1].replaceAll(';', '')}': '${tempList[i]}'}));
        makeScriptPieceFiles(
            tempList[i - 1].replaceAll(';', '').toString(), tempList[i]);
      }
    }

    //print(scriptList.values.toList());
  }

  Future<void> makeScriptPieceFiles(String index, String content) async {
    if (language == 'jpj' || language == 'idi'){
      mainEngineVersion = 'Ver3';
    }
    File Path = File("${vocalizerEngineDir}/${mainEngineVersion}/temp/${index}.txt");
    File scriptTextFile = await Path;
    scriptTextFile.writeAsString('${content}');
  }

  Future<void> makeBatchFileVer1() async {

    final Path = File("${vocalizerEngineDir}/${mainEngineVersion}/batch.bat");
    final batchFile = await Path;
    ver1_LanguageFullVerName = selectEngineVersion(language,selectedPlatform);

    if(ver1_LanguageFullVerName == '1.4.1'){
      ver1_VoiceModel = "full_vssq5f22";
    }
    else if(ver1_LanguageFullVerName == '1.3.1&1.5.1'){
      ver1_VoiceModel = "full_155mrf22";
    }

    for (int i = 0; i < scriptList.length; i++) {
      //print(scriptList.values.toList()[i]);

      if (_apdbValidCheck == true && _ruleSetValidCheck == true) {
        batchFileContent +=
        '@echo\n sample_text_nav_read_file.exe -I ./ -v ${selectedVoice} -i temp/${scriptList
            .keys
            .toList()[i]}.txt -o temp/${scriptList
            .keys
            .toList()[i]}.pcm -T 2 -m ${ver1_VoiceModel} -x "application/x-vocalizer-activeprompt-db ${activePromptDBPath}" -x "application/x-vocalizer-rettt+text ${ruleSetPath} && python PcmToWav.py temp/${scriptList
            .keys
            .toList()[i]}.pcm output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList.keys.toList()[i]}.wav" \n\n';
      } else if (_apdbValidCheck == true && _ruleSetValidCheck == false) {
        batchFileContent +=
        '@echo\n sample_text_nav_read_file.exe -I ./ -v ${selectedVoice} -i temp/${scriptList
            .keys
            .toList()[i]}.txt -o temp/${scriptList
            .keys
            .toList()[i]}.pcm -T 2 -m ${ver1_VoiceModel} -x "application/x-vocalizer-activeprompt-db ${activePromptDBPath} && python PcmToWav.py temp/${scriptList
            .keys
            .toList()[i]}.pcm output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList.keys.toList()[i]}.wav"\n\n';
      } else if (_apdbValidCheck == false && _ruleSetValidCheck == true) {
        batchFileContent +=
        '@echo\n sample_text_nav_read_file.exe -I ./ -v ${selectedVoice} -i temp/${scriptList
            .keys
            .toList()[i]}.txt -o temp/${scriptList
            .keys
            .toList()[i]}.pcm -T 2 -m ${ver1_VoiceModel} -x "application/x-vocalizer-rettt+text ${ruleSetPath} && python PcmToWav.py temp/${scriptList
            .keys
            .toList()[i]}.pcm output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList.keys.toList()[i]}.wav"\n\n';
      } else {
        batchFileContent +=
        '@echo\n sample_text_nav_read_file.exe -I ./ -v ${selectedVoice} -i temp/${scriptList
            .keys
            .toList()[i]}.txt -o temp/${scriptList
            .keys.toList()[i]}.pcm -T 2 -m ${ver1_VoiceModel} && python PcmToWav.py temp/${scriptList
            .keys
            .toList()[i]}.pcm output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList.keys.toList()[i]}.wav\n\n';
      }



      wavfilemodels.add(WavFileModel(
          "${scriptList.keys.toList()[i]}",
          "${scriptList.values.toList()[i]}",
          "${vocalizerEngineDir}/${mainEngineVersion}/output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList
              .keys.toList()[i]}.wav"));
    }

    batchFile.writeAsString('$batchFileContent');
  }

  Future<void> makeBatchFileVer3() async {
    final Path = File("${vocalizerEngineDir}/${mainEngineVersion}/batch.bat");
    final batchFile = await Path;


    for (int i = 0; i < scriptList.length; i++) {
      //print(scriptList.values.toList()[i]);

      if (_apdbValidCheck == true && _ruleSetValidCheck == true) {
        batchFileContent +=
        '@echo\n text_nav_read_file.exe -I languages -v ${selectedVoice} -i temp/${scriptList
            .keys
            .toList()[i]}.txt -o output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList
            .keys
            .toList()[i]}.wav -w -T 2 -x "application/x-vocalizer-activeprompt-db ${activePromptDBPath}" -x "application/x-vocalizer-rettt+text ${ruleSetPath}"\n\n';
      } else if (_apdbValidCheck == true && _ruleSetValidCheck == false) {
        batchFileContent +=
        '@echo\n text_nav_read_file.exe -I languages -v ${selectedVoice} -i temp/${scriptList
            .keys
            .toList()[i]}.txt -o output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList
            .keys
            .toList()[i]}.wav -w -T 2 -x "application/x-vocalizer-activeprompt-db ${activePromptDBPath}"\n\n';
      } else if (_apdbValidCheck == false && _ruleSetValidCheck == true) {
        batchFileContent +=
        '@echo\n text_nav_read_file.exe -I languages -v ${selectedVoice} -i temp/${scriptList
            .keys
            .toList()[i]}.txt -o output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList
            .keys
            .toList()[i]}.wav -w -T 2 -x "application/x-vocalizer-rettt+text ${ruleSetPath}"\n\n';
      } else {
        batchFileContent +=
        '@echo\n text_nav_read_file.exe -I languages -v ${selectedVoice} -i temp/${scriptList
            .keys
            .toList()[i]}.txt -o output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList
            .keys.toList()[i]}.wav -w -T 2\n\n';
      }

      wavfilemodels.add(WavFileModel(
          "${scriptList.keys.toList()[i]}",
          "${scriptList.values.toList()[i]}",
          "${vocalizerEngineDir}/${mainEngineVersion}/output/${selectedPlatform}_${language}_${mkdirTimeStamp}/${scriptList
              .keys.toList()[i]}.wav"));
    }

    batchFile.writeAsString('$batchFileContent');
  }

  void tempFilesRemove() {
    setState(() {
      shell.run('''
      pushd ${vocalizerEngineDir}\\${mainEngineVersion} && rm -rf temp && mkdir temp && exit
      ''');
    });
  }

  Future<void> executeBatchFileVer1() async{
    setState(() {
      for (int i = 0; i < scriptList.length; i++) {
        // pcm to wave 수행
      }
      shell.run('''
        pushd ${vocalizerEngineDir}\\${mainEngineVersion} && cd output && mkdir ${selectedPlatform}_${language}_${mkdirTimeStamp} && cd .. && batch.bat && exit
        ''');
      // shell.run('''
      // cd ${vocalizerEngineDir} && batch.bat
      // ''');
    });
  }

  void executeBatchFileVer3() {
    setState(() {
      shell.run('''
        pushd ${vocalizerEngineDir}\\${mainEngineVersion} && cd output && mkdir ${selectedPlatform}_${language}_${mkdirTimeStamp} && cd .. && batch.bat && exit
        ''');

      // shell.run('''
      // cd ${vocalizerEngineDir} && batch.bat
      // ''');
    });
  }

  void _showScriptFile() async {
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _visibility = true;
      });
    });
  }

  void _showETC() async {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _visibility2 = true;
      });
    });
  }

  void removeScriptFilePath() {
    setState(() {
      scriptFilePath = '파일을 선택해주세요.';
      scriptResult = '';
      scriptList = {};
    });
  }

  bool engineValidCheck(String vocalizerEngineDir) {
    //이름이 ve_engine_MZver이고 디렉토리 수 2 이상, 그리고 엔진 사이즈 6gb 이상으로만 판단 (추가 세부 조건 개발 예정)
    var dir = Directory(vocalizerEngineDir);
    List<String> tempList = [];
    tempList = vocalizerEngineDir.split("\\");
    //definitelyExistsDirectoryList = ["Directory: '${vocalizerEngineDir}\\Ver3'","Directory: '${vocalizerEngineDir}\\Ver1'"];
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: false, followLinks: false)
            .forEach((FileSystemEntity entity) {
          if (entity is Directory) {
            directoryNum++;
          }
        }
        );
      }
    } catch (e) {
      print(e.toString());
    }
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: true, followLinks: false)
            .forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
            (entity.toString());
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }

    print("프로그램 총 용량은 : ${totalSize}");


    if (tempList.contains("ve_engine_MZver") && totalSize > 6000000000 && directoryNum >= 2 )  { //이곳에 조건2,3도 추가
      setState(() {
        _engineValidCheck = true;
      });
    } else {
      setState(() {
        _engineValidCheck = false;
      });
    }

    return _engineValidCheck;
  }

  bool scriptValidCheck(String scriptResult) {
    if (scriptResult.contains("[HEADER]") &&
        scriptResult.contains("PromptSculptor") &&
        scriptResult.contains("ScriptEncoding") &&
        scriptResult.contains("Language") ||
        scriptResult.contains("[TTS]")) {
      setState(() {
        _scriptValidCheck = true;
      });
    } else {
      setState(() {
        _scriptValidCheck = false;
      });
    }

    return _scriptValidCheck;
  }

  bool apdbValidCheck(String activePromptDBPath) {
    if (activePromptDBPath.contains('apdb_tp_${selectedVoice}') &&
        activePromptDBPath.contains('.dat')) {
      setState(() {
        _apdbValidCheck = true;
      });
    } else {
      setState(() {
        _apdbValidCheck = false;
      });
    }
    return _apdbValidCheck;
  }

  bool ruleSetValidCheck(String ruleSetPath) {
    if (ruleSetPath.contains('${language}') && ruleSetPath.contains('.rst')) {
      setState(() {
        _ruleSetValidCheck = true;
      });
    } else {
      setState(() {
        _ruleSetValidCheck = false;
      });
    }
    return _ruleSetValidCheck;
  }
//========================================함수 선언부 종료 =======================================================================================

//========================================Alert 선언 시작 =======================================================================================
  SnackBar invalidEngineAlertMessageSnackBar() {
    return SnackBar(
      duration: Duration(seconds: 2),
      content: Text("올바른 엔진 디렉토리가 아닙니다. 디렉토리가 정상적인지 확인해주세요."),
      action: SnackBarAction(
        onPressed: () {},
        label: "Done",
        textColor: Colors.blue,
      ),
    );
  }

  SnackBar invalidScriptAlertMessageSnackBar() {
    return SnackBar(
      duration: Duration(seconds: 2),
      content: Text("올바른 스크립트 파일이 아닙니다."),
      action: SnackBarAction(
        onPressed: () {},
        label: "Done",
        textColor: Colors.blue,
      ),
    );
  }

  SnackBar invalidActivePromptDBAlertMessageSnackBar() {
    return SnackBar(
      duration: Duration(seconds: 2),
      content: Text(
          "선택하신 Voice와 ActivePrompt DB의 Voice와 일치하지 않습니다. \n 다시 확인 해주세요. "),
      action: SnackBarAction(
        onPressed: () {},
        label: "Done",
        textColor: Colors.blue,
      ),
    );
  }

  SnackBar invalidRuleSetAlertMessageSnackBar() {
    return SnackBar(
      duration: Duration(seconds: 2),
      content: Text("적절한 Ruleset 파일이 아닙니다. \n 다시 확인 해주세요. "),
      action: SnackBarAction(
        onPressed: () {},
        label: "Done",
        textColor: Colors.blue,
      ),
    );
  }
//========================================Alert 선언 종료 =======================================================================================
}
