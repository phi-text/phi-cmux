import 'package:curses_abst/curses_abst.dart';

import 'package:phi_cmux/phi_cmux.dart';
import 'package:phi_cmux/src/region.dart';

abstract class TreeNode {
  TreeNode get parent;

  bool get hasChildren;

  TreeNode get child1;

  TreeNode get child2;

  NodeOrientation get orientation;

  set _parentProp(TreeNode parent);

  void _expand(WindowRegion region);
}

class WindowNode extends WindowRegion implements TreeNode {
  TreeNode _parent;

  WindowNode(int x, int y, int width, int height, Window window, this._parent) : super(x, y, width, height, window);

  WindowNode.fromRegion(WindowRegion region, this._parent) : super.clone(region);

  @override
  TreeNode get parent => _parent;

  @override
  bool get hasChildren => false;

  @override
  TreeNode get child1 => null;

  @override
  TreeNode get child2 => null;

  @override
  NodeOrientation get orientation => null;

  @override
  set _parentProp(TreeNode parent) => _parent = parent;

  @override
  void _expand(WindowRegion region) => fitTo(region);

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
    return new BiNode(this, gen(newRegion), orientation, regionCopy, _parent);
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
    return new BiNode(this, gen(newRegion), orientation, regionCopy, _parent);
  }

  bool destroy() {
    if (parent == null) {
      return false;
    } if (parent is BiNode) {
      BiNode pn = parent, ppn = parent.parent;
      WindowRegion region = ppn != null ? ppn._region : new WindowRegion(0, 0, pn._region.window.width, pn._region.window.height, pn._region.window);
      TreeNode otherChild = pn.child1 == this ? pn.child2 : pn.child1;
      if (ppn != null) {
        if (ppn.child1 == pn)
          ppn._child1 = otherChild;
        else
          ppn._child2 = otherChild;
      }
      otherChild._expand(region);
      return true;
    }
    throw new StateError('Parent of WindowNode cannot be WindowNode!');
  }
}

class BiNode implements TreeNode {
  TreeNode _parent, _child1, _child2;
  NodeOrientation _orientation;
  WindowRegion _region;

  BiNode(this._child1, this._child2, this._orientation, this._region, this._parent) {
    _child1._parentProp = this;
    _child2._parentProp = this;
  }

  @override
  TreeNode get parent => _parent;

  @override
  bool get hasChildren => true;

  @override
  TreeNode get child1 => _child1;

  @override
  TreeNode get child2 => _child2;

  @override
  NodeOrientation get orientation => _orientation;

  @override
  set _parentProp(TreeNode parent) => _parent = parent;

  @override
  void _expand(WindowRegion region) {
    _region = region;
    WindowRegion rg1 = new WindowRegion.clone(region), rg2 = new WindowRegion.clone(region);
    switch (_orientation) {
      case NodeOrientation.HORIZONTAL:
        rg1.resize(rg1.width ~/ 2, rg1.height);
        rg2.resize(rg2.width - rg1.width, rg2.height);
        rg2.translate(rg1.width, 0);
        break;
      case NodeOrientation.VERTICAL:
        rg1.resize(rg1.width, rg1.height ~/ 1);
        rg2.resize(rg2.width, rg2.height - rg1.height);
        rg2.translate(0, rg1.height);
        break;
    }
  }
}