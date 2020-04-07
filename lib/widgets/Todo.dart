import 'package:flutter/material.dart';
import 'package:schedular/bloc/TodoBloc.dart';
import 'package:schedular/bloc/TodoListBloc.dart';
import 'package:schedular/utils/Provider.dart';
import 'package:schedular/widgets/CCheckBox.dart';

class Todo extends StatefulWidget {
  final TodoBloc todoBloc;
  Todo(this.todoBloc, {Key key}) : super(key: key);

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  TextEditingController _textController;
  bool _isBeingEdited = false;

  _TodoState() {
    this._textController = new TextEditingController();
  }

  Widget renderButtonBar(BuildContext context) {
    final TodoListBloc _todoListBloc = Provider.of<TodoListBloc>(context);
    return ButtonBarTheme(
      // make buttons use the appropriate styles for cards
      data: ButtonBarThemeData(),
      child: ButtonBar(
        children: <Widget>[
          FlatButton(
            textColor: Color(0xff48c6ef),
            child: const Text('DELETE'),
            onPressed: () {
              _todoListBloc.deleteTodo(widget.todoBloc.id);
            },
          ),
          FlatButton(
            textColor: Color(0xff48c6ef),
            child: Text(this._isBeingEdited ? 'SAVE' : 'EDIT'),
            onPressed: () {
              if (this._isBeingEdited == true &&
                  this._textController.text != '') {
                widget.todoBloc.updateContent(this._textController.text);
              }
              setState(() {
                this._isBeingEdited = !this._isBeingEdited;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget renderTextField() {
    return Expanded(
      child: StreamBuilder<String>(
          stream: widget.todoBloc.contentObservable,
          initialData: "Click on Edit",
          builder: (context, AsyncSnapshot<String> snapshot) {
            this._textController.text = snapshot.data;
            return (this._isBeingEdited
                ? TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Write down a quick todo...',
                    ),
                    controller: _textController,
                  )
                : Text(
                    snapshot.data == '' ? 'Click on edit...' : snapshot.data,
                    style: Theme.of(context).textTheme.body2,
                  ));
          }),
    );
  }

  Widget renderCheckBox() {
    return StreamBuilder<bool>(
        stream: widget.todoBloc.isCheckedObservable,
        initialData: false,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return CCheckBox(
            value: snapshot.data,
            onTap: () {
              widget.todoBloc.updateCheckedState(!snapshot.data);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              this.renderCheckBox(),
              this.renderTextField(),
            ],
          ),
          this.renderButtonBar(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.clear();
    //_textController.dispose();
    super.dispose();
  }
}
