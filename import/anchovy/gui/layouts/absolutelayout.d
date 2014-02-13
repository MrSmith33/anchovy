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

module anchovy.gui.layouts.absolutelayout;

import anchovy.gui;

public import anchovy.gui.interfaces.ilayout;

class AbsoluteLayout : ILayout
{
	override void minimize(Widget root)
	{
	}

	override void expand(Widget root)
	{
	}

	override void onContainerResized(Widget root, ivec2 oldSize, ivec2 newSize)
	{
		Widget[] children = root.getPropertyAs!("children", Widget[]);

		int dx = newSize.x - oldSize.x;
		int dy = newSize.y - oldSize.y;

		foreach(ref widget; children)
		{
			int anchor;
			ivec2 pos = widget.getPropertyAs!("position", int);
			ivec2 size = widget.getPropertyAs!("size", ivec2);
			anchor = widget.getPropertyAs!("anchor", int);

			if ((anchor & Sides.LEFT) && (anchor & Sides.RIGHT))
			{
				int newWidth = size.x + dx;
				if (newWidth >= 0)
					size = ivec2(newWidth, size.y);
				else
					size = ivec2(0, size.y);
			}
			else if (anchor & Sides.LEFT)
			{
				// Do nothing. X position stays unchanged, as well as width
			}
			else if (anchor & Sides.RIGHT)
			{
				pos = ivec2(pos.x + dx, pos.y);
			}
			else
			{
				assert(false); // Not yet implemented
			}

			if (anchor & Sides.TOP && anchor & Sides.BOTTOM)
			{
				size = ivec2(size.x, size.y + dy);
			}
			else if (anchor & Sides.TOP)
			{
				// Do nothing. Y position stays unchanged, as well as height
			}
			else if (anchor & Sides.BOTTOM)
			{
				pos = ivec2(pos.x, pos.y + dy);
			}
			else
			{
				assert(false); // Not yet implemented
			}

			widget.setProperty!"position"(pos);
			widget.setProperty!"size"(size);
			widget.setProperty!"anchor"(anchor);
		}
	}


}

