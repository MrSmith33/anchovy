/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/


module anchovy.gui.behaviors.listbehavior;

import std.stdio;
import std.math : ceil;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;
import anchovy.gui.interfaces.ilayout;
import anchovy.gui.databinding.list;

class ViewportLayout : ILayout
{
	/// Called by widget when MinimizeLayout event occurs.
	void minimize(Widget root)
	{
		Widget[] children = root.getPropertyAs!("children", Widget[]);

		if (children.length > 0)
		{
			ivec2 childSize = children[0].getPropertyAs!("prefSize", ivec2);

			root.setProperty!("prefSize")(ivec2(childSize.x, 0));
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

class BasicListBehavior : IWidgetBehavior
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
	}
}

class WidgetListBehavior : BasicListBehavior
{
	override void attachTo(Widget widget)
	{
		super.attachTo(widget);

		if (_viewport && _canvas && _vertscroll)
		{
			_viewport.setProperty!("layout", ILayout)(new ViewportLayout);
			_viewport.property("size").valueChanged.connect(&updateSize);
			_canvas.property("size").valueChanged.connect(&updateSize);
			_vertscroll.property("sliderPos").valueChanged.connect(&sliderMoved);

			sliderMoved(null, _vertscroll.property("sliderPos").value);
		}
	}

	void sliderMoved(FlexibleObject widget, Variant position)
	{
		ivec2 viewSize = _viewport.getPropertyAs!("size", ivec2);
		ivec2 canvasSize = _canvas.getPropertyAs!("size", ivec2);

		int avalPos = canvasSize.y - viewSize.y;
		int newCanvasPos = avalPos < 0 ? 0 : -cast(int)(position.get!double * avalPos); 

		_canvas.setProperty!("position")(ivec2(0, newCanvasPos));
	}

	void updateSize(FlexibleObject widget, Variant size)
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


class StringListBehavior : BasicListBehavior
{
	alias StringList = List!dstring;

protected:
	StringList _list;
	size_t itemsPerPage; // Number of items that are visible in viewport.
	size_t firstVisible;

	uint _itemHeight = 16;
	size_t numLabels = 0;
	GuiContext context;

public:

	override void attachPropertiesTo(Widget widget)
	{
		widget.property("list").valueChanged.connect(&listAssigned);
	}

	void listAssigned(FlexibleObject widget, Variant newList)
	{
		if (newList.type !is typeid(StringList)) return;

		auto oldList = _list;

		_list = newList.get!StringList;

		if (_list is null && oldList !is null)
		{
			oldList.listChangedSignal.disconnectAll();
		}

		refreshItems();

		if (_list is null) return;

		_list.listChangedSignal.connect((){refreshItems();});
	}

	override void attachTo(Widget widget)
	{
		super.attachTo(widget);

		//writeln(_viewport , _canvas , _vertscroll);

		if (_viewport && _canvas && _vertscroll)
		{
			context = _viewport.getPropertyAs!("context", GuiContext);

			_viewport.setProperty!("layout", ILayout)(new ViewportLayout);
			_viewport.property("size").valueChanged.connect(&updateSize);
			_vertscroll.property("sliderPos").valueChanged.connect(&sliderMoved);

			sliderMoved(null, _vertscroll.property("sliderPos").value);

			refreshItems();
		}
	}

	void refreshPageSize()
	{
		if (_list is null)
		{
			itemsPerPage = 0;
		}

		ivec2 viewSize = _viewport.getPropertyAs!("size", ivec2);

		itemsPerPage = cast(size_t)(cast(real)viewSize.y / _itemHeight).ceil;

		if (itemsPerPage > numLabels)
		{
			foreach (_; 0..itemsPerPage - numLabels)
			{
				context.createWidget("label", _canvas);
			}
		}
		else if (itemsPerPage < numLabels)
		{
			Widget[] labels = _canvas.getPropertyAs!("children", Widget[]);

			labels.length = itemsPerPage;

			_canvas.setProperty!("position")(ivec2(0, 0));
		}

		numLabels = itemsPerPage;

		if (_list is null) return;
		
		double sliderSize = cast(double)itemsPerPage / _list.length;
		_vertscroll.setProperty!("sliderSize", double)(sliderSize);
	}

	void refreshPagePos()
	{
		if (_list is null) return;

		double sliderPos = _vertscroll.getPropertyAs!("sliderPos", double);

		ptrdiff_t visible = cast(ptrdiff_t)(sliderPos * (_list.length - itemsPerPage));
		firstVisible = visible < 0 ? 0 : visible;

		if (_list.length > itemsPerPage)
		{
			ivec2 viewSize = _viewport.getPropertyAs!("size", ivec2);
			long canvasSize = _list.length * _itemHeight;
			long viewPos = cast(long)(sliderPos * cast(double)(canvasSize - viewSize.y));

			_canvas.setProperty!("position")(ivec2(0, cast(int)(firstVisible*_itemHeight - viewPos)));
		}
		else
		{
			_canvas.setProperty!("position")(ivec2(0, 0));
		}
	}

	void addItems()
	{
		if (_list is null) return;

		size_t listLength = _list.length;
		size_t itemsToShow = itemsPerPage < listLength ? itemsPerPage : listLength;

		Widget[] labels = _canvas.getPropertyAs!("children", Widget[]);

		foreach(itemIndex; firstVisible..firstVisible + itemsToShow)
		{
			labels[itemIndex - firstVisible].setProperty!"text"(_list[itemIndex]);
		}
	}

	void refreshItems()
	{
		refreshPageSize();
		refreshPagePos();
		addItems();
	}

	void sliderMoved(FlexibleObject widget, Variant position)
	{
		if (_list is null) return;

		ivec2 viewSize = _viewport.getPropertyAs!("size", ivec2);

		long avalPos = _list.length * _itemHeight - viewSize.y;
		
		refreshItems();
	}

	void updateSize(FlexibleObject widget, Variant size)
	{
		refreshItems();
	}

	double scrollSize()
	{
		ivec2 viewSize = _viewport.getPropertyAs!("size", ivec2);

		return cast(double)viewSize.y / _list.length * _itemHeight;
	}
}