//  Created by Jinwoo.Choi ,PD1 Team on 2024. 01. 25
//  Copyright © 2024 MediaZen Co. All rights reserved.

import 'package:flutter/material.dart';
import 'package:script_to_wavfiles/screen/home_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  String vocalizerEngineDir = '경로를 선택해주세요.'; //프로그램을 끄지 않고 재사용을 할 때 엔진 디렉토리를 유지 시키기 위해 , 메인에서 변수 선언.
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(vocalizerEngineDir: vocalizerEngineDir,),
  ));

}

