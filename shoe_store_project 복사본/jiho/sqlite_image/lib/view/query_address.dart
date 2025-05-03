import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:sqlite_image/view/insert_address.dart';
import 'package:sqlite_image/view/update_address.dart';
import 'package:sqlite_image/vm/database_handler.dart';

class QueryAddress extends StatefulWidget {
  const QueryAddress({super.key});

  @override
  State<QueryAddress> createState() => _QueryAddressState();
}

class _QueryAddressState extends State<QueryAddress> {
  late DatabaseHandler handler;

  @override
  void initState() {
    super.initState();
  handler =DatabaseHandler();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("주소록 검색"),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(InsertAddress())!.then((value)=>reloadData());
            }, 
            icon: Icon(Icons.add)
          ),
        ],
      ),
      body: FutureBuilder(
        future: handler.queryAddress(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      UpdateAddress(),
                      arguments: [
                        snapshot.data![index].id!,
                        snapshot.data![index].name,
                        snapshot.data![index].phone,
                        snapshot.data![index].address,
                        snapshot.data![index].relation,
                        snapshot.data![index].image,
                      ]
                    )!.then((value)=>reloadData());
                  },
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: BehindMotion(), 
                      children: [
                        SlidableAction(
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: "삭제",
                          onPressed: (context) async{
                            await handler.deleteAddress(snapshot.data![index].id!);
                            snapshot.data!.remove(snapshot.data![index]);
                            setState(() {
                            });
                          },
                        ),
                      ]
                      ),
                    child: Card(
                      child: Row(
                        children: [
                          Image.memory(
                            snapshot.data![index].image,
                            width: 100,
                          ),
                          Column(
                            children: [
                              Text(
                                "이름 : ${snapshot.data![index].name}"
                              ),
                              Text("전화번호 : ${snapshot.data![index].phone}")
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              );
          }else{
            return Center(child: CircularProgressIndicator()
            );
          }
        },
      ),
    );
  }//build
  reloadData(){
    handler.queryAddress();
    setState(() {});
  }
}//class