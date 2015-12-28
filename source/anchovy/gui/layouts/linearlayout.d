/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.layouts.linearlayout;

import anchovy.gui;

public import anchovy.gui.interfaces.ilayout;

alias VerticalLayout = LinearLayout!true;
alias HorizontalLayout = LinearLayout!false;

//version = debug_linear;

class LinearLayout(bool vertical) : ILayout
{

	override void minimize(Widget root)
	{
		Widget[] children = root.getPropertyAs!("children", Widget[]);
		ivec2 rootSize = root.getPropertyAs!("size", ivec2);
		int rootSpacing = root.coercePropertyAs!("spacing", int)(0);
		int rootPadding = root.coercePropertyAs!("padding", int)(0);

		int minRootWidth = int.min; // Will be max child width. Then padding will be added
		int minRootLength = rootPadding * 2;
		int childrenLength;
		uint numExpandableChildren;

		foreach(child; children)
		{
			ivec2 childSize = child.getPropertyAs!("prefSize", ivec2);
			ivec2 childMinSize = child.getPropertyAs!("minSize", ivec2);

			childrenLength += max(*sizeLength(childSize), *sizeLength(childMinSize));
			minRootWidth = max(max(*sizeWidth(childSize), minRootWidth), *sizeWidth(childMinSize));

			if (isExpandableLength(child)) ++numExpandableChildren;
		}

		minRootLength += (children.length-1) * rootSpacing;
		minRootLength += childrenLength;
		minRootWidth += rootPadding * 2;

		version(debug_linear)
		{
			writeln("minRootLength ", minRootLength);
			writeln("minRootWidth ", minRootWidth);
			writeln("rootSize ", rootSize);
		}

		*sizeWidth(rootSize) = minRootWidth;
		*sizeLength(rootSize) = minRootLength;

		version(debug_linear) writeln("rootSize ", rootSize);

		root.setProperty!("prefSize")(rootSize);
		root.setProperty!("numExpandable")(numExpandableChildren);

		version(debug_linear) writeln("linear minimize end\n");
	}

	override void expand(Widget root)
	{
		Widget[] children = root.getPropertyAs!("children", Widget[]);

		int rootSpacing = root.coercePropertyAs!("spacing", int)(0);
		int rootPadding = root.coercePropertyAs!("padding", int)(0);

		uint numExpandableChildren = root.getPropertyAs!("numExpandable", uint);

		ivec2 rootSize = root.getPropertyAs!("size", ivec2);
		ivec2 rootPrefSize = root.getPropertyAs!("prefSize", ivec2);

		version(debug_linear)
		{
			writeln("Root: ", root["name"]);
			writeln("rootSize ", rootSize);
			writeln("rootPrefSize ", rootPrefSize);
		}

		int maxChildWidth = *sizeWidth(rootSize) - rootPadding * 2;

		int extraLength = *sizeLength(rootSize) - *sizeLength(rootPrefSize);
		int extraPerWidget = extraLength / cast(int)(numExpandableChildren > 0 ? numExpandableChildren : 1);
		extraPerWidget = extraPerWidget > 0 ? extraPerWidget : 0;

		version(debug_linear)
		{
			writeln("numChildren ", children.length);
			writeln("numExpandableChildren ", numExpandableChildren);
			writeln("extraPerWidget ", extraPerWidget);
			writeln("extraLength ", extraLength);
			writeln("rootPrefSize ", rootPrefSize);
		}

		int topOffset = rootPadding - rootSpacing;

		foreach(child; children)
		{
			topOffset += rootSpacing;
			static if(vertical)
				child.setProperty!("position")(ivec2(rootPadding, topOffset));
			else
				child.setProperty!("position")(ivec2(topOffset, rootPadding));

			ivec2 childSize = child.getPropertyAs!("prefSize", ivec2);
			ivec2 childMinSize = child.getPropertyAs!("minSize", ivec2);
			childSize = ivec2(max(childSize.x, childMinSize.x), max(childSize.y, childMinSize.y));

			if (isExpandableLength(child))
			{
				version(debug_linear) writeln("	expandable ", child["type"]);
				*sizeLength(childSize) += extraPerWidget;
			}

			if (isExpandableWidth(child))
			{
				version(debug_linear) writeln("expandable width ", child["type"]);
				*sizeWidth(childSize) = maxChildWidth;
			}

			topOffset += *sizeLength(childSize); // Offset for next child

			child.setProperty!("size")(childSize);
		}

		version(debug_linear) writeln("linear expand end\n");
	}

	override void onContainerResized(Widget root, ivec2 oldSize, ivec2 newSize)
	{
		version(debug_linear) writeln("onContainerResized");
	}

private:

	static bool isExpandableWidth(Widget widget)
	{
		static if (vertical)
			return widget.hasProperty!"hexpand";
		else
			return widget.hasProperty!"vexpand";
	}

	static bool isExpandableLength(Widget widget)
	{
		static if (vertical)
			return widget.hasProperty!"vexpand";
		else
			return widget.hasProperty!"hexpand";
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
}
