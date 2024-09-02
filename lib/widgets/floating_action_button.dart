import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:book_shelf/models/book.dart';
import 'package:book_shelf/providers/book_list_provider.dart';
import 'package:book_shelf/providers/floating_button_providers.dart';
import 'package:book_shelf/providers/loading_provider.dart';
import 'package:book_shelf/service/http_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomFloatingButton extends ConsumerStatefulWidget {
  const CustomFloatingButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomFloatingButtonState();
}

class _CustomFloatingButtonState extends ConsumerState<CustomFloatingButton> {
  HttpService service = HttpService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController bookName = TextEditingController();
  TextEditingController authorName = TextEditingController();
  TextEditingController pageNumber = TextEditingController();

  void bardoceScanner() async {
    var result = await BarcodeScanner.scan();
    // buralar deneme amacli boyle kalacak ama if else boyle kalacak
    if (result.rawContent.length == 13 || result.rawContent.length == 10) {
      ref.read(loadingProvider.notifier).toggleLoading();
      Book? newBook = await service.searchBookWithIsbn(result.rawContent);

      if (newBook != null && context.mounted) {
        _showaboutdialog(newBook, context);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Book not found!')));
          ref.read(loadingProvider.notifier).toggleLoading();

          return;
        }
      }

      return;
    }
  }

  void _showaboutdialog(Book book, BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible:
          false, // bos alana basildiinda kapanmasini engelleyecek
      builder: (ctx) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: book.imagePath,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Book Name : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(book.title),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Author Name : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(book.auhtorName)
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Number of Pages : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(book.numberOfPages.toString())
                      ],
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        ref.read(bookListProvider.notifier).addBook(book);
                      });
                      ref.read(loadingProvider.notifier).toggleLoading();

                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Book'),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        ref.read(loadingProvider.notifier).toggleLoading();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Cancel'))
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var toggle = ref.read(floatingButtonProvider.notifier);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: () {
            toggle.toggleFloatingButton();
          },
          label: const Text('Add Book'),
        ),
        const SizedBox(
          height: 16,
        ),
        Visibility(
            visible: ref.watch(floatingButtonProvider),
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    bardoceScanner();
                    toggle.toggleFloatingButton();
                  },
                  tooltip: 'Option 1',
                  child: const Icon(Icons.qr_code_scanner),
                ),
                const SizedBox(
                  height: 5,
                ),
                FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return Form(
                          key: _formKey,
                          child: AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Add Book with ISBN 13',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: false),
                                  decoration: const InputDecoration(
                                      label: Text('ISBN 13 Number')),
                                  validator: (value) {
                                    if (value == null || value.length != 13) {
                                      return 'Must be a valid, isbn number';
                                    }
                                    return null;
                                  },
                                  onSaved: (isbn) async {
                                    if (isbn != null) {
                                      Book? newBook = await service
                                          .searchBookWithIsbn(isbn);

                                      if (newBook != null && context.mounted) {
                                        ref
                                            .read(loadingProvider.notifier)
                                            .toggleLoading();
                                        Navigator.pop(ctx);
                                        _showaboutdialog(newBook, context);
                                      } else {
                                        if (context.mounted) {
                                          // SnackBar'ı Navigator.pop işlemi sonrasına aldık ve mounted olup olmadığını kontrol ettik.
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Book not found!'),
                                              duration: Duration(seconds: 5),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Book not found!'),
                                            duration: Duration(seconds: 5),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      FocusScope.of(ctx).unfocus();
                                    }
                                  },
                                  child: const Text('Search Book'))
                            ],
                          ),
                        );
                      },
                    );
                    toggle.toggleFloatingButton();
                  },
                  tooltip: 'Option 2',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(
                  height: 5,
                ),
                FloatingActionButton(
                  onPressed: () {
                    toggle.toggleFloatingButton();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Add Book Manual',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextField(
                                controller: bookName,
                                decoration: const InputDecoration(
                                    label: Text('Book Name')),
                                maxLength: 100,
                                textAlignVertical: TextAlignVertical.bottom,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: authorName,
                                decoration: const InputDecoration(
                                    label: Text('Author Name')),
                                maxLength: 100,
                                textAlignVertical: TextAlignVertical.bottom,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: pageNumber,
                                decoration: const InputDecoration(
                                    label: Text('Number of Pages')),
                                maxLength: 5,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: false),
                                textAlignVertical: TextAlignVertical.bottom,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Book newBook = Book.manualCreate(
                                        bookName.text,
                                        int.tryParse(pageNumber.text),
                                        authorName.text);
                                    ref
                                        .read(bookListProvider.notifier)
                                        .addBook(newBook);
                                    Navigator.pop(context);
                                    FocusScope.of(context).unfocus();
                                    bookName.clear();
                                    authorName.clear();
                                    pageNumber.clear();
                                  },
                                  child: const Text('Save Book'))
                            ],
                          ),
                        );
                      },
                    );
                  },
                  tooltip: 'Option 3',
                  child: const Icon(Icons.edit_document),
                ),
              ],
            ))
      ],
    );
  }
}
