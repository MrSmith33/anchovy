/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/


module anchovy.gui.behaviors.sliderbehavior;

import std.algorithm;
import std.stdio;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

class SliderBehavior : IWidgetBehavior
{
protected:
	ivec2 _dragPosition;

public:

	override void attachTo(Widget widget)
	{
		widget.addEventHandler(&pointerMoved);
		widget.addEventHandler(&pointerPressed);
		widget.addEventHandler(&pointerReleased);

		widget.setProperty!"isFocusable"(true);
	}

	bool pointerMoved(Widget widget, PointerMoveEvent event)
	{
		if (event.context.eventDispatcher.pressedWidget is widget )
		{
			ivec2 deltaPos = event.pointerPosition - widget.getPropertyAs!("staticPosition", ivec2) - _dragPosition;

			widget["position"] = widget.getPropertyAs!("position", ivec2) + deltaPos;
		}
		
		return true;
	}

	bool pointerPressed(Widget widget, PointerPressEvent event)
	{
		if (event.button == PointerButton.PB_LEFT)
		{
			_dragPosition = event.pointerPosition - widget.getPropertyAs!("staticPosition", ivec2);

			return true;
		}

		return false;
	}

	bool pointerReleased(Widget widget, PointerReleaseEvent event)
	{
		return true;
	}
}