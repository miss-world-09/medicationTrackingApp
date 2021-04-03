import 'package:flutter/material.dart';
import '../../../../core/base/viewmodel/base_viewmodel.dart';
import 'package:mobx/mobx.dart';

part 'verify_mail_code_viewmodel.g.dart';

class VerifyMailCodeViewModel = _VerifyMailCodeViewModelBase with _$VerifyMailCodeViewModel;

abstract class _VerifyMailCodeViewModelBase with Store, BaseViewModel {
  void setContext(BuildContext context) => this.context = context;
  void init() {}
}