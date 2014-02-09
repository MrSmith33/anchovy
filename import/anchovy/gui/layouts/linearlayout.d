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

module anchovy.gui.layouts.linearlayout;

import anchovy.gui.all;

public import anchovy.gui.interfaces.ilayout;

alias VerticalLayout = LinearLayout!true;
alias HorizontalLayout = LinearLayout!false;

class LinearLayout(bool vertical) : ILayout
{
	uint spacing = 2; // Between children
	uint padding = 2; // Between borders and content

	override void minimize(Widget root)
	{
		Widget[] children = root.getPropertyAs!("children", Widget[]);
		ivec2 rootSize = root.getPropertyAs!("userSize", ivec2);

		int minRootWidth = int.min; // Will be max child width. Then padding will be added
		int minRootLength = padding * 2;
		int childrenLength;
		uint numExpandableChildren;

		foreach(child; children)
		{
			ivec2 childSize = child.getPropertyAs!("prefSize", ivec2);
			childrenLength += *sizeLength(childSize);
			minRootWidth = max(*sizeWidth(childSize), minRootWidth);

			if (isExpandableLength(child)) ++numExpandableChildren;
		}

		minRootLength += (children.length-1) * spacing;
		minRootLength += childrenLength;
		minRootWidth += padding * 2;

		writeln("minRootLength ", minRootLength);
		writeln("minRootWidth ", minRootWidth);
		writeln("rootSize ", rootSize);

		*sizeWidth(rootSize) = minRootWidth;
		*sizeLength(rootSize) = minRootLength;
		writeln("rootSize ", rootSize);

		root.setProperty!("prefSize")(rootSize);
		root.setProperty!("numExpandable")(numExpandableChildren);

		writeln("minimize linear");
	}

	override void expand(Widget root)
	{
		Widget[] children = root.getPropertyAs!("children", Widget[]);

		uint numExpandableChildren = root.getPropertyAs!("numExpandable", uint);

		ivec2 rootUserSize = root.getPropertyAs!("userSize", ivec2);
		ivec2 rootPrefSize = root.getPropertyAs!("prefSize", ivec2);

		int maxChildWidth = *sizeWidth(rootUserSize) - padding * 2;

		int extraLength = *sizeLength(rootUserSize) - *sizeLength(rootPrefSize);
		int extraPerWidget = extraLength / cast(int)(numExpandableChildren > 0 ? numExpandableChildren : 1);
		extraPerWidget = extraPerWidget > 0 ? extraPerWidget : 0;

		writeln("numExpandableChildren ", numExpandableChildren);
		writeln("extraPerWidget ", extraPerWidget);
		writeln("extraLength ", extraLength);
		writeln("rootPrefSize ", rootPrefSize);

		int topOffset = padding - spacing;

		foreach(child; children)
		{
			topOffset += spacing;
			child.setProperty!("position")(ivec2(padding, topOffset));

			ivec2 childSize = child.getPropertyAs!("prefSize", ivec2);

			if (isExpandableLength(child))
			{
				writeln("expandable ", child["type"]);
				*sizeLength(childSize) += extraPerWidget;
			}
			if (isExpandableWidth(child))
			{
				writeln("expandable width ", child["type"]);
				*sizeWidth(childSize) = maxChildWidth;
			}
			topOffset += *sizeLength(childSize); // Offset for next child

			child.setProperty!("userSize")(childSize);
		}

		writeln("minimize linear");
	}

	override void onContainerResized(Widget root, ivec2 oldSize, ivec2 newSize)
	{
		writeln("onContainerResized");
	}

private:

	static bool isExpandableWidth(Widget widget)
	{
		static if (vertical)
			return widget.peekPropertyAs!("hexpand", bool) !is null;
		else
			return widget.peekPropertyAs!("vexpand", bool) !is null;
	}

	static bool isExpandableLength(Widget widget)
	{
		static if (vertical)
			return widget.peekPropertyAs!("vexpand", bool) !is null;
		else
			return widget.peekPropertyAs!("hexpand", bool) !is null;
	}

	static pure int* sizeLength(ref ivec2 vector)
	{
		static if (vertical)
			return &(vector.arrayof[1]);
		else
			return &(vector.arrayof[0]);
	}

	static pure int* sizeWidth(ref ivec2 vector)
	{
		static if (vertical)
			return &(vector.arrayof[0]);
		else
			return &(vector.arrayof[1]);
	}

	static pure int max(int a, int b)
	{
		return a > b ? a : b;
	}
}