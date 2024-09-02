class Book {
  Book(
      {required this.title,
      required this.numberOfPages,
      required this.imagePath,
      this.auhtorName = 'Unknown'});

  late final String title;
  late final int? numberOfPages;
  late final String imagePath;
  String auhtorName = 'Unknown';
  bool? manuel = false;

  Book.fromJsonWtihAuthor(
      Map<String, dynamic> json, String isbn, String auhtor) {
    title = json['title'] as String;
    numberOfPages = json['number_of_pages'] as int?;
    imagePath = 'https://covers.openlibrary.org/b/isbn/$isbn-M.jpg';
    auhtorName = auhtor;
  }

  Book.manualCreate(String bookName, int? pageNumber, String author) {
    title = bookName;
    numberOfPages = pageNumber;
    auhtorName = author;
    imagePath = 'assets/images/book.png';
    manuel = true;
  }

  Book.fromJson(Map<String, dynamic> json, String isbn) {
    title = json['title'] as String;
    numberOfPages = json['number_of_pages'] as int?;
    imagePath = 'https://covers.openlibrary.org/b/isbn/$isbn-M.jpg';
  }

  Book.fromJsonLocal(Map<String, dynamic> json) {
    title = json['title'] as String;
    numberOfPages = json['numberOfPages'] as int?;
    imagePath = json['imagePath'] as String;
    auhtorName = json['auhtorName'] as String;
    manuel = json['manuel'] as bool?;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'numberOfPages': numberOfPages,
      'imagePath': imagePath,
      'auhtorName': auhtorName,
      'manuel': manuel
    };
  }
}
