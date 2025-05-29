import 'package:flutter/material.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          )),
          title: Text('Edit Profil'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50.0),
                alignment: Alignment.center,
                child: const CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage('assets/location.png'),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      child: Icon(Icons.edit),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Form(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       TextFormField(
                         controller: _nameController,
                         decoration: InputDecoration(
                           border: const OutlineInputBorder(),
                           labelText: 'Edit Nama',
                           hintText: "Masukkan nama",
                           suffixIcon: IconButton(
                             onPressed: () {
                               setState(() {
                                 _nameController.text = '';
                               });
                             },
                             icon: const Icon(Icons.cancel_outlined),
                           ),
                         ),
                       ),
                       const SizedBox(
                         height: 16,
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         children: [
                           ElevatedButton(
                             onPressed:(){},
                             child: const Text('Save'),
                           ),
                         ],
                       ),   
            ],
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