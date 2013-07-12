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

module anchovy.gui.controls.button;

import anchovy.gui.all;

class Button : GuiWidget
{
public:
	this(Rect initRect, in string initStyleName = "button", GuiSkin initSkin = null)
	{
		super(initRect, initStyleName, initSkin);
	}

	override void drawContent(IGuiRenderer renderer) 
	{
		assert(_textLine);
		renderer.pushClientArea(_staticRect);

		int offx, offy;
		if (state == "pressed")
		{
			offx = 1;
			offy = 1;
		}
		renderer.drawTextLine(_textLine, _staticRect, AlignmentType.CENTER_CENTER);
		renderer.popClientArea;
	}

	override bool pointerPressed(ivec2 pointerPosition, PointerButton button)
	{
		if (!_staticRect.contains(pointerPosition)) return false;
		if (button == PointerButton.PB_LEFT)
		{
			window.inputOwnerWidget = this;
			state = "pressed";
			return true;
		}
		return false;
	}

	override bool pointerMoved(ivec2 newPointerPosition)
	{
		if (!_staticRect.contains(newPointerPosition))
		{
			if (window.inputOwnerWidget is this)
				state = "normal";
			return false;
		}
		if (window.inputOwnerWidget is this)
			state = "pressed";

		window.hoveredWidget = this;
		return true;
	}

	override void pointerEntered()
	{
		if (window.inputOwnerWidget is this)
		{
			state = "pressed";
		}
		else
		{
			state = "hover";
		}
		if (_onEnter !is null) _onEnter(this);
	}
	
	override void pointerLeaved()
	{
		state = "normal";
		if (_onLeave !is null) _onLeave(this);
	}

	override bool pointerReleased(ivec2 pointerPosition, PointerButton button)
	{
		//
		if (button == PointerButton.PB_LEFT && window.inputOwnerWidget is this)
		{
			window.lastClickedWidget = this;
			window.inputOwnerWidget = null;

			if (!_staticRect.contains(pointerPosition))
			{
				window.hoveredWidget = null;
				state = "normal";
				return true;
			}
			if (_onClick !is null) _onClick(this, pointerPosition);
			state = "hover";

			return true;
		}
		return false;
	}

	override protected void skinChanged()
	{
		setTextLineFont();
	}
}
