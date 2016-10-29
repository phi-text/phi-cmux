import 'package:curses_abst/curses_abst.dart';

import 'package:phi_cmux/phi_cmux.dart';
import 'package:phi_cmux/src/region.dart';

abstract class TreeNode {
  bool get hasChildren;

  TreeNode get child1;

  TreeNode get child2;

  NodeOrientation get orientation;
}

class WindowNode extends WindowRegion implements TreeNode {
  WindowNode(int x, int y, int width, int height, Window window) : super(x, y, width, height, window);

  WindowNode.fromRegion(WindowRegion region) : super.clone(region);

  @override
  bool get hasChildren => false;

  @override
  TreeNode get child1 => null;

  @override
  TreeNode get child2 => null;

  @override
  NodeOrientation get orientation => null;

  BiNode splitPrepend(NodeOrientation orientation, Function gen) {
    WindowRegion regionCopy = new WindowRegion.clone(this);
    WindowRegion newRegion = new WindowRegion.clone(this);
    switch (orientation) {
      case NodeOrientation.HORIZONTAL:
        newRegion.resize(width ~/ 2, height);
        translate(newRegion.width, 0);
        break;
      case NodeOrientation.VERTICAL:
        newRegion.resize(width, height ~/ 2);
        translate(0, newRegion.height);
        break;
    }
    resize(regionCopy.width - newRegion.width, regionCopy.height - newRegion.height);
    return new BiNode(this, gen(newRegion), orientation, regionCopy);
  }

  BiNode splitAppend(NodeOrientation orientation, Function gen) {
    WindowRegion regionCopy = new WindowRegion.clone(this);
    WindowRegion newRegion = new WindowRegion.clone(this);
    switch (orientation) {
      case NodeOrientation.HORIZONTAL:
        resize(width ~/ 2, height);
        newRegion.translate(width, 0);
        break;
      case NodeOrientation.VERTICAL:
        resize(width, height ~/ 2);
        newRegion.translate(0, height);
        break;
    }
    newRegion.resize(regionCopy.width - this.width, regionCopy.height - this.height);
    return new BiNode(this, gen(newRegion), orientation, regionCopy);
  }
}

class BiNode implements TreeNode {
  TreeNode _child1, _child2;
  NodeOrientation _orientation;
  WindowRegion _region;

  BiNode(this._child1, this._child2, this._orientation, this._region);

  @override
  bool get hasChildren => true;

  @override
  TreeNode get child1 => _child1;

  @override
  TreeNode get child2 => _child2;

  @override
  NodeOrientation get orientation => _orientation;
}