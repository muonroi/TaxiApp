import 'package:flutter/material.dart';
import 'package:muonroi/shared/settings/enums/enum.search.story.dart';
import 'package:muonroi/shared/settings/settings.colors.dart';
import 'package:muonroi/core/localization/settings.language_code.vi..dart';
import 'package:muonroi/shared/settings/settings.main.dart';
import 'package:muonroi/features/stories/data/models/models.stories.story.dart';
import 'package:muonroi/features/stories/data/repositories/story_repository.dart';
import 'package:muonroi/features/stories/presentation/pages/widget.static.stories.detail.dart';

class SearchPage extends StatefulWidget {
  final TextEditingController searchController;
  const SearchPage({super.key, required this.searchController});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
  }

  bool isShowClearText = false;
  StoryRepository storyRepository = StoryRepository();
  List<StoryItems> storiesSearch = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            splashRadius: 25,
            color: ColorDefaults.thirdMainColor,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: backButtonCommon()),
        backgroundColor: ColorDefaults.lightAppColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: TextField(
          controller: widget.searchController,
          onChanged: (value) => {
            if (context.mounted)
              {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await _handleSearch(value);
                })
              }
          },
          maxLines: 1,
          minLines: 1,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8.0),
              hintMaxLines: 1,
              hintText: L(ViCode.searchTextInfo.toString()),
              suffixIcon: Visibility(
                visible: isShowClearText,
                child: IconButton(
                  icon: const Icon(
                    Icons.clear,
                  ),
                  onPressed: () {
                    setState(() {
                      isShowClearText = false;
                    });
                    widget.searchController.clear();
                  },
                ),
              ),
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
        ),
      ),
      body: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: storiesSearch.length,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StoriesDetail(
                                    storyId: storiesSearch[index].id,
                                    storyTitle: storiesSearch[index].storyTitle,
                                  )));
                    },
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MainSetting.getPercentageOfDevice(context,
                                  expectWidth: 40)
                              .width,
                          height: MainSetting.getPercentageOfDevice(context,
                                  expectHeight: 100)
                              .height,
                          child:
                              netWorkImage(storiesSearch[index].imgUrl, true),
                        ),
                      ),
                      title: Text(storiesSearch[index].storyTitle),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _handleSearch(String value) async {
    final isInputNotEmpty = value.isNotEmpty;
    List<StoryItems> searchedStories = [];

    if (isInputNotEmpty) {
      var resultData =
          await storyRepository.searchStory([value], [SearchType.title], 1, 15);
      searchedStories = resultData.result.items;
    }

    setState(() {
      isShowClearText = isInputNotEmpty;
      storiesSearch = searchedStories;
    });
  }
}
