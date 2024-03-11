import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _responseBody = "";
  bool isSending = false;
  XFile? _image;
  String customPrompt = "";
  TextEditingController _controller = TextEditingController();
  _openCamer() {
    if (_image == null) {
      _getImageFromCamera();
    }
  }

  Future<void> _getImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      ImageCropper cropper = ImageCropper();
      final croppedImage =
          await cropper.cropImage(sourcePath: image.path, aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ]);
      setState(() {
        _image = croppedImage != null ? XFile(croppedImage.path) : null;
      });
    }
  }

  Future<void> sendImage(XFile? imageFIle) async {
    if (imageFIle == null) return;
    setState(() {
      isSending = true;
    });
    String based64Image = base64Encode(File(imageFIle.path).readAsBytesSync());
    String apiKey = "API Key";
    String requestBody = json.encode({
      "contents": [
        {
          "parts": [
            {"text": customPrompt == "" ? "What is this?" : customPrompt},
            {
              "inlineData": {"mimeType": "image/jpeg", "data": based64Image}
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.4,
        "topK": 32,
        "topP": 1,
        "maxOutputTokens": 4096,
        "stopSequences": []
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ]
    });
    http.Response response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro-vision-latest:generateContent?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: requestBody);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonBody = json.decode(response.body);
      setState(() {
        _responseBody =
            jsonBody["candidates"][0]["content"]["parts"][0]["text"];
        isSending = false;
      });
    } else {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SACHAL'S AI"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _image == null
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: const Center(
                          child: Text(
                            "No Image Selected",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 42,
                                fontFamily: "Time Zone"),
                          ),
                        ),
                      )
                    : Image.file(File(_image!.path)),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.black),
                          onChanged: (value) => customPrompt = value,
                          decoration: InputDecoration(
                            hintText: "Ask me anything by given the Picture",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (_image == null) {
                                  _openCamer();
                                } else {
                                  _image = null;
                                  _openCamer();
                                }
                              },
                              icon: const Icon(Icons.camera_alt_rounded),
                            ),
                          ),
                        ),
                      ),
                    ),

                    isSending
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: Colors.red,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              sendImage(_image);
                              _controller.clear();
                            },
                            icon: const Icon(Icons.send),
                            color: Colors.green,
                            iconSize: 35,
                          ),

                    // SizedBox(
                    //   width: MediaQuery.of(context).size.width * 0.7,
                    //   child: TextField(),
                    // ),
                    // IconButton(onPressed: () {}, icon: Icon(Icons.send))
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _responseBody,
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _image == null ? _openCamer() : sendImage(_image);
      //   },
      //   tooltip: _image == null ? "Pick Image" : "Send Image",
      //   child: Icon(_image == null ? Icons.camera_alt_outlined : Icons.send),
      // ),
    );
  }
}
