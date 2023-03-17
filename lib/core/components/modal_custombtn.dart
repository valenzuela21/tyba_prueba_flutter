import 'package:flutter/material.dart';
import 'package:marvel_bloc/core/constants/app_constants.dart';

import 'button_related/button_style.dart';
class ModalCustomButton extends StatelessWidget {

  Widget children;

  ModalCustomButton({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {

   _handleClickMe(){
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Filtrar'),
            content: children,
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Cerrar', style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return TextButton(
      style: buttonStyle(context),
      onPressed: () => _handleClickMe(),
      child: const Text(AppConstants.showDialog),
    );

  }

}

