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
	override void attachTo(Widget widget)
	{
		widget.addEventHandler(&pointerMoved);
		widget.addEventHandler(&pointerPressed);
		widget.addEventHandler(&pointerReleased);

		widget.setProperty!"isFocusable"(true);
	}

	bool pointerMoved(Widget widget, PointerMoveEvent event)
	{
		if (event.context.pressedWidget is widget )
		{
			widget["position"] = event.delta + widget["position"].get!ivec2;
		}
		

		return true;
	}

	bool pointerPressed(Widget widget, PointerPressEvent event)
	{
		if (event.button == PointerButton.PB_LEFT)
		{
			return true;
		}

		return false;
	}

	bool pointerReleased(Widget widget, PointerReleaseEvent event)
	{
		return true;
	}

}