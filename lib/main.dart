import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pedidos_app/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Inicializa Firebase primero

  runApp(
    MaterialApp(
      title: 'Cevicheria Los Gorditos',
      home: RegistroPedidosApp(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ),
  );
}
