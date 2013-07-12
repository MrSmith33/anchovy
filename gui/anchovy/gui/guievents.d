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

module anchovy.gui.guievents;

@disable class Event
{
	/++
	 + If this flag is set to PropPhase.Sinking -
	 + event propagates
	 + from window to target widget, otherwise
	 + it is bubbling from target to window
	 +/
	bool	sinking;

	this()
	{
		// Constructor code
	}
}

@disable class EventPointer : Event
{
	enum : uint // mouse buttons
	{
		LEFT_BUTTON     = 0x1,  
		RIGHT_BUTTON     = 0x2,  
		CENTER_BUTTON   = 0x4,
		X_BUTTON_1       = 0x8,
		X_BUTTON_2       = 0x10,
		X_BUTTON_3       = 0x20,
	}

	/// mouse buttons - combination of flags above
	uint  buttons;

	int pointerX;
	int pointerY;
}