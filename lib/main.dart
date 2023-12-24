// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';

import 'package:imagepostsflutter/posts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catstagram',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt_outlined),
              onPressed: () {},
            ),
            Text('Catstagram'),
          ],
        ),
      ),
      body: LazyLoadingListView(posts: posts),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.black),
            label: 'New Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.black),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class LazyLoadingListView extends StatefulWidget {
  final List<List<String>> posts;

  const LazyLoadingListView({Key? key, required this.posts}) : super(key: key);

  @override
  _LazyLoadingListViewState createState() => _LazyLoadingListViewState();
}

class _LazyLoadingListViewState extends State<LazyLoadingListView> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  int _visibleItemCount = 5;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    if (!_loading) {
      setState(() {
        _loading = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _visibleItemCount += 5;
          _loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _visibleItemCount,
      itemBuilder: (context, index) {
        if (index < widget.posts.length) {
          return PostWidget(images: widget.posts[index]);
        } else if (_loading) {
          return CircularProgressIndicator();
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class PostWidget extends StatefulWidget {
  final List<String> images;

  const PostWidget({Key? key, required this.images}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Column(
        children: [
          Container(
            height: 200.0,
            width: 250.0,
            padding: EdgeInsets.only(top: 8.0),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.images[index],
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(
                    value: null,
                    strokeWidth: 2.0,
                    color: Colors.black,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {}, 
                  icon: Icon(Icons.mode_comment_outlined)
                ),
                IconButton(
                  onPressed: () {}, 
                  icon: Icon(Icons.send)
                ),
              ],
            ),
          ),
          DotsIndicator(
            dotsCount: widget.images.length,
            position: _currentIndex.round(),
            decorator: DotsDecorator(
              color: Colors.grey,
              activeColor: Colors.blue,
              size: Size.fromRadius(2),
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

