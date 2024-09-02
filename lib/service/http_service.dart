import 'dart:io';

import 'package:book_shelf/models/book.dart';
import 'package:dio/dio.dart';

class HttpService {
  final Dio dio = Dio();

  Future<Book?> searchBookWithIsbn(String isbn) async {
    try {
      // Perform the HTTP GET request
      Response response = await dio.get(
        'https://openlibrary.org/isbn/$isbn.json', // Make sure to add .json to get JSON data
        options: Options(headers: {'Accept': 'application/json'}),
      );

      // Check if the request was successful
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        Map<String, dynamic> map = response.data;

        if (map.containsKey('authors')) {
          // Get author information if available
          String olid = map['authors'][0]['key'];
          String author = await getAuthorsInfo(olid);
          var book = Book.fromJsonWtihAuthor(response.data, isbn, author);
          return book;
        } else {
          // Create book without author if not available
          var book = Book.fromJson(response.data, isbn);
          return book;
        }
      }

      // Return null if the response is neither 200 OK nor 404 Not Found
      return null;
    } on DioException catch (e) {
      // Handle network and other request-related errors
      if (e.response?.statusCode == HttpStatus.notFound) {
        // Specifically handle the 404 error
        print('Book not found (404) for ISBN: $isbn');
        return null;
      } else {
        // Log other errors for debugging purposes
        print('Failed to fetch book data: ${e.message}');
        return null;
      }
    } catch (e) {
      // Handle any other unexpected errors
      print('Unexpected error occurred: $e');
      return null;
    }
  }

  Future<String> getAuthorsInfo(String olid) async {
    var response = await dio.get(
      'https://openlibrary.org$olid',
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );

    if (response.statusCode == HttpStatus.ok && response.data != null) {
      String author = response.data['name']
          as String; // gelen response.data ditekt olarak bize map olarak geliyor. Buna dikkat!
      return author;
    }

    return 'Unknown';
  }
}
