import "package:app/app_drawer.dart";
import "package:app/constants/color.dart";
import "package:app/provider/news_provider.dart";
import "package:app/screens/create_news_screen.dart";
import "package:app/screens/news_detail_screen.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:hugeicons/hugeicons.dart";
import "package:provider/provider.dart";
import "package:timeago/timeago.dart" as timeago;

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNews();
    });
  }

  Future<void> _fetchNews({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    await Provider.of<NewsProvider>(
      context,
      listen: false,
    ).fetchNews(forceRefresh: forceRefresh);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(18),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight.withAlpha(78)),
            ),
            child: IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, size: 18),
              color: AppColors.primary,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Menu',
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: Text(
          "News Feed",
          style: GoogleFonts.mulish(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              color: AppColors.primary,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateNewsScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedRefresh,
              color: AppColors.primary,
            ),
            onPressed: () => _fetchNews(forceRefresh: true),
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (_isLoading && newsProvider.newsList.isEmpty) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (newsProvider.newsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedNews,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No news yet",
                    style: GoogleFonts.mulish(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _fetchNews(forceRefresh: true),
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              itemCount: newsProvider.newsList.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final news = newsProvider.newsList[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NewsDetailScreen(news: news),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            news.title[0].toUpperCase(),
                            style: GoogleFonts.mulish(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          news.authorName,
                                          style: GoogleFonts.mulish(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          news.title,
                                          style: GoogleFonts.mulish(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    timeago.format(
                                      DateTime.parse(news.createdAt),
                                    ),
                                    style: GoogleFonts.mulish(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                news.content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.mulish(
                                    fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _isExpanded ? null : 3,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: GoogleFonts.mulish(fontSize: 14, height: 1.4),
        ),
        if (widget.text.length > 100) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? "Read less" : "Read more",
              style: GoogleFonts.mulish(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
