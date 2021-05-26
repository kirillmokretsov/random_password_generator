import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_strength/password_strength.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Random Password Generator',
        theme: ThemeData(
            primarySwatch: Colors.lightBlue, accentColor: Colors.amberAccent),
        home: PasswordPage());
  }
}

class PasswordPage extends StatefulWidget {
  const PasswordPage({Key key}) : super(key: key);

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  double _currentPasswordLength = 4;
  double strength;
  bool isIncludeLowercase = true;
  bool isIncludeUppercase = true;
  bool isIncludeNumbers = true;
  bool isIncludeSymbols = true;
  bool isExcludeSimilar = false;
  bool isExcludeAmbiguous = false;
  String password = "";
  Color colorOfPasswordBackground = Colors.transparent;

  String _generatePassword() {
    // Arrays with characters
    // I swear I didn't write it myself
    var lowercase = [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z",
    ];
    var uppercase = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z",
    ];
    var numbers = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
    ];
    var symbols = [
      "!",
      "#",
      "\$",
      "%",
      "&",
      "*",
      "+",
      "-",
      "?",
      "@",
      "\"",
      "'",
      "(",
      ")",
      ",",
      ".",
      "/",
      ":",
      ";",
      "<",
      "=",
      ">",
      "[",
      "\\",
      "]",
      "^",
      "_",
      "`",
      "{",
      "|",
      "}",
      "~",
    ];
    var similar = [
      "1",
      "i",
      "I",
      "l",
      "L",
      "|",
      "o",
      "O",
      "0",
    ];
    var ambiguous = [
      "\"",
      "'",
      "(",
      ")",
      ",",
      ".",
      "/",
      ":",
      ";",
      "<",
      "=",
      ">",
      "[",
      "\\",
      "]",
      "^",
      "_",
      "`",
      "{",
      "|",
      "}",
      "~",
    ];
    // We do not add ambiguous because we already use them in symbols
    // The ambiguous array necessary only to remove them
    var resultChars = lowercase + uppercase + numbers + symbols + similar;
    if (!isIncludeLowercase)
      resultChars.removeWhere((element) => lowercase.contains(element));
    if (!isIncludeUppercase)
      resultChars.removeWhere((element) => uppercase.contains(element));
    if (!isIncludeNumbers)
      resultChars.removeWhere((element) => numbers.contains(element));
    if (!isIncludeSymbols)
      resultChars.removeWhere((element) => symbols.contains(element));
    if (isExcludeSimilar)
      resultChars.removeWhere((element) => similar.contains(element));
    if (isExcludeAmbiguous)
      resultChars.removeWhere((element) => ambiguous.contains(element));

    if (resultChars.isNotEmpty) {
      colorOfPasswordBackground = Colors.grey.shade300;
      String result = "";
      var random = Random.secure();
      for (var a = 0; a < _currentPasswordLength; a++) {
        result += resultChars[random.nextInt(resultChars.length)];
      }
      return result;
    } else {
      colorOfPasswordBackground = Colors.white;
      return "";
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Random Password Generator"),
        ),
        body: DefaultTextStyle(
          style: TextStyle(),
          child: ListView(
            children: [
              // TODO: make slider be log2
              Slider(
                value: _currentPasswordLength,
                min: 4,
                max: 256,
                divisions: 252,
                label: _currentPasswordLength.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentPasswordLength = value;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Include Lowercase Characters"),
                value: isIncludeLowercase,
                onChanged: (bool a) {
                  setState(() {
                    isIncludeLowercase = a;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Include Uppercase Characters"),
                value: isIncludeUppercase,
                onChanged: (bool a) {
                  setState(() {
                    isIncludeUppercase = a;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Include Numbers"),
                value: isIncludeNumbers,
                onChanged: (bool a) {
                  setState(() {
                    isIncludeNumbers = a;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Include Symbols"),
                value: isIncludeSymbols,
                onChanged: (bool a) {
                  setState(() {
                    isIncludeSymbols = a;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Exclude Similar Characters"),
                value: isExcludeSimilar,
                onChanged: (bool a) {
                  setState(() {
                    isExcludeSimilar = a;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Exclude Ambiguous Characters"),
                value: isExcludeAmbiguous,
                onChanged: (bool a) {
                  setState(() {
                    isExcludeAmbiguous = a;
                  });
                },
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      password = _generatePassword();
                      strength = estimatePasswordStrength(password);
                      String message;
                      if (strength < 0.2)
                        message = "Password is extremely weak";
                      else if (strength < 0.4)
                        message = "Password is weak";
                      else if (strength < 0.6)
                        message = "Password is normal";
                      else if (strength < 0.8)
                        message = "Password is strong";
                      else if (strength < 1.0)
                        message = "Password is especially strong";
                      else if (strength == 1.0)
                        message = "Password is impossible to hack";
                      else
                        message =
                            "Some error occurred when we estimated password strength. Please, leave issue on our GitHub";
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
                  child: Text("Generate Password"),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                color: colorOfPasswordBackground,
                child: Text(password,
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontFamily: 'RobotoMono',
                      fontFeatures: [FontFeature.tabularFigures()],
                    )),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () {
            if (password.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password has copied to clipboard'),
                ),
              );

              Clipboard.setData(ClipboardData(text: password));
            }
          },
        ),
      );
}
