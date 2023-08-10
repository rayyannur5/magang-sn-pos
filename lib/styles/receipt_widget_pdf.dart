import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class ReceiptWidgetPDF {
  static Future<Uint8List> makePDF(Map data) async {
    final pdf = Document();
    final imageLogo = MemoryImage((await rootBundle.load('assets/image/logo.png')).buffer.asUint8List());
    final imageTextPrint = MemoryImage((await rootBundle.load('assets/image/text-print.png')).buffer.asUint8List());

    final Uint8List fontData = (await rootBundle.load('assets/Space_Mono/SpaceMono-Bold.ttf')).buffer.asUint8List();
    final ttf = Font.ttf(fontData.buffer.asByteData());

    TextStyle bold = TextStyle(font: ttf);

    pdf.addPage(Page(
      pageFormat: PdfPageFormat.a5,
      build: (context) {
        return Column(children: [
          Image(imageLogo, height: 50),
          Image(imageTextPrint, height: 25),
          Text("-- ${data['brand_store']} --", style: bold),
          Text("-- ${data['name_store']} --", style: bold),
          Text(data['tanggal'], style: bold),
          SizedBox(height: 10),
          Row(children: [Text("Kasir     : ${data['name']}", style: bold)]),
          Row(children: [Text("Pelanggan : -", style: bold)]),
          Divider(height: 4, borderStyle: BorderStyle.dashed),
          for (int i = 0; i < data['data'].length; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['data'][i]['name'], style: bold),
                Text(data['data'][i]['harga'], style: bold),
              ],
            ),
          Divider(height: 4, borderStyle: BorderStyle.dashed),
          Text('TOTAL', style: TextStyle(font: ttf, fontSize: 24)),
          Text(data['total'], style: TextStyle(font: ttf, fontSize: 24)),
          Divider(height: 4, borderStyle: BorderStyle.dashed),
          Text(data['message_store'], style: bold),
          Text(data['address_store'], style: bold),
          Text(data['phone_store'], style: bold),
          SizedBox(height: 10),
          Text(data['id_trx'], style: bold),
        ]);
      },
    ));

    return pdf.save();
  }
}
