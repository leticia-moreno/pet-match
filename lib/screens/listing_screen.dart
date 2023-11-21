import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class ListingScreen extends StatefulWidget {
  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _announceAnimal() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;

      if (_validateEmptyForm()) {
        final userRef = _databaseRef.child("animals").push();
        final uuid = const Uuid().v4();

        userRef.set({
          "id": userRef.key,
          "name": _nameController.text,
          "description": _descriptionController.text,
          "breed": _breedController.text,
          "age": _ageController.text,
          "type": _typeController.text,
          "contact": _contactController.text,
          "user": userId,
        });

        if (_imageFile != null) {
          final snapshot = await _storage
              .ref()
              .child("animals")
              .child(userRef.key!)
              .child(uuid)
              .putFile(_imageFile!);
          final downloadUrl = await snapshot.ref.getDownloadURL();
          userRef.child("image").set(downloadUrl);
        }

        _nameController.clear();
        _descriptionController.clear();
        _breedController.clear();
        _ageController.clear();
        _typeController.clear();
        _contactController.clear();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anuncio criado com sucesso!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário não logado")),
      );
    }
  }

  bool _validateEmptyForm() {
    const icon = Icons.warning;

    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar("Insira o nome do animal.", icon);
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar("Insira a descrição", icon);
      return false;
    }
    if (_breedController.text.trim().isEmpty) {
      _showErrorSnackBar("Insira a raça.", icon);
      return false;
    }
    if (_ageController.text.trim().isEmpty) {
      _showErrorSnackBar("Insira a idade.", icon);
      return false;
    }
    if (_typeController.text.trim().isEmpty) {
      _showErrorSnackBar("Insira o tipo.", icon);
      return false;
    }
    if (_contactController.text.trim().isEmpty) {
      _showErrorSnackBar("Insira o contato.", icon);
      return false;
    }
    if (_imageFile == null) {
      _showErrorSnackBar("Insira a imagem", icon);
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anunciar animal"),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Anunciar animal",
                style: TextStyle(fontSize: 50),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Descrição"),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(labelText: "Raça"),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: "Idade"),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(labelText: "Tipo"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: "Contato"),
              ),
              const SizedBox(height: 10),
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      width: 130,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getImage,
                child: const Text("Adicionar Imagem"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _announceAnimal,
                child: const Text("Registrar animal"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
