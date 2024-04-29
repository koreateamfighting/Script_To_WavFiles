//  Created by Jinwoo.Choi ,PD1 Team on 2024. 01. 25
//  Copyright © 2024 MediaZen Co. All rights reserved.

import 'dart:io';
import 'package:flutter/cupertino.dart';

List<String> voices = [];
String ver1_LanguageFullVerName = '';

List<String> selectVoices(String vocalizerEngineDir, String mainEngineVersion,
    String language, String selectedPlatform) {

  voices.clear();

  if (language == 'jpj' || language == 'idi') {
    mainEngineVersion = 'Ver3';
  }
  if (mainEngineVersion == 'Ver3') {
    if (language == "eng") {
      Directory dir = Directory(
          '${vocalizerEngineDir}/${mainEngineVersion}/languages/languages/${language}/speech/ve');
      List<FileSystemEntity> files = dir.listSync();

      Directory dir2 = Directory(
          '${vocalizerEngineDir}/${mainEngineVersion}/languages/languages/enu/speech/ve');

      files += dir2.listSync();

      getFileEntity(files, language, mainEngineVersion);
    } else {
      Directory dir = Directory(
          '${vocalizerEngineDir}/${mainEngineVersion}/languages/languages/${language}/speech/ve');
      List<FileSystemEntity> files = dir.listSync();
      getFileEntity(files, language, mainEngineVersion);
    }
  } else if (mainEngineVersion == 'Ver1') {
    ver1_LanguageFullVerName = selectEngineVersion(language, selectedPlatform);
    Directory dir = Directory(
        '${vocalizerEngineDir}/${mainEngineVersion}/languages/${ver1_LanguageFullVerName}/languages/${language}/speech/ve');
    List<FileSystemEntity> files = dir.listSync();
    getFileEntity(files, language, mainEngineVersion);
  }
  return voices;
}

Future<void> getFileEntity(
    List<FileSystemEntity> files, String language, String subEngineDir) async {
  //고쳐야 할 부분.
  String announcerName = '';
  if (subEngineDir == 'Ver3') {
    for (final FileSystemEntity file in files) {
      //announcerName = file.path.substring(0, file.path.indexOf('_22'));


      announcerName =
          file.path.substring(0, file.path.length - 27).substring(16);
      announcerName =
          announcerName.substring(announcerName.lastIndexOf('_') + 1);
      if (language == 'ged') {
        announcerName = 'petra-ml';
      }
      voices.add("${announcerName}");

      announcerName = '';
    }
  } else if (subEngineDir == 'Ver1') {
    for (final FileSystemEntity file in files) {
      //announcerName = file.path.substring(0, file.path.indexOf('_22'));
      announcerName =
          file.path.substring(0, file.path.length - 21).substring(16);
      if (language == 'ged') {
        announcerName = 'petra-ml';
      }
      announcerName =
          announcerName.substring(announcerName.lastIndexOf('_') + 1);
      voices.add("${announcerName}");
      announcerName = '';
    }
  }


}

String selectEngineVersion(String language, String selectedPlatform) {

  if (selectedPlatform == 'p6_ccic') {
    ver1_LanguageFullVerName = '';
  } else if (selectedPlatform == 'wide_p5' || selectedPlatform == 's5_S5w') {
    ver1_LanguageFullVerName = '1.3.1&1.5.1';
  } else if (selectedPlatform == 'mobis') {
    List<String> one_four_onelist = [
      'kok',
      'eng',
      'ged',
      'frf',
      'spe',
      'czc',
      'dad',
      'dun',
      'plp',
      'iti',
      'ptp',
      'rur',
      'sws',
      'trt',
      'sks',
      'non',
      'ena'
    ];
    if (one_four_onelist.contains(language) == true) {
      ver1_LanguageFullVerName = '1.4.1';
    } else if (language == 'jpj' || language == 'idi') {
      ver1_LanguageFullVerName = '';
    } else {
      ver1_LanguageFullVerName = '1.3.1&1.5.1';
    }
  } else {
    debugPrint("어떠한 플랫폼도 설정되지 않았습니다. 다시 확인해주세요.");
  }

  debugPrint("정해진 엔진 버전은 ${ver1_LanguageFullVerName}입니다.");
  return ver1_LanguageFullVerName;
}
