import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/tracing_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/tracing/tracing_widgets/tracing_word.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/custom_appbar.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';
import 'package:logger/logger.dart';

class TracingWrite extends StatefulWidget {
  final String code;
  final int openPage;

  const TracingWrite({
    super.key,
    required this.code,
    required this.openPage,
  });

  @override
  State<TracingWrite> createState() => _TracingWriteState();
}

class _TracingWriteState extends State<TracingWrite> {
  final tracingController = Get.put(TracingDataController());
  final ValueNotifier<bool> resetNotifier = ValueNotifier(false);

  int currentIndex = 0;
  late final int totalIndex;
  int completedPathCount = 0;

  String meaning = '';
  String phonetic = '';

  @override
  void initState() {
    super.initState();
    totalIndex = widget.openPage;
    music.playBackgroundMusic('tracing');
    _updateNote();
  }

  void _updateNote() {
    if (tracingController.tracingDataList != null &&
        tracingController.tracingDataList!.isNotEmpty) {
      final note = tracingController.tracingDataList![currentIndex].note;
      if (note.length > 1) {
        meaning = note.substring(0, note.length - 1); // 첫 번째 부분 (독)
        phonetic = note.substring(note.length - 1); // 마지막 글자 (음)
      } else {
        meaning = note;
        phonetic = '';
      }
      setState(() {});
    }
  }

  void _onNextWord() {
    if (currentIndex < totalIndex - 1 &&
        currentIndex < tracingController.tracingDataList!.length - 1) {
      setState(() {
        _onResetTracing();
        currentIndex++;
        _updateNote();
      });
    }
  }

  void _onPrevWord() {
    if (currentIndex > 0) {
      setState(() {
        _onResetTracing();
        currentIndex--;
        completedPathCount--;
        _updateNote();
      });
    }
  }

  void _completeWord() async {
    if (currentIndex < totalIndex - 1 &&
        currentIndex < tracingController.tracingDataList!.length - 1) {
      setState(() {
        effect.correctSound();
        _onResetTracing();
        currentIndex++;
        completedPathCount++;
        _updateNote();
      });
    } else {
      String result = await resultService(widget.code, currentIndex + 1);
      resultDialog(Get.context!, completedPathCount + 1, totalIndex, result);
    }
  }

  void _onResetTracing() {
    resetNotifier.value = !resetNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFD254),
      appBar: const CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(gapHalf),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Padding(
                padding: EdgeInsets.all(gapHalf),
                child: ClipRect(
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: TracingWord(
                      tracingController: tracingController,
                      currentIndex: currentIndex,
                      resetNotifier: resetNotifier,
                      onComplete: _completeWord,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    meaning, // 독 (의미) 표시
                    style: TextStyle(
                      color: mFontMain,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: gapQuarter),
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFE7610B),
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Padding(
                      padding: EdgeInsets.all(2.r),
                      child: Text(
                        phonetic, // 음 (발음) 표시
                        style: TextStyle(
                          color: mFontWhite,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(gapHalf),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _onPrevWord();
                      },
                      child: Icon(
                        Icons.skip_previous,
                        size: 50.r,
                        color: currentIndex > 0 ? mFontWhite : mFontSub,
                      ),
                    ),
                    GestureDetector(
                        onTap: _onResetTracing,
                        child:
                            Icon(Icons.refresh, size: 50.r, color: mFontWhite)),
                    GestureDetector(
                      onTap: () {
                        _onNextWord();
                        Logger().d(
                            'total = ${totalIndex - 1} current = $currentIndex');
                      },
                      child: Icon(
                        Icons.skip_next,
                        size: 50.r,
                        color: totalIndex - 1 > currentIndex
                            ? mFontWhite
                            : mFontSub,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    music.stopBackgroundMusic();
    super.dispose();
  }
}
