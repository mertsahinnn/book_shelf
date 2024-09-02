import 'dart:convert';

import 'package:book_shelf/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveLocal {
  void saveList(List<Book> bookList) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    List<String> booksJson = bookList
        .map(
          (book) => jsonEncode(book.toJson()),
        )
        .toList();

    await pref.setStringList('books', booksJson);
  }

  Future<List<Book>> loadBooks() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    List<String>? booksJson = pref.getStringList('books');
    if (booksJson != null) {
      return booksJson
          .map(
            (bookJson) => Book.fromJsonLocal(jsonDecode(bookJson)),
          )
          .toList();
    }
    return [];
  }
}
