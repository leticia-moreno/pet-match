import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petmatch/main.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Perfil",
              style: TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? "Usuário não está logado.",
              style: const TextStyle(fontSize: 30),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _auth.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                    (route) => false,
                  );
                } catch (e) {
                  print("Erro ao fazer logout: $e");
                }
              },
              child: const Text("Sair"),
            ),
          ],
        ),
      ),
    );
  }
}
