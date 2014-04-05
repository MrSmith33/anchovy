/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.application.eventaggregator;

import anchovy.core.interfaces.iwindow;
import anchovy.gui;

import anchovy.gui.application.application;

class EventAggregator(WindowType)
{
	Application!WindowType application;
	IWindow window;
	ivec2 pointerPosition;

	this(Application!WindowType app, IWindow window)
	{
		this.application = app;
		this.window = window;
		window.keyPressed.connect(&keyPressed);
		window.keyReleased.connect(&keyReleased);
		window.charEntered.connect(&charEntered);
		window.windowResized.connect(&windowResized);
		window.mousePressed.connect(&mousePressed);
		window.mouseReleased.connect(&mouseReleased);
		window.mouseMoved.connect(&mouseMoved);
		window.closePressed.connect(&closePressed);
	}

	void keyPressed(uint keyCode)
	{
		application.context.keyPressed(cast(KeyCode)keyCode, getCurrentKeyModifiers());
	}

	void keyReleased(uint keyCode)
	{
		application.context.keyReleased(cast(KeyCode)keyCode, getCurrentKeyModifiers());
	}

	void charEntered(dchar unicode)
	{
		application.context.charEntered(unicode);
	}

	void mousePressed(uint mouseButton)
	{
		application.context.pointerPressed(window.mousePosition, cast(PointerButton)mouseButton);
	}

	void mouseReleased(uint mouseButton)
	{
		application.context.pointerReleased(window.mousePosition, cast(PointerButton)mouseButton);
	}

	void windowResized(uvec2 newSize)
	{
		window.reshape(newSize);
		application.context.size = cast(ivec2)newSize;
	}

	void mouseMoved(ivec2 position)
	{
		ivec2 deltaPos = position - pointerPosition;
		pointerPosition = position;
		application.context.pointerMoved(position, deltaPos);
	}

	uint getCurrentKeyModifiers()
	{
		uint modifiers;

		if (window.isKeyPressed(KeyCode.KEY_LEFT_SHIFT) || window.isKeyPressed(KeyCode.KEY_RIGHT_SHIFT))
			modifiers |= KeyModifiers.SHIFT;
			
		if (window.isKeyPressed(KeyCode.KEY_LEFT_CONTROL) || window.isKeyPressed(KeyCode.KEY_RIGHT_CONTROL))
			modifiers |= KeyModifiers.CONTROL;

		if (window.isKeyPressed(KeyCode.KEY_LEFT_ALT) || window.isKeyPressed(KeyCode.KEY_RIGHT_ALT))
			modifiers |= KeyModifiers.ALT;

		return modifiers;
	}

	void closePressed()
	{
		application.closePressed();
	}
}