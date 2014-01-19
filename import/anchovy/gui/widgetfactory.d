module anchovy.gui.widgetfactory;

public import std.variant;

import anchovy.gui.all;

alias widgetCreator = IWidget delegate(Variant[]);

static widgetCreator[string] widgetFactories;

static IWidget createWidget(string name, Variant[] properties = [])
{
	return widgetFactories[name](properties);
}