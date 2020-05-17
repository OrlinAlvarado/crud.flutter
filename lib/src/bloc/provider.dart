import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/login_bloc.dart';
export 'package:formvalidation/src/bloc/login_bloc.dart';

//Clase para manejar la informacion de la aplicacion como Bloc
//Para que este disponible en toda la aplicacion.
class Provider extends InheritedWidget{

  //Para el patron singleton
  static Provider _instancia;

  //Para que se cree la instancia solo si no existe
  factory Provider( { Key key, Widget child}){
    if( _instancia == null){
      _instancia = new Provider._internal(key:key, child:child);
    }

    return _instancia;

  }

  //Constructor estatico, para evitar que se haga instancia desde afuera.
  Provider._internal( { Key key, Widget child })
  : super(key: key, child: child);
  //Unica instancia del Bloc
  final loginBloc =  LoginBloc();

  

  //Para Notificar a todos los Widget que si hay cambios
  //para todos los hijos
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;


  static LoginBloc of ( BuildContext context ){
     return context.dependOnInheritedWidgetOfExactType<Provider>().loginBloc;
  }


}


