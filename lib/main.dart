import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saude_integral/pages/PaginaInicial.dart';

import 'constants/firebase.dart';
import 'controllers/UsuarioController.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialization.then((value) {
    Get.put(UsuarioController());
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp (
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaginaInicial(),
    );
  }
}
