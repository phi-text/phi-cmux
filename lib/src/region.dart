import 'dart:async';

import 'package:curses_abst/curses_abst.dart';

class WindowRegion implements Window {
  int _x, _y;
  int _width, _height;
  final Window _window;
  final Cursor _cursor = new WindowCursor();
  final StreamController<ResizeEvent> _resizeController = new StreamController.broadcast();

  WindowRegion(this._x, this._y, this._width, this._height, this._window);

  WindowRegion.clone(WindowRegion orig) : this(orig._x, orig._y, orig._width, orig._height, orig._window);

  int get width => _width;

  int get height => _height;

  Cursor get cursor => _cursor;

  Cell getCell(int x, int y) => _window.getCell(_x + x, _y + y);

  void write(int x, int y, String text) => _window.write(_x + x, _y + y, text);

  Iterable<Cell> regionOf(int x, int y, int width, int height) => _window.regionOf(_x + x, _y + y, width, height);

  void resize(int x, int y) {
    _resizeController.add(new ResizeEvent(_width, _height, x, y));
    this._width = x;
    this._height = y;
  }

  void clear() => _window.regionOf(_x, _y, _width, _height).forEach((c) => c.clear());

  Stream<ResizeEvent> get resizeEvents => _resizeController.stream;

  void drawBuffer() => _window.drawRegion(_x, _y, _width, _height);

  void drawRegion(int x, int y, int width, int height) => _window.drawRegion(_x + x, _y + y, width, height);

  void translate(int xOff, int yOff) {
    this._x += xOff;
    this._y += yOff;
  }
}

class WindowCursor extends Cursor { }