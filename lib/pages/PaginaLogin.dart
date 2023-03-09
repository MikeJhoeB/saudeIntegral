// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../constants/controllers.dart';
import '../controllers/UsuarioController.dart';

class PaginaLogin extends StatefulWidget {
  const PaginaLogin({super.key});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  bool isLogin = true;

  static const String titulo = "Bem Vindo";

  bool loadingGoogle = false;

  loginGoogle() async {
    setState(() => loadingGoogle = true);
    try {
      await usuarioController.loginGoogle();
    } on AuthException catch (e) {
      setState(() => loadingGoogle = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }

  notTryingToLogin() {
    return !loadingGoogle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              const Text(
                titulo,
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.5),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Row(children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        children: [
                          Visibility(
                            visible: (isLogin) ? true : false,
                            child: Column(
                              children: (loadingGoogle)
                                  ? [
                                      const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      )
                                    ]
                                  : [
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: FractionallySizedBox(
                                          widthFactor: 0.8,
                                          child: SignInButton(
                                            Buttons.Google,
                                            text: "Conectar com Google",
                                            onPressed: () {
                                              if (notTryingToLogin()) {
                                                loginGoogle();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
