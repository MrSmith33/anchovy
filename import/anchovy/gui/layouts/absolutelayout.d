/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.layouts.absolutelayout;

import anchovy.gui;

public import anchovy.gui.interfaces.ilayout;

//version = debug_absolute;

class AbsoluteLayout : ILayout
{
	override void minimize(Widget root)
	{
	}

	override void expand(Widget root)
	{
		Widget[] children = root.getPropertyAs!("children", Widget[]);

		version(debug_absolute) writefln("AbsoluteLayout expand %s", root["id"]);
		
		foreach(child; children)
		{
			version(debug_absolute) writeln(child["id"]);

			ivec2 childSize = child.getPropertyAs!("prefSize", ivec2);
			ivec2 childMinSize = child.getPropertyAs!("minSize", ivec2);
			childSize = ivec2(max(childSize.x, childMinSize.x), max(childSize.y, childMinSize.y));
			child.setProperty!("size")(childSize);
		}
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

			if ((anchor & Sides.left) && (anchor & Sides.right))
			{
				int newWidth = size.x + dx;
				if (newWidth >= 0)
					size = ivec2(newWidth, size.y);
				else
					size = ivec2(0, size.y);
			}
			else if (anchor & Sides.left)
			{
				// Do nothing. X position stays unchanged, as well as width
			}
			else if (anchor & Sides.right)
			{
				pos = ivec2(pos.x + dx, pos.y);
			}
			else
			{
				assert(false); // Not yet implemented
			}

			if (anchor & Sides.top && anchor & Sides.bottom)
			{
				size = ivec2(size.x, size.y + dy);
			}
			else if (anchor & Sides.top)
			{
				// Do nothing. Y position stays unchanged, as well as height
			}
			else if (anchor & Sides.bottom)
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

