/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/


module anchovy.gui.behaviors.listbehavior;

import std.stdio;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;
import anchovy.gui.interfaces.ilayout;

class ViewportLayout : ILayout
{
	/// Called by widget when MinimizeLayout event occurs.
	void minimize(Widget root)
	{
		Widget[] children = root.getPropertyAs!("children", Widget[]);

		if (children.length > 0)
		{
			ivec2 childSize = children[0].getPropertyAs!("prefSize", ivec2);

			root.setProperty!("size")(ivec2(childSize.x, 0));
		}
	}

	/// Called by widget when ExpandLayout event occurs.
	void expand(Widget root)
	{
		Widget[] children = root.getPropertyAs!("children", Widget[]);

		if (children.length > 0)
		{
			ivec2 childSize = children[0].getPropertyAs!("prefSize", ivec2);
			ivec2 childMinSize = children[0].getPropertyAs!("minSize", ivec2);
			childSize = ivec2(max(childSize.x, childMinSize.x), max(childSize.y, childMinSize.y));

			children[0].setProperty!("size")(childSize);
		}
	}

	/// Called by container to update its children positions and sizes.
	void onContainerResized(Widget root, ivec2 oldSize, ivec2 newSize)
	{
		
	}
}

class ListBehavior : IWidgetBehavior
{
protected:

	Widget _viewport;
	Widget _canvas;
	Widget _vertscroll;

public:

	override void attachTo(Widget widget)
	{
		_viewport = widget["subwidgets"].get!(Widget[string]).get("viewport", null);
		_canvas = widget["subwidgets"].get!(Widget[string]).get("canvas", null);
		_vertscroll = widget["subwidgets"].get!(Widget[string]).get("vert-scroll", null);

		if (_viewport && _canvas && _vertscroll)
		{
			_viewport.setProperty!("layout", ILayout)(new ViewportLayout);
			_viewport.property("size").valueChanged.connect(&updateSize);
			_canvas.property("size").valueChanged.connect(&updateSize);
		}
	}

	void updateSize(FlexibleObject widget, Variant position)
	{
		_vertscroll.setProperty!"sliderSize"(scrollSize());
	}

	double scrollSize()
	{
		ivec2 viewSize = _viewport.getPropertyAs!("size", ivec2);
		ivec2 canvasSize = _canvas.getPropertyAs!("size", ivec2);

		return cast(double)viewSize.y / canvasSize.y;
	}
}