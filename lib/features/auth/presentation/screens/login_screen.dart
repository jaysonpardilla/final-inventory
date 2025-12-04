import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:inventory/widgets/loading.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  bool loading = false;
  String error = '';
  bool _obscurePassword = true; // 🔹 For toggling password visibility

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {}); // Rebuild screen
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🔹 Background image
            Image.asset(
              "lib/assets/background.png",
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.1),
            ),

            // 🔹 Transparent form
            loading
                ? const Loading()
                : Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Welcome back!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🔹 Email Field
                            TextFormField(
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email, color: Colors.black87),
                                labelText: 'Email',
                                labelStyle: const TextStyle(color: Colors.black87),
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.black54,
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 50, 107, 232),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (v) => v != null && v.contains('@')
                                  ? null
                                  : 'Enter valid email',
                              onSaved: (v) => email = v!.trim(),
                            ),
                            const SizedBox(height: 16),

                            // 🔹 Password Field with eye icon
                            TextFormField(
                              style: const TextStyle(color: Colors.black87),
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock, color: Colors.black87),
                                suffixIcon: IconButton(
                                  iconSize: 18,
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                labelText: 'Password',
                                labelStyle: const TextStyle(color: Colors.black87),
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 37, 37, 37),
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 50, 107, 232),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onSaved: (v) => password = v!.trim(),
                            ),

                            const SizedBox(height: 20),

                            // 🔹 Login button
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
                                  _formKey.currentState!.save();
                                  setState(() => loading = true);

                                  await auth.signIn(email, password);

                                  setState(() => loading = false);

                                  if (auth.error != null) {
                                    setState(() => error = auth.error!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(auth.error!)),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 19,
                                    color: Color.fromARGB(255, 228, 228, 228),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 🔹 Bottom Sign Up
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterScreen()),
                                  ),
                                  child: const Text(
                                    "Sign Up",
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
      ),
    );
  }
}
