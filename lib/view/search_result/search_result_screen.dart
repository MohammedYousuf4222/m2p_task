  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:itunes_media_app/res/AppContextExtension.dart';
  import 'package:itunes_media_app/view/shared/text_view.dart';
  import 'package:itunes_media_app/view_model/media_selection_view_model.dart';
  import 'package:itunes_media_app/view_model/search_view_model.dart';
  import 'widget/grid_view_result.dart';
  import 'widget/list_view_result.dart';

  class SearchResultScreen extends ConsumerStatefulWidget {
    static const String id = "search_result_screen";
    const SearchResultScreen({super.key});

    @override
    ConsumerState<SearchResultScreen> createState() => _HomeScreenState();
  }

class _HomeScreenState extends ConsumerState<SearchResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _controller = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaViewModelNotifier = ref.read(mediaViewModelProvider.notifier);
    Map<String, List<String>> mediaKindMap = mediaViewModelNotifier.mediaKindMap;
    final filteredMediaType = ref.watch(mediaViewModelProvider);
    final resources = context.resources;

    return Scaffold(
      backgroundColor: resources.color.primaryColor,
      appBar: AppBar(
        backgroundColor: resources.color.primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.resources.color.secondaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const MyTextView(label: 'iTunes'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.transparent,
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          tabs: [
            Tab(
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? context.resources.color.tabBarColor
                      : context.resources.color.transparentColor,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                alignment: Alignment.center,
                child: MyTextView(
                  label: "Grid Layout",
                  fontSize: context.resources.dimension.smallText,
                ),
              ),
            ),
            Tab(
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? context.resources.color.tabBarColor
                      : context.resources.color.transparentColor,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                alignment: Alignment.center,
                child: MyTextView(
                  label: "List Layout",
                  fontSize: context.resources.dimension.smallText,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, watch, child) {
                final state = ref.watch(searchViewModelProvider);

                return state.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.mediaList.when(
                        data: (mediaList) {
                          return TabBarView(
                            controller: _tabController,
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (mediaKindMap.isEmpty)
                                      const Center(child: MyTextView(label:'No categories available'))
                                    else
                                      ...mediaKindMap.entries.map((entry) {
                                        final key = entry.key;
                                        final value = entry.value;
                                        final filteredMedia = mediaList
                                            .where((media) =>
                                                value.contains(media.kind))
                                            .toList();

                                        return filteredMedia.isNotEmpty && filteredMediaType.contains(key)
                                            ? GridViewResultWidget(
                                                mediaList: filteredMedia,
                                                mediaType: key,
                                              )
                                            : const SizedBox.shrink(); // Use SizedBox.shrink() for empty space
                                      }),

                                    // Process the "Other" category
                                    if (mediaList.any((media) => !mediaKindMap
                                        .values
                                        .expand((e) => e)
                                        .contains(media.kind)))
                                      GridViewResultWidget(
                                        mediaList: mediaList
                                            .where((media) => !mediaKindMap.values
                                                .expand((e) => e)
                                                .contains(media.kind))
                                            .toList(),
                                        mediaType: 'Other',
                                      ),

                                    // If no media is present, show a no data message
                                    if (!mediaList.any((media) => mediaKindMap.values
                                        .expand((e) => e)
                                        .contains(media.kind)) &&
                                        !mediaList.any((media) => !mediaKindMap.values
                                            .expand((e) => e)
                                            .contains(media.kind)))
                                      const Center(child: MyTextView(label: 'No data available')),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (mediaKindMap.isEmpty)
                                      const Center(child: MyTextView(label:'No categories available'))
                                    else
                                      ...mediaKindMap.entries.map((entry) {
                                        final key = entry.key;
                                        final value = entry.value;
                                        final filteredMedia = mediaList
                                            .where((media) =>
                                                value.contains(media.kind))
                                            .toList();

                                        return filteredMedia.isNotEmpty && filteredMediaType.contains(key)
                                            ? ListViewResultWidget(
                                                mediaList: filteredMedia,
                                                mediaType: key,
                                              )
                                            : Container();
                                      }),

                                    // Process the "Other" category
                                    if (mediaList.any((media) => !mediaKindMap
                                        .values
                                        .expand((e) => e)
                                        .contains(media.kind)))
                                      ListViewResultWidget(
                                        mediaList: mediaList
                                            .where((media) => !mediaKindMap.values
                                                .expand((e) => e)
                                                .contains(media.kind))
                                            .toList(),
                                        mediaType: 'Other',
                                      ),

                                    // If no media is present, show a no data message
                                    if (!mediaList.any((media) => mediaKindMap.values
                                        .expand((e) => e)
                                        .contains(media.kind)) &&
                                        !mediaList.any((media) => !mediaKindMap.values
                                            .expand((e) => e)
                                            .contains(media.kind)))
                                      const Center(child: MyTextView(label: 'No data available')),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) =>
                            Center(child: Text('Error: $error')),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
