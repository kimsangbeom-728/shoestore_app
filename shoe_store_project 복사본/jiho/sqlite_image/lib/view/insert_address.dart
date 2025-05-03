import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlite_image/model/address.dart';
import 'package:sqlite_image/vm/database_handler.dart';

class InsertAddress extends StatefulWidget {
  const InsertAddress({super.key});

  @override
  State<InsertAddress> createState() => _InsertAddressState();
}

class _InsertAddressState extends State<InsertAddress> {
  late DatabaseHandler handler;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController relationController;

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    relationController = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("주소록 입력"),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "이름을 입력하세요"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "전화번호를 입력하세요"),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: "주소를 입력하세요"),
            ),
            TextField(
              controller: relationController,
              decoration: InputDecoration(labelText: "관계를 입력하세요"),
            ),
            ElevatedButton(
              onPressed: () {
                getImageFromGallery(ImageSource.gallery);
              }, 
              child: Text("Gallery")
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Colors.white,
                child: imageFile == null
                ? Center(child: Text("image is not selected!")) 
                : Image.file(File(imageFile!.path)),
            ),
            ElevatedButton(
              onPressed: () {
                insertAction();
              }, 
              child: Text("입력")
            ),
          ],
        ),
      ),
    );
  }//build
  Future getImageFromGallery(ImageSource imageSouce)async{
    final XFile? pickedFile = await picker.pickImage(source: imageSouce);
    if(pickedFile == null){
      return;
    }else{
      imageFile = XFile(pickedFile.path);
      setState(() {});
    }
  }
  insertAction()async{
    // File Type을 Byte type으로 변환
    File imageFile1 = File(imageFile!.path);
    Uint8List getImage = await imageFile1.readAsBytes();

    var addressinsert = Address(
      name: nameController.text, 
      phone: phoneController.text, 
      address: addressController.text, 
      relation: relationController.text, 
      image: getImage
    );

    int result =  await handler.insertAddress(addressinsert);
    if(result==0){
      // errosnackbar();
    }else{
      _showDilog();
    }
  }

  _showDilog(){
    Get.defaultDialog(
      title: "입력 완료",
      middleText: "입력이 완료 되었습니다",
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          }, 
          child: Text("Ok")
        ),
      ]
    );
  }
}//class