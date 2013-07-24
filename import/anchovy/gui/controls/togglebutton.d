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

module anchovy.gui.controls.togglebutton;

import anchovy.gui.all;

abstract class ToggleButton : Widget
{
	this(Rect initRect, in string initStyleName = "toggle", GuiSkin initSkin = null)
	{
		super(initRect, initStyleName, initSkin);
	}

	bool isChecked() @property
	{
		return _isChecked;
	}
	
	void isChecked(bool checked) @property
	{
		if (_isChecked != checked)
		{
			_isChecked = checked;
			updateState();
			if (_onToggle !is null) _onToggle(this);
		}
	}

	void onToggle(RegularHandler handler) @property
	{
		_onToggle = handler;
	}

protected:
	
	bool _isChecked = false;
	bool _isHovered = false;
	bool _isPressed = false;

	RegularHandler _onToggle;

	void toggleState()
	{
		_isChecked = !_isChecked;
		updateState();
	}
	
	/// Using bitwise OR 6 variants can be produced
	/// NORMAL | UNCHECKED == 0
	/// NORMAL | CHECKED == 1
	/// HOVERED | UNCHECKED == 2
	/// HOVERED | CHECKED == 3
	/// PRESSED | UNCHECKED == 4
	/// PRESSED | CHECKED == 5
	enum State
	{
		NORMAL = 0, // not pressed and not hovered
		HOVERED = 2,
		PRESSED = 4,
		CHECKED = 1,
		UNCHECKED = 0,
	}

	// normal_unchecked == normal
	static const string[6] stateStrings = ["normal", "normal_checked", "hovered_unchecked", "hovered_checked", "pressed_unchecked", "pressed_checked"];
	
	void updateState()
	{
		uint checked = _isChecked ? 1 : 0;
		uint hovered = _isHovered ? 2 : 0;
		if (_isPressed) hovered = 4;
		_state = stateStrings[checked | hovered];
		//writeln("stateUpdate ", _state);
	}
}