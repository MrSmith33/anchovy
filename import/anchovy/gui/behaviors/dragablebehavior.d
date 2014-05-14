/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/


module anchovy.gui.behaviors.dragablebehavior;

import std.algorithm;
import std.stdio;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

class DragableBehavior : IWidgetBehavior
{
protected:
	ivec2 _dragPosition;
	Widget _widget;

public:

	override void attachTo(Widget widget)
	{
		_widget = widget;
		widget.addEventHandler(&pointerMoved);
		widget.addEventHandler(&pointerPressed);
		widget.addEventHandler(&pointerReleased);

		widget.setProperty!"isFocusable"(true);
	}

	bool pointerMoved(Widget widget, PointerMoveEvent event)
	{
		if (event.context.eventDispatcher.pressedWidget is widget)
		{
			ivec2 deltaPos = event.pointerPosition - widget.getPropertyAs!("staticPosition", ivec2) - _dragPosition;
			
			auto dragEvent = new DragEvent(event.pointerPosition, deltaPos, _widget);
			dragEvent.context = event.context;
			_widget.handleEvent(dragEvent);

			return true;
		}
		return false;
	}

	bool pointerPressed(Widget widget, PointerPressEvent event)
	{
		if (event.button == PointerButton.PB_LEFT && event.bubbling)
		{
			_dragPosition = event.pointerPosition - widget.getPropertyAs!("staticPosition", ivec2);

			return true;
		}

		return false;
	}

	bool pointerReleased(Widget widget, PointerReleaseEvent event)
	{
		if (event.sinking) return false;
		return true;
	}
}