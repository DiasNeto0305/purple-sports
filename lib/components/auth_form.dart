import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<AuthForm> with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  bool _isLogin() => _authMode == AuthMode.Login;
  // bool _isSignup() => _authMode == AuthMode.Signup;

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.Signup;
        _controller.forward();
      } else {
        _authMode = AuthMode.Login;
        _controller.reverse();
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ocorreu um erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar'),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState?.save();
    Auth auth = Provider.of(context, listen: false);
    try {
      if (_isLogin()) {
        // Login
        await auth.login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        // Cadastro
        await auth.signup(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
        padding: EdgeInsets.all(16),
        width: deviceSize.width * 0.90,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  suffixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (_email) {
                  final email = _email ?? '';
                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'Informe um email válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: Icon(Icons.vpn_key),
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                controller: _passwordController,
                onSaved: (password) => _authData['password'] = password ?? '',
                validator: (_password) {
                  final password = _password ?? '';
                  if (password.isEmpty || password.length < 5) {
                    return 'Informe uma senha válida';
                  }
                  return null;
                },
              ),
              AnimatedContainer(
                constraints: BoxConstraints(
                    minHeight: _isLogin() ? 0 : 60,
                    maxHeight: _isLogin() ? 0 : 120),
                duration: Duration(milliseconds: 300),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        suffixIcon: Icon(Icons.vpn_key),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: _isLogin()
                          ? null
                          : (_password) {
                              final password = _password ?? '';
                              if (password != _passwordController.text) {
                                return 'Senhas informadas não estão iguais';
                              }
                              return null;
                            },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 80,
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : Container(
                    width: deviceSize.width * 0.9,
                    height: 40,
                    child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                            _authMode == AuthMode.Login ? 'Entrar' : 'Registrar'),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 8)),
                      ),
                  ),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                    _isLogin() ? 'Deseja registrar?' : 'Já possui cadastro?'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
