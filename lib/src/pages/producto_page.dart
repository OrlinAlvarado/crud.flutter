import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:formvalidation/src/models/producto_model.dart';
import 'package:formvalidation/src/providers/productos_provider.dart';
import 'package:formvalidation/src/utils/utils.dart' as utils;
class ProductoPage extends StatefulWidget {
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  final formKey     = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final productoProvider = new ProductosProvider();
  ProductoModel producto = new ProductoModel();
  bool _guardando = false;
  File foto;

  

  @override
  Widget build(BuildContext context) {
    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;

    if( prodData != null)  {
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon( Icons.photo_size_select_actual ),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon( Icons.camera_alt ),
            onPressed: _tomarFoto,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                SizedBox(
                  height: 20.0,
                ),
                _crearBoton()
              ],
            ),
          ),
        ),
      ),
    );

     
  }

  Widget _crearNombre(){
       return TextFormField(
         initialValue: producto.titulo,
         textCapitalization: TextCapitalization.sentences,
         decoration: InputDecoration(
           labelText: 'Producto'
         ),
         onSaved: (value) => producto.titulo = value,
         validator: (value){
           if( value.length < 3){
             return 'Ingrese el nombre del producto';
           } else{
             return null;
           }
         },
       );
     }

  Widget _crearPrecio(){
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions( decimal: true),
      decoration: InputDecoration(
        labelText: 'Precio'
      ),
      onSaved: (value) => producto.valor = double.parse(value),
      validator: (value){
        if(!utils.isNumeric(value)){
          return 'Ingrese un numero';
        } else {
          return null;
        }
      },
    );
  }

  Widget _crearDisponible(){
    return SwitchListTile(
      value: producto.disponible,
      title: Text('Disponible'),
      activeColor: Colors.deepPurple,
      onChanged: (value) => setState((){
        producto.disponible = value;
      }),
    );
  }
  Widget _crearBoton(){
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0)
      ),
      label: Text('Guardar'),
      icon: Icon( Icons.save ),
      color: Colors.deepPurple,
      textColor: Colors.white,
      onPressed: (_guardando) ? null : _submit,
    );
  }

  void _submit() async{
    if(!formKey.currentState.validate()) return;

    formKey.currentState.save();

    setState(() {
      _guardando = true;
    });

    if(foto != null){
      producto.fotoUrl = await productoProvider.subirImage(foto);
    }

    if( producto.id == null){
      final id = await productoProvider.crearProducto(producto);
      producto.id = id;
    } else {
      productoProvider.editarProducto(producto);
    }

    setState(() {
      _guardando = false;
    });
    
    mostrarSackbar('Registro guardado');
  }

  void mostrarSackbar(String mensaje){
    final snackbar = new SnackBar(
      content: Text(mensaje),
      duration: Duration( milliseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);

  }

  _mostrarFoto(){
    if( producto.fotoUrl != null){
      return FadeInImage(
        image: NetworkImage( producto.fotoUrl ),
        placeholder: AssetImage('assets/jar-loading.gif'),
        height: 300,
        fit: BoxFit.contain,
      );
    } else {
      if ( foto != null){
        return Image.file(
          foto,
          fit: BoxFit.cover,
          height: 300.0,
        );
      }
      
      return Image(
        image: AssetImage('assets/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }

  }
  _seleccionarFoto() async {
    
    _procesarFoto(ImageSource.gallery);
  }

  _tomarFoto() async{
    _procesarFoto(ImageSource.camera);
  }

  _procesarFoto(ImageSource source ) async {
    foto = await ImagePicker.pickImage(
      source: source
    );

    if( foto != null){
      producto.fotoUrl = null;
    }

    setState(() {});

  }


}