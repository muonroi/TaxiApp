import 'package:flutter/material.dart';
import 'package:muonroi/Items/Static/RenderData/Shared/widget.static.stories.vertical.dart';
import 'package:muonroi/Settings/settings.colors.dart';
import 'package:muonroi/Settings/settings.fonts.dart';
import 'package:muonroi/Settings/settings.language_code.vi..dart';
import 'package:muonroi/Settings/settings.main.dart';

class EditorStories extends StatelessWidget {
  final bool isShowLabel;
  final bool isShowBack;
  const EditorStories(
      {super.key, required this.isShowLabel, required this.isShowBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              splashRadius:
                  MainSetting.getPercentageOfDevice(context, expectWidth: 25)
                      .width,
              color: ColorDefaults.thirdMainColor,
              highlightColor: const Color.fromARGB(255, 255, 175, 0),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: backButtonCommon()),
          backgroundColor: ColorDefaults.mainColor,
          title: Text(
            L(ViCode.editorChoiceTextInfo.toString()),
            style: FontsDefault.h5.copyWith(fontWeight: FontWeight.w600),
          )),
      body: StoriesVerticalData(
        isShowLabel: isShowLabel,
        isShowBack: isShowBack,
      ),
    );
  }
}
