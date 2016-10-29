part of phi_cmux;

class WindowManager {
  Window _window;
  List<WindowTree> _trees;
  int _active;

  WindowManager() {
    this._window = new Window.init();
    this._trees = [new WindowTree(this)];
    this._active = 0;
  }

  int get activeTree => _active;

  set activeTree(int index) {
    if (index >= 0 && index < _trees.length)
      _active = index;
    throw new IndexError(index, this);
  }

  int get treeCount => _trees.length;

  operator [](int index) => _trees[index];
}

class WindowTree {
  WindowManager _parent;
  TreeElement _root;

  WindowTree(this._parent) {
    this._root = new TreeElement(new WindowNode(0, 0, _parent._window.width, _parent._window.height, _parent._window));
  }

  TreeElement get root => _root;
}

class TreeElement {
  dynamic _node;

  TreeElement(this._node);

  bool get isWindow => _node is WindowNode;

  Window get window => _node;

  WindowNode split(NodeOrientation orientation, [bool prepend = false]) {
    if (prepend) {
      _node = _node.splitPrepend(orientation, (r) => new WindowNode.fromRegion(r));
      return _node.child1;
    }
    _node = _node.splitPrepend(orientation, (r) => new WindowNode.fromRegion(r));
    return _node.child2;
  }

  bool get isSplit => _node is BiNode;

  TreeElement get child1 => new TreeElement(_node.child1);

  TreeElement get child2 => new TreeElement(_node.child2);
}

enum NodeOrientation {
  HORIZONTAL, VERTICAL
}