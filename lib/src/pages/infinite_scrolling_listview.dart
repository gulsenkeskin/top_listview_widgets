import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfiniteScrollingListViewPage extends StatefulWidget {
  const InfiniteScrollingListViewPage({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  State<InfiniteScrollingListViewPage> createState() =>
      _InfiniteScrollingListViewPageState();
}

class _InfiniteScrollingListViewPageState
    extends State<InfiniteScrollingListViewPage> {
  final controller = ScrollController();
  // List<String> items = List.generate(15, (index) => 'Item ${index + 1}');
  bool hasMore = true;
  List<String> items = [];
  int page = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetch();
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetch();
      }
    });
  }

  Future fetch() async {
    if (isLoading) return;
    isLoading = true;
    const limit = 25;
    final url = Uri.parse(
        "https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List newItems = json.decode(response.body);

      setState(() {
        page++;
        isLoading = false;
        if (newItems.length < limit) {
          hasMore = false;
        }

        items.addAll(newItems.map<String>((item) {
          final number = item['id'];
          return 'Item $number';
        }).toList());
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future refresh() async {
    //ekranı yukarıdan aşağı doğru kaydırınca verileri ilk haline getirir.
    setState(() {
      isLoading = false;
      hasMore = true;
      page = 0;
      items.clear();
    });
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
            controller: controller,
            padding: const EdgeInsets.all(8),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index < items.length) {
                final item = items[index];
                return ListTile(
                  title: Text(item),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: hasMore
                        ? const CircularProgressIndicator()
                        : const Text("Görüntülenecek veri yok"),
                  ),
                );
              }
            }),
      ),
    );
  }
}
