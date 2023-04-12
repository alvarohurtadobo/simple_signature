import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';


class SignaturePage extends StatefulWidget {
  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final GlobalKey<SignatureState> _signatureKey = GlobalKey<SignatureState>();
  bool _isDrawing = false;
  ByteData _img = ByteData(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firma'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Signature(
                key: _signatureKey,
                
                onSign: () {
                  setState(() {
                    _isDrawing = true;
                  });
                },
                
                // onSignEnd: () {
                //   setState(() {
                //     _isDrawing = false;
                //   });
                // },
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_isDrawing) {
                // Renderizamos la firma a una imagen
                // final signatureImage = await _signatureKey.currentState!.();
                // final bytes = await signatureImage.toByteData(format: ImageByteFormat.png);
                // final pngBytes = bytes!.buffer.asUint8List();

                final sign = _signatureKey.currentState;
                        //retrieve image data, do whatever you want with it (send to server, save locally...)
                        final image = await sign?.getData();
                        var data = await image?.toByteData(format: ui.ImageByteFormat.png);
                        sign?.clear();
                        // final encoded = base64.encode(data?.buffer.asUint8List());
                        setState(() {
                          _img = data!;
                        });
                        // debugPrint("onPressed " + encoded);

                // Guardamos la imagen en la galería
                final result = await ImageGallerySaver.saveImage(data?.buffer.asUint8List()??Uint8List(0));

                // Mostramos una alerta con el resultado de la operación
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Resultado'),
                    content: Text(result['isSuccess'] ? 'La firma se guardó correctamente.' : 'Ocurrió un error al guardar la firma.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Aceptar'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text('Exportar PNG'),
          ),
        ],
      ),
    );
  }
}
