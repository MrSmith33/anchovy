/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.checkbehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

//version = Check_debug;

class CheckBehavior : IWidgetBehavior
{
public:

	override void attachTo(Widget widget)
	{
		widget.addEventHandler(&onClick);
		widget.addEventHandler(&pointerPressed);
		widget.addEventHandler(&pointerReleased);
		widget.addEventHandler(&pointerMoved);
		widget.addEventHandler(&pointerEntered);
		widget.addEventHandler(&pointerLeaved);

		widget.setProperty!"isFocusable"(true);
		widget.setProperty!"isChecked"(false);
		widget.setProperty!"isHovered"(false);
		widget.setProperty!"isPressed"(false);
		widget.setProperty!"style"("check");
	}

	bool onClick(Widget widget, PointerClickEvent event)
	{
		widget.setProperty!"isChecked"(!widget.getPropertyAs!("isChecked", bool));

		updateState(widget);

		version(Check_debug) writeln("onClick");

		return true;
	}

	bool pointerPressed(Widget widget, PointerPressEvent event)
	{
		if (event.button == PointerButton.PB_LEFT)
		{
			widget.setProperty!"isPressed"(true);
		}

		updateState(widget);

		version(Check_debug) writeln("pointerPressed");

		return true;
	}
	
	bool pointerReleased(Widget widget, PointerReleaseEvent event)
	{
		if (event.button == PointerButton.PB_LEFT)
		{
			widget.setProperty!"isHovered"(true);
			widget.setProperty!"isPressed"(false);
		}

		updateState(widget);

		version(Check_debug) writeln("pointerReleased");

		return true;
	}

	bool pointerMoved(Widget widget, PointerMoveEvent event)
	{
		return true;
	}

	bool pointerEntered(Widget widget, PointerEnterEvent event)
	{
		if (event.context.pressedWidget is this)
		{
			widget.setProperty!"isPressed"(true);
		}
		else
		{
			widget.setProperty!"isHovered"(true);
		}

		updateState(widget);

		version(Check_debug) writeln("pointerEntered");

		return true;
	}
	
	bool pointerLeaved(Widget widget, PointerLeaveEvent event)
	{
		widget.setProperty!"isHovered"(false);
		
		updateState(widget);

		version(Check_debug) writeln("pointerLeaved");

		return true;
	}

	// normal_unchecked == normal
	static const string[6] stateStrings = ["normal", "normal_checked", "hovered_unchecked", "hovered_checked", "pressed_unchecked", "pressed_checked"];
	
	static void updateState(Widget widget)
	{
		uint checked = widget.getPropertyAs!("isChecked", bool) ? 1 : 0;
		uint hovered = widget.getPropertyAs!("isHovered", bool) ? 2 : 0;
		bool pressed = widget.getPropertyAs!("isPressed", bool);
		if (pressed) hovered = 4;

		version(Check_debug) writefln("checked %s hovered %s pressed %s %s",checked , hovered, pressed, stateStrings[checked | hovered]);

		widget.setProperty!"state"(stateStrings[checked | hovered]);
	}
}