import 'package:book_shelf/providers/loading_provider.dart';
import 'package:book_shelf/service/excel_export.dart';
import 'package:book_shelf/widgets/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:book_shelf/models/book.dart';
import 'package:book_shelf/providers/book_list_provider.dart';
import 'package:book_shelf/widgets/floating_action_button.dart';

class BookShelf extends ConsumerStatefulWidget {
  const BookShelf({super.key});

  @override
  ConsumerState<BookShelf> createState() => _BookShelfState();
}

class _BookShelfState extends ConsumerState<BookShelf> {
  @override
  void initState() {
    super.initState();
    ref.read(bookListProvider.notifier).loadBook();
  }

  @override
  Widget build(BuildContext context) {
    bool loadingState = ref.watch(loadingProvider);
    List<Book> scanedBooks = ref.watch(bookListProvider);
    Widget content;

    if (scanedBooks.isNotEmpty && !loadingState) {
      content = Center(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: scanedBooks.length,
          itemBuilder: (context, index) {
            var createBook = scanedBooks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.onPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: ListItem(createBook: createBook, ref: ref),
              ),
            );
          },
        ),
      );
    } else {
      content = const Center(
        child: Text('Lets scan a book'),
      );
    }

    if (loadingState) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Library'),
          actions: [
            IconButton(
                onPressed: () {
                  var export = ExcelExport();
                  export.exportData(scanedBooks, context);
                },
                icon: const Icon(Icons.save_alt))
          ],
          centerTitle: true,
        ),
        body: content,
        floatingActionButton: const CustomFloatingButton(),
      ),
    );
  }
}
