import 'dart:io';

import 'package:book_shelf/models/book.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelExport {
  String getDeviceInternalPath(dir) {
    List<String> comp = dir.path.split('/');
    List<String> trunc = comp.sublist(1, 4);
    return trunc.join('/');
  }

  void exportData(List<Book> listBooks, BuildContext context) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['All Books'];

    CellStyle columnStyle = CellStyle(bold: true, fontSize: 14,);

    var bookNameColumn = sheetObject.cell(CellIndex.indexByString('A1'));
    bookNameColumn.value = TextCellValue('Book Name');
    bookNameColumn.cellStyle = columnStyle;
    //kitap ismi yazdirma

    var authorNameColumn = sheetObject.cell(CellIndex.indexByString('B1'));
    authorNameColumn.value = TextCellValue('Author Name');
    authorNameColumn.cellStyle = columnStyle;
    //yazar ismi yazdirma

    var pageNumberColumn = sheetObject.cell(CellIndex.indexByString('C1'));
    pageNumberColumn.value = TextCellValue('Number of Pages');
    pageNumberColumn.cellStyle = columnStyle;
    //kitap sayfa yazdirma

    for (var i = 0; i < listBooks.length; i++) {
      var bookNameCell = sheetObject.cell(CellIndex.indexByString('A${i + 2}'));
      bookNameCell.value = TextCellValue(listBooks[i].title);

      var authorNameCell =
          sheetObject.cell(CellIndex.indexByString('B${i + 2}'));
      authorNameCell.value = TextCellValue(listBooks[i].auhtorName);

      var pageNumberCell =
          sheetObject.cell(CellIndex.indexByString('C${i + 2}'));
      pageNumberCell.value = IntCellValue(listBooks[i].numberOfPages ?? 0);
    }

    //save method

    final permissionStatus = await Permission.manageExternalStorage.status;
    if (permissionStatus.isDenied) {
      // Here just ask for the permission for the first time
      await Permission.manageExternalStorage.request();

      // I noticed that sometimes popup won't show after user press deny
      // so I do the check once again but now go straight to appSettings
      if (permissionStatus.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      // Here open app settings for user to manually enable permission in case
      // where permission was permanently denied
      await Permission.manageExternalStorage.request();
    } else if (permissionStatus.isGranted) {
      var fileBytes = excel.save();

      final directory = await getDownloadsDirectory();
      final storage = getDeviceInternalPath(directory);
      final dir = Directory('/$storage/Download');

      var filePath = '${dir.path}/All Books.xlsx';

      File file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(fileBytes!);

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$filePath kaydedildi')));
      }
    }
  }
}
