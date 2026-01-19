import 'package:flutter/material.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {

  String helloText = '안녕1';

  TextStyle ts1 = TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20);
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(helloText, style: TextStyle(fontSize: 30),),

            ElevatedButton(
                onPressed: (){
                },
                child: Text('버튼1'),
            ),

            Image.network(
                width: 150,
                'https://dora-guide.com/wp-content/uploads/2019/11/%EC%95%88%EB%93%9C%EB%A1%9C%EC%9D%B4%EB%93%9C-%EC%8A%A4%ED%8A%9C%EB%94%94%EC%98%A4-%EC%84%A4%EC%B9%98-%EB%B0%A9%EB%B2%95-8.png'
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text('안녕하세요', style: ts1),
            ),
            Text('안녕하세요', style: ts1),
            SizedBox(height: 50,),
            Text('안녕하세요', style: ts1),
            Text('안녕하세요', style: ts1),
            Text('안녕하세요', style: ts1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('로우1'),

                Text('로우4'),
              ],
            ),

            TextFormField(
              controller: textEditingController,
            )
          ],
        )
        ),
    );
  }
}
