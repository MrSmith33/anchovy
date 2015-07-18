/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.layouts.dockinglayout;

import anchovy.gui;

public import anchovy.gui.interfaces.ilayout;

class DockingLayout : ILayout
{
	override void minimize(Widget root)
	{
	}

	override void expand(Widget root)
	{
	}

	override void onContainerResized(Widget root, ivec2 oldSize, ivec2 newSize)
	{

	}
}
