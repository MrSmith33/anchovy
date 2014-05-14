/**
Copyright: Copyright (c) 2013 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.buttonbehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

// version = Button_debug;

class ButtonBehavior : IWidgetBehavior
{
public:

	override void attachTo(Widget widget)
	{
		widget.addEventHandler(&pointerPressed);
		widget.addEventHandler(&pointerReleased);
		widget.addEventHandler(&pointerMoved);
		widget.addEventHandler(&pointerEntered);
		widget.addEventHandler(&pointerLeaved);

		widget.setProperty!"isFocusable"(true);
		widget.setProperty!"style"("button");
	}

	bool pointerPressed(Widget widget, PointerPressEvent event)
	{
		if (event.button == PointerButton.PB_LEFT)
		{
			widget.setProperty!"state"("pressed");
			
			version(Button_debug) writeln("pressed");
		}
		return true;
	}
	
	bool pointerReleased(Widget widget, PointerReleaseEvent event)
	{
		if (event.button == PointerButton.PB_LEFT)
		{
			widget.setProperty!"state"("hover");
			
			version(Button_debug) writeln("hovered");
		}
		return true;
	}

	bool pointerMoved(Widget widget, PointerMoveEvent event)
	{
		return true;
	}

	bool pointerEntered(Widget widget, PointerEnterEvent event)
	{
		if (event.context.eventDispatcher.pressedWidget is this)
		{
			widget.setProperty!"state"("pressed");
			
			version(Button_debug) writeln("pressed");
		}
		else
		{
			widget.setProperty!"state"("hover");
			
			version(Button_debug) writeln("hovered");
		}
		return true;
	}
	
	bool pointerLeaved(Widget widget, PointerLeaveEvent event)
	{
		widget.setProperty!"state"("normal");
		
		version(Button_debug) writeln("normal");
		
		return true;
	}
}

