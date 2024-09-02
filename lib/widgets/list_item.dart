import 'package:book_shelf/models/book.dart';
import 'package:book_shelf/providers/book_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.createBook,
    required this.ref,
  });

  final Book createBook;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const BeveledRectangleBorder(),
      leading: FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: createBook.manuel ?? false ? AssetImage(createBook.imagePath) : NetworkImage(createBook.imagePath),
        imageErrorBuilder: (context, error, stackTrace) {
          return Image(image: MemoryImage(kTransparentImage), width: 37.5, height: 56,);
        },
        height: 56,
        width: 37.5,
      ),
      title: Text(
        createBook.title,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      subtitle: Text(
        createBook.auhtorName,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: IconButton.outlined(
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(
              content:
                  Text('${createBook.title} silinsin mi ?'),
              action: SnackBarAction(
                label: 'Sil',
                onPressed: () {
                  ref
                      .read(bookListProvider.notifier)
                      .removeBook(createBook);
                },
              ),
            ));
          },
          icon: const Icon(Icons.remove,color: Colors.red,)),
    );
  }
}