import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:inventory/widgets/loading.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '', email = '', password = '';
  bool loading = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Background image
          Image.asset(
            "lib/assets/background.png",
            fit: BoxFit.cover,
          ),

          // 🔹 Overlay to improve readability
          Container(
            color: Colors.black.withOpacity(0.2),
          ),

          // 🔹 Form or loading
          loading
              ? const Loading()
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Create your account!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(221, 34, 33, 33),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🔹 Username
                          TextFormField(
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person, color: Colors.black87),
                              labelText: 'Username',
                              labelStyle: const TextStyle(color: Colors.black87),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black54, width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 50, 107, 232), width: 1.5),
                              ),
                            ),
                            validator: (v) => v != null && v.isNotEmpty ? null : 'Enter a username',
                            onSaved: (v) => username = v!.trim(),
                          ),
                          const SizedBox(height: 16),

                          // 🔹 Email
                          TextFormField(
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email, color: Colors.black87),
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.black87),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black54, width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 50, 107, 232), width: 1.5),
                              ),
                            ),
                            validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
                            onSaved: (v) => email = v!.trim(),
                          ),
                          const SizedBox(height: 16),

                          // 🔹 Password
                          TextFormField(
                            style: const TextStyle(color: Colors.black87),
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock, color: Colors.black87),
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.black87),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black54, width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 50, 107, 232),  width: 1.5),
                              ),
                            ),
                            validator: (v) => v != null && v.length >= 6 ? null : 'Password must be at least 6 characters',
                            onSaved: (v) => password = v!.trim(),
                          ),
                          const SizedBox(height: 20),

                          // 🔹 Register Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: const Color.fromARGB(255, 14, 34, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  setState(() => loading = true);

                                  await auth.register(username, email, password);

                                  setState(() => loading = false);

                                  if (auth.error != null) {
                                    setState(() => error = auth.error!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(auth.error!)),
                                    );
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                "Signup",
                                style: TextStyle(
                                  fontSize: 19,
                                  color: Color.fromARGB(255, 228, 228, 228),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🔹 Bottom Sign In
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(color: Colors.black87),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                ),
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(221, 21, 21, 255),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
