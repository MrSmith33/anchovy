/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.layouts.defaultlayouts;

import anchovy.gui.layouts.absolutelayout;
import anchovy.gui.layouts.dockinglayout;
import anchovy.gui.layouts.linearlayout;

import anchovy.gui.guicontext;

void attachDefaultLayouts(GuiContext context)
{
	context.layoutFactories["absolute"] = {return new AbsoluteLayout;};
	context.layoutFactories["docking"] = {return new DockingLayout;};
	context.layoutFactories["horizontal"] = {return new HorizontalLayout;};
	context.layoutFactories["vertical"] = {return new VerticalLayout;};
}