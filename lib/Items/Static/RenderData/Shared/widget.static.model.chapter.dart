import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:muonroi/Items/Static/RenderData/Shared/widget.static.stories.detail.dart';
import 'package:muonroi/Settings/settings.colors.dart';
import 'package:muonroi/Settings/settings.fonts.dart';
import 'package:muonroi/Settings/settings.language_code.vi..dart';
import 'package:muonroi/Settings/settings.main.dart';
import 'package:muonroi/blocs/Chapters/Detail_bloc/detail_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DetailChapter/widget.static.detail.chapter.bottom.dart';

class Chapter extends StatefulWidget {
  final int storyId;
  final String storyName;
  final int chapterId;
  final int lastChapterId;
  final int firstChapterId;
  final bool isLoadHistory;
  const Chapter(
      {super.key,
      required this.storyId,
      required this.storyName,
      required this.chapterId,
      required this.lastChapterId,
      required this.firstChapterId,
      required this.isLoadHistory});

  @override
  State<Chapter> createState() => _ChapterState();
}

class _ChapterState extends State<Chapter> {
  @override
  void initState() {
    _initSharedPreferences();
    _scrollPositionKey = "scrollPosition-${widget.storyId}";
    _detailChapterOfStoryBloc =
        DetailChapterOfStoryBloc(chapterId: widget.chapterId);
    _detailChapterOfStoryBloc
        .add(const DetailChapterOfStory(null, null, chapterId: 0));
    super.initState();
    isLoad = true;
    _scrollController = ScrollController();
    _refreshController = RefreshController(initialRefresh: false);
    _scrollController.addListener(_saveScrollPosition);
  }

  @override
  void dispose() {
    _detailChapterOfStoryBloc.close();
    _scrollController.removeListener(_saveScrollPosition);
    _scrollController.dispose();
    _refreshController.dispose();
    maxPosition = false;
    minPosition = false;
    isLoad = false;
    super.dispose();
  }
// #region Methods

  Future<void> _initSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void _saveScrollPosition() async {
    await _sharedPreferences.setDouble(
        _scrollPositionKey, _scrollController.offset);
    await _sharedPreferences.setInt("story-${widget.storyId}", widget.storyId);
    await _sharedPreferences.setInt(
        "story-${widget.storyId}-current-chapter-id", chapterIdOld);
    await _sharedPreferences.setInt(
        "story-${widget.storyId}-current-chapter", chapterNumber);
  }

  void _loadSavedScrollPosition() async {
    if (isLoad && widget.isLoadHistory) {
      SharedPreferences savedLocation = await SharedPreferences.getInstance();
      savedScrollPosition = savedLocation.getDouble(_scrollPositionKey) ?? 0.0;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(savedScrollPosition);
      }
    }
  }

  void _onRefresh(int chapterId) async {
    if (mounted && widget.firstChapterId != chapterId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _detailChapterOfStoryBloc.add(DetailChapterOfStory(
              false, widget.storyId,
              chapterId: chapterId));
        });
      });
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading(int chapterId, bool isCheckShow) async {
    if (!isCheckShow) {
      isLoading = true;
    }
    if (mounted && widget.lastChapterId != chapterId && isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _detailChapterOfStoryBloc.add(
              DetailChapterOfStory(true, widget.storyId, chapterId: chapterId));
          _scrollController.jumpTo(0.0);
          isLoading = false;
        });
      });
    } else if (!isLoading) {
      isLoading = true;
    }
    _refreshController.loadComplete();
  }

// #endregion

// #region Variables
  late bool maxPosition = false;
  late bool minPosition = false;
  late bool isLoad = false;
  var storyIdOld = 0;
  var chapterIdOld = 0;
  var chapterNumber = 0;
  var savedScrollPosition = 0.0;
  var isLoading = false;
  var isNextPage = false;
  var isPrePage = false;
  var isVisible = true;
  late SharedPreferences _sharedPreferences;
  late DetailChapterOfStoryBloc _detailChapterOfStoryBloc;
  late ScrollController _scrollController;
  late RefreshController _refreshController;
  late String _scrollPositionKey;
  // #endregion

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _detailChapterOfStoryBloc,
      child: BlocListener<DetailChapterOfStoryBloc, DetailChapterOfStoryState>(
          listener: (context, state) {
        const Center(
          child: CircularProgressIndicator(),
        );
      }, child:
              BlocBuilder<DetailChapterOfStoryBloc, DetailChapterOfStoryState>(
        builder: (context, state) {
          if (state is DetailChapterOfStoryLoadingState) {
            const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is DetailChapterOfStoryLoadedState) {
            _loadSavedScrollPosition();
            var chapterInfo = state.chapter.result;
            chapterIdOld = chapterInfo.id;
            chapterNumber = chapterInfo.numberOfChapter;
            return Scaffold(
              appBar: isVisible
                  ? AppBar(
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      backgroundColor: ColorDefaults.lightAppColor,
                      leading: IconButton(
                          splashRadius: 25,
                          color: ColorDefaults.thirdMainColor,
                          onPressed: () {
                            Navigator.maybePop(context, true);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_sharp,
                            color: ColorDefaults.thirdMainColor,
                          )),
                      title: GestureDetector(
                        onDoubleTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StoriesDetail(
                                        storyId: widget.storyId,
                                        storyTitle: widget.storyName,
                                      )));
                        },
                        child: Title(
                            color: ColorDefaults.thirdMainColor,
                            child: Text(
                              widget.storyName,
                              style: FontsDefault.h5,
                            )),
                      ),
                    )
                  : PreferredSize(preferredSize: Size.zero, child: Container()),
              backgroundColor: ColorDefaults.lightAppColor,
              body: GestureDetector(
                onTap: () {
                  setState(() {
                    isVisible = false;
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        overlays: []);
                  });
                },
                onDoubleTap: () {
                  setState(() {
                    isVisible = true;
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        overlays: SystemUiOverlay.values);
                  });
                },
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  header: ClassicHeader(
                    idleIcon: const Icon(Icons.arrow_upward),
                    idleText: L(ViCode.previousChapterTextInfo.toString()),
                    refreshingText: L(ViCode.loadingTextInfo.toString()),
                    releaseText: L(ViCode.loadingTextInfo.toString()),
                  ),
                  controller: _refreshController,
                  onRefresh: () => _onRefresh(chapterInfo.id),
                  onLoading: () => _onLoading(chapterInfo.id, true),
                  footer: ClassicFooter(
                    canLoadingIcon: const Icon(Icons.arrow_downward),
                    canLoadingText: L(ViCode.nextChapterTextInfo.toString()),
                  ),
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: _scrollController,
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: MainSetting.getPercentageOfDevice(
                                            context,
                                            expectWidth: 387)
                                        .width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width:
                                              MainSetting.getPercentageOfDevice(
                                                      context,
                                                      expectWidth: 96.75)
                                                  .width,
                                          child: Text(
                                            "${L(ViCode.chapterNumberTextInfo.toString())} ${chapterInfo.numberOfChapter}: ",
                                            style: FontsDefault.h5.copyWith(
                                                fontWeight: FontWeight.w600),
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              MainSetting.getPercentageOfDevice(
                                                      context,
                                                      expectWidth: 290.25)
                                                  .width,
                                          child: Text(
                                            chapterInfo.chapterTitle
                                                .replaceAll("\n", "")
                                                .trim(),
                                            style: FontsDefault.h5.copyWith(
                                                fontWeight: FontWeight.w600),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Html(
                                    data: chapterInfo.body
                                        .replaceAll("\n", "")
                                        .trim()),
                              ],
                            ));
                      }),
                ),
              ),
              bottomNavigationBar: isVisible
                  ? BottomChapterDetail(
                      chapterId: chapterInfo.id,
                      onRefresh: (int chapterId) => _onRefresh(chapterInfo.id),
                      onLoading: (int chapterId, bool isCheckShow) =>
                          _onLoading(chapterInfo.id, false))
                  : null,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      )),
    );
  }
}
