import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlite_image/vm/database_handler.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sqlite_image/model/address.dart';

class UpdateAddress extends StatefulWidget {
  const UpdateAddress({super.key});

  @override
  State<UpdateAddress> createState() => _UpdateAddressState();
}

class _UpdateAddressState extends State<UpdateAddress> {
  late DatabaseHandler handler;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController relationController;

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  var value = Get.arguments ??"__";

  late int firstDisp;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    relationController = TextEditingController();

    nameController.text = value[1];
    phoneController.text = value[2];
    addressController.text = value[3];
    relationController.text = value[4];

    firstDisp = 0;
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
              decoration: InputDecoration(labelText: "이름"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "전화번호"),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: "주소"),
            ),
            TextField(
              controller: relationController,
              decoration: InputDecoration(labelText: "관계"),
            ),
            ElevatedButton(
              onPressed: () {
                getImageFromGallery(ImageSource.gallery);
              }, 
              child: Text("Gallery")
            ),
            firstDisp==0 
            ? Container(
              height: 200,
              color: Colors.green,
              child: Center(
                child: Image.memory(value[5]),
              ),
            )
            :
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
                if(firstDisp == 0){
                  updateAction();
                  setState(() {
                    
                  });
                }else{
                  updateActionAll();
                  setState(() {
                    
                  });
                }
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
      firstDisp +=1;
      setState(() {});
    }
  }
  updateAction()async{

    var addressupdate = Address(
      id: value[0],
      name: nameController.text, 
      phone: phoneController.text, 
      address: addressController.text, 
      relation: relationController.text,
      image: value[5] 
    );

    int result =  await handler.updateAddress(addressupdate);
    if(result==0){
      // errosnackbar();
    }else{
      _showDilog();
    }
  }
  updateActionAll()async{
    // File Type을 Byte type으로 변환
    File imageFile1 = File(imageFile!.path);
    Uint8List getImage = await imageFile1.readAsBytes();

    var addressupdate = Address(
      id: value[0],
      name: nameController.text, 
      phone: phoneController.text, 
      address: addressController.text, 
      relation: relationController.text, 
      image: getImage
    );

    int result =  await handler.updateAddressAll(addressupdate);
    if(result==0){
      // errosnackbar();
    }else{
      _showDilog();
    }
  }

  _showDilog(){
    Get.defaultDialog(
      title: "수정",
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
  }//build

}//class