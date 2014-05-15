/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.events;

import anchovy.gui;

abstract class Event
{
	/++
	 + If this flag is set-
	 + event propagates
	 + from root widget to target widget, otherwise
	 + it is bubbling from target to root.
	 +/
	bool	sinking = true;
	
	/// Pseudo flag for convenience.
	/// Opposite to sinking.
	bool bubbling() @property
	{
		return !sinking;
	}
	/// ditto
	bool bubbling(bool newBubbling) @property
	{
		return sinking = !newBubbling;
	}
	
	/// Specifies if event was already handled.
	/// Useful for checking if any child has handled this event.
	/// Set automatically by EventPropagator
	bool handled;

	/// Reference to GuiContext class, used to obtain some global information.
	GuiContext context;
}

abstract class PointerEvent : Event
{
	this(ivec2 pointerPosition)
	{
		this.pointerPosition = pointerPosition;
	}
	ivec2 pointerPosition;
}

abstract class PointerButtonEvent : PointerEvent
{
	this(ivec2 pointerPosition, PointerButton button)
	{
		super(pointerPosition);
		this.button = button;
	}
	PointerButton button;
}

// Pointer button

class PointerPressEvent : PointerButtonEvent
{
	this(ivec2 pointerPosition, PointerButton button)
	{
		super(pointerPosition, button);
	}
}

class PointerReleaseEvent : PointerButtonEvent
{
	this(ivec2 pointerPosition, PointerButton button)
	{
		super(pointerPosition, button);
	}
}

class PointerClickEvent : PointerButtonEvent
{
	this(ivec2 pointerPosition, PointerButton button)
	{
		super(pointerPosition, button);
	}
}

class PointerDoubleClickEvent : PointerButtonEvent
{
	this(ivec2 pointerPosition, PointerButton button)
	{
		super(pointerPosition, button);
	}
}

class PointerMoveEvent : PointerEvent
{
	this(ivec2 newPointerPosition, ivec2 delta)
	{
		super(newPointerPosition);
		this.delta = delta;
	}
	ivec2 delta;
}

class DragEvent : PointerMoveEvent
{
	this(ivec2 newPointerPosition, ivec2 delta, Widget target)
	{
		super(newPointerPosition, delta);
		this.target = target;
	}
	Widget target;
}

// Keyboard

class CharEnterEvent : Event
{
	this(dchar character)
	{
		this.character = character;
	}
	dchar character;
}

abstract class KeyEvent : Event
{
	this(uint keyCode, uint modifiers)
	{
		this.keyCode = keyCode;
		this.modifiers = modifiers;
	}
	uint keyCode;
	uint modifiers;
}

class KeyPressEvent : KeyEvent
{
	this(uint keyCode, uint modifiers)
	{
		super(keyCode, modifiers);
	}
}

class KeyReleaseEvent : KeyEvent
{
	this(uint keyCode, uint modifiers)
	{
		super(keyCode, modifiers);
	}
}

// Hovering

class PointerEnterEvent : Event
{
}

class PointerLeaveEvent : Event
{
}

// Focus

class FocusGainEvent : Event
{
}

class FocusLoseEvent : Event
{
}

// Layout

class ExpandLayoutEvent : Event
{
}

class MinimizeLayoutEvent : Event
{
}

// Misc

class DrawEvent : Event
{
	this(IGuiRenderer guiRenderer)
	{
		this.guiRenderer = guiRenderer;
	}
	IGuiRenderer guiRenderer;
}

class UpdatePositionEvent : Event
{
}

class GroupSelectionEvent : Event
{
	this(Widget selected)
	{
		this.selected = selected;
	}

	Widget selected;
}