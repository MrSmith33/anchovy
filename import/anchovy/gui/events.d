/*
Copyright (c) 2013 Andrey Penechko

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license the "Software" to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
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