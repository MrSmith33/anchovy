/**
Copyright: Copyright (c) 2013 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.framebehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

// version = Button_debug;

class FrameBehavior : IWidgetBehavior
{
protected:
	Widget _header;
	Widget _frame;

public:
	override void attachTo(Widget widget)
	{
		_frame = widget;
		_header = widget["subwidgets"].get!(Widget[string]).get("header", null);

		if (_header && _header.getWidgetBehavior!DragableBehavior)
		{
			_header.addEventHandler(&handleHeaderDrag);
		}
	}

	bool handleHeaderDrag(Widget widget, DragEvent event)
	{
		_frame["position"] = _frame.getPropertyAs!("position", ivec2) + event.delta;
		return true;
	}
}