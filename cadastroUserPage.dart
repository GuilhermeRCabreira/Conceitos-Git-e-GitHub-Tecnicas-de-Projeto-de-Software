import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:carteira_saude/pages/homePage.dart';
import 'package:carteira_saude/pages/login/login_screen.dart';
import 'package:carteira_saude/pages/snackBar/showSnackBar.dart';
import 'package:carteira_saude/services/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:carteira_saude/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CadastroUserPage extends StatefulWidget {
  @override
  State<CadastroUserPage> createState() => _CadastroUserPageState();
}

class _CadastroUserPageState extends State<CadastroUserPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _senhaConfController = TextEditingController();
  bool _showPassword = false;

  void _limpar() {
    setState(() {
      _nomeController.clear();
      _sobrenomeController.clear();
      _cpfController.clear();
      _dataNascController.clear();
      _emailController.clear();
      _senhaController.clear();
      _senhaConfController.clear();
    });
  }

  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final TextEditingController _dataNascController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        print(_dataNascController.text = dateFormatter.format(selectedDate));
      });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _dataNascController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _senhaController.dispose();
    _senhaConfController.dispose();

    super.dispose();
  }

  FirebaseAuthService authService = FirebaseAuthService();

  Color tituloColor = Color.fromARGB(255, 40, 78, 121);
  Color textColor = Colors.black;
  Color fundoColor = Color.fromARGB(255, 239, 239, 239);
  Color textoBotao = Colors.white;
  String? urlPhoto;

  Future<void> uploadFromUrl() async {
    final imageUrl =
        'https://static.vecteezy.com/ti/vetor-gratis/p1/18765757-icone-de-perfil-de-usuario-em-estilo-simples-ilustracao-em-avatar-membro-no-fundo-isolado-conceito-de-negocio-de-sinal-de-permissao-humana-vetor.jpg';

    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/temp_image.jpg');
    await file.writeAsBytes(bytes);

    authService.uploadCriacao(file: file, fileName: 'userfoto');
    print("Imagem salva");
  }

  Future<bool?> _criarUsuario({
    required String email,
    required String senha,
    required String cpf,
    required String nome,
    required String sobrenome,
    required String dataNasc,
  }) async {
    String? erro = await authService.cadastrarUsuario(
        email: email, senha: senha, cpf: cpf);
    if (erro == null) {
      print("Funcionou");
      authService.adUsuarioInfos(nome, sobrenome, cpf, dataNasc, email);
      uploadFromUrl();
      print("##################################################Vamo");
      return true;
    } else {
      print("###############################################deu ruim" + erro);
      print("###############################################" + erro);
      return false;
    }
  }

  bool confirmacaoSenha() {
    if (_senhaController.text.trim() == _senhaConfController.text.trim() &&
        _senhaController.text.length > 6) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController? controller;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        decoration: BoxDecoration(color: fundoColor),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Image.asset(
                  "assets/logo.png",
                  height: 200,
                ),
              ),
              Text(
                "Boas-vindas!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tituloColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 25),
              ),
              Text(
                "Para assumir o protagonismo sobre seus dados e poder levá-los com você para onde for, crie uma conta:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 25),
              ),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      autofocus: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Nome:",
                        labelStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: textColor,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _sobrenomeController,
                      autofocus: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Sobrenome:",
                        labelStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: textColor,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _cpfController,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter(),
                      ],
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "CPF:",
                        labelStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.wallet_rounded,
                          color: textColor,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      onTap: () {
                        _selectDate(context);
                      },
                      controller: _dataNascController,
                      autofocus: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Data de Nascimento:",
                        labelStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_month,
                          color: textColor,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      autofocus: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "E-mail:",
                        labelStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: textColor,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value == "") {
                          return "O valor de e-mail deve ser preenchido";
                        }
                        if (!value.contains("@") ||
                            !value.contains(".") ||
                            value.length < 4) {
                          showSnackBar(
                              context: context,
                              mensagem: "O e-mail deve ser válido.");
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _senhaController,
                      style: TextStyle(
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        labelText: "Senha:",
                        labelStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.vpn_key,
                          color: textColor,
                        ),
                        suffixIcon: GestureDetector(
                          child: Icon(
                            _showPassword == false
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: textColor,
                          ),
                          onTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                      ),
                      obscureText: _showPassword == false ? true : false,
                    ),
                    TextFormField(
                      controller: _senhaConfController,
                      style: TextStyle(
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        labelText: "Confirme a senha:",
                        labelStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.vpn_key,
                          color: textColor,
                        ),
                        suffixIcon: GestureDetector(
                          child: Icon(
                            _showPassword == false
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: textColor,
                          ),
                          onTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor,
                          ),
                        ),
                      ),
                      obscureText: _showPassword == false ? true : false,
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 50),
              ),
              ElevatedButton(
                onPressed: () {
                  if (GetUtils.isCpf(_cpfController.text)) {
                    print('cpf válido!');
                  } else {
                    print('cpf inválido!');
                  }

                  if (_criarUsuario(
                            email: _emailController.text.trim(),
                            senha: _senhaController.text.trim(),
                            cpf: _cpfController.text.trim(),
                            nome: _nomeController.text.trim(),
                            sobrenome: _sobrenomeController.text.trim(),
                            dataNasc: _dataNascController.text.trim(),
                          ) ==
                          true &&
                      confirmacaoSenha() == true) {
                    showSnackBar(
                        context: context,
                        mensagem: "Usuário criado com sucesso!",
                        isErro: false);
                  } else {
                    showSnackBar(
                        context: context,
                        mensagem: "Usuário criado com sucesso!",
                        isErro: false);
                  }
                  _limpar();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: tituloColor,
                  onPrimary: textoBotao,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Criar conta",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
