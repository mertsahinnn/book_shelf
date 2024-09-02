import 'package:book_shelf/models/book.dart';
import 'package:book_shelf/service/save_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookListNotifier extends StateNotifier<List<Book>> {
  BookListNotifier() : super([]);

  void addBook(Book book) {
    state = [...state, book];
    SaveLocal().saveList(state);
  }

  void loadBook() async {
    var bookList = await SaveLocal().loadBooks();
    state = bookList;
  }

  void removeBook(Book book) {
    state = state
        .where(
          (element) => element != book,
        )
        .toList();
    SaveLocal().saveList(state);
  }
}

final bookListProvider = StateNotifierProvider<BookListNotifier, List<Book>>(
  (ref) {
    return BookListNotifier();
  },
);
