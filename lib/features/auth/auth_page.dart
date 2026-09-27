import 'package:flutter/material.dart';

import '../../data/cloud/cloudbase_gateway.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.gateway,
    required this.onAuthenticated,
  });
  final CloudGateway gateway;
  final ValueChanged<String> onAuthenticated;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  bool _register = false;
  bool _awaitingCode = false;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final email = _email.text.trim();
    final password = _password.text;
    if (!_awaitingCode && (!email.contains('@') || password.length < 8)) {
      setState(() => _message = '请输入有效邮箱和至少 8 位密码');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final CloudResult<String> result;
      if (_awaitingCode) {
        result = await widget.gateway.verifyRegistration(_code.text.trim());
      } else if (_register) {
        result = await widget.gateway.signUp(email, password);
      } else {
        result = await widget.gateway.signIn(email, password);
      }
      if (!mounted) return;
      if (result.isSuccess && result.data != null) {
        if (result.data == 'verificationRequired') {
          setState(() {
            _awaitingCode = true;
            _message = '请查看邮箱并填写验证码';
          });
        } else {
          widget.onAuthenticated(result.data!);
        }
      } else {
        setState(
          () => _message = switch (result.status) {
            CloudStatus.offline => '网络暂时不可用',
            _ => '登录或验证失败，请检查输入',
          },
        );
      }
    } catch (_) {
      if (mounted) setState(() => _message = '网络暂时不可用');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Timer')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _awaitingCode ? '验证邮箱' : (_register ? '创建账号' : '登录'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              if (!_awaitingCode) ...[
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '邮箱'),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '密码'),
                ),
              ] else
                TextField(
                  controller: _code,
                  decoration: const InputDecoration(labelText: '邮箱验证码'),
                ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(_message!),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(_awaitingCode ? '验证' : (_register ? '注册' : '登录')),
              ),
              if (!_awaitingCode)
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _register = !_register),
                  child: Text(_register ? '已有账号？登录' : '没有账号？注册'),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
