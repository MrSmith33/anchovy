/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.checkbehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

version = Check_debug;


class CheckBehavior : IWidgetBehavior
{
	bool isHovered;
	bool isPressed;
	Widget _widget;

public:

	override void attachTo(Widget widget)
	{
		version(Check_debug) writeln("attachTo ", widget["name"], " ", widget["type"], " ", widget["isChecked"]);
		_widget = widget;

		widget.addEventHandler(&onClick);
		widget.addEventHandler(&pointerPressed);
		widget.addEventHandler(&pointerReleased);
		widget.addEventHandler(&pointerMoved);
		widget.addEventHandler(&pointerEntered);
		widget.addEventHandler(&pointerLeaved);

		isHovered = false;
		isPressed = false;

		widget.property("isChecked").valueChanged.connect( (FlexibleObject a, Variant b){updateState();} );

		updateState();
	}

	bool onClick(Widget widget, PointerClickEvent event)
	{
		widget.setProperty!"isChecked"(!widget.getPropertyAs!("isChecked", bool));

		version(Check_debug) writeln("onClick");

		return true;
	}

	bool pointerPressed(Widget widget, PointerPressEvent event)
	{
		if (event.button == PointerButton.PB_LEFT)
		{
			isPressed = true;
		}

		updateState();

		version(Check_debug) writeln("pointerPressed");

		return true;
	}
	
	bool pointerReleased(Widget widget, PointerReleaseEvent event)
	{
		if (event.button == PointerButton.PB_LEFT)
		{
			isHovered = true;
			isPressed = false;
		}

		updateState();
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
			isPressed = true;
			version(Check_debug) writeln("pressed");
		}
		else
		{
			isHovered = true;
			version(Check_debug) writeln("pointerEntered hovered");
		}

		updateState();
		return true;
	}
	
	bool pointerLeaved(Widget widget, PointerLeaveEvent event)
	{
		isHovered = false;

		version(Check_debug) writefln("pointerLeaved isHovered %s", isHovered);
		updateState();

		return true;
	}

	// normal_unchecked == normal
	static const string[6] stateStrings = ["normal", "normal_checked", "hovered_unchecked",
	 "hovered_checked", "pressed_unchecked", "pressed_checked"];
	
	void updateState()
	{
		version(Check_debug) writefln("%s %s isHovered %s", _widget["name"], _widget["type"], isHovered);

		uint checked = _widget.getPropertyAs!("isChecked", bool) ? 1 : 0;
		uint hovered = isHovered ? 2 : 0;
		if (isPressed) hovered = 4;

		version(Check_debug) writefln("checked %s hovered %s pressed %s %s", _widget.getPropertyAs!("isChecked", bool)
		 , hovered, isPressed, stateStrings[checked | hovered]);

		_widget.setProperty!"state"(stateStrings[checked | hovered]);
	}
}