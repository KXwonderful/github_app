import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_app/commom/funs.dart';
import 'package:github_app/commom/git_api.dart';
import 'package:github_app/commom/global.dart';
import 'package:github_app/i10n/localization_intl.dart';
import 'package:github_app/models/index.dart';
import 'package:github_app/states/profile_change_notifier.dart';
import 'package:provider/provider.dart';

class LoginRoute extends StatefulWidget {
  @override
  _LoginRouteState createState() {
    return new _LoginRouteState();
  }
}

class _LoginRouteState extends State<LoginRoute> {
  TextEditingController _uController = new TextEditingController();
  TextEditingController _pController = new TextEditingController();
  bool pShow = false;
  GlobalKey _formKey = new GlobalKey();
  bool _nameAutoFocus = true;

  @override
  void initState() {
    // 自动填充上次登录的用户名，填充后将焦点定位到密码输入框
    _uController.text = Global.profile.lastLogin;
    if (_uController.text != null) {
      _nameAutoFocus = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var gm = GmLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(gm.login),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            autovalidate: true,
            child: Column(
              children: <Widget>[
                TextFormField(
                  autofocus: _nameAutoFocus,
                  controller: _uController,
                  decoration: InputDecoration(
                      labelText: gm.userName,
                      hintText: gm.userName,
                      prefixIcon: Icon(Icons.person)),
                  // 检查不为空
                  validator: (v) {
                    return v.trim().isNotEmpty
                        ? null
                        : gm.userNameOrPasswordWrong;
                  },
                ),
                TextFormField(
                  controller: _pController,
                  autofocus: !_nameAutoFocus,
                  decoration: InputDecoration(
                      labelText: gm.password,
                      hintText: gm.password,
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            pShow ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            pShow = !pShow;
                          });
                        },
                      )),
                  obscureText: !pShow,
                  //校验密码（不能为空）
                  validator: (v) {
                    return v.trim().isNotEmpty ? null : gm.passwordRequired;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.expand(height: 55),
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: _onLogin,
                      textColor: Colors.white,
                      child: Text(gm.login),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  void _onLogin() async {
    if ((_formKey.currentState as FormState).validate()) {
      showLoading(context);
      User user;
      try {
        user = await Git(context).login(_uController.text, _pController.text);
        // 因为登录页返回后，首页会build，所以我们传false，更新user后不触发更新
        Provider.of<UserModel>(context, listen: false).user = user;
      } catch (e) {
        if (e.response?.statusCode == 401) {
          showToast(GmLocalizations.of(context).userNameOrPasswordWrong);
        } else {
          showToast(e.toString());
        }
      } finally {
        // 隐藏loading框
        Navigator.of(context).pop();
      }

      if (user != null) {
        // 返回
        Navigator.of(context).pop();
      }
    }
  }
}
