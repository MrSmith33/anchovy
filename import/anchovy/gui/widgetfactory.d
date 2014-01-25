module anchovy.gui.widgetfactory;

public import std.variant;

import anchovy.gui.all;
import anchovy.gui.interfaces.iwidgetbehavior : IWidgetBehavior;

alias widgetCreator = Widget delegate(Variant[]);

static widgetCreator[string] widgetFactories;
static IWidgetBehavior[string] widgetBehaviors;

static Widget createWidget(string type, Variant[] properties = [])
{
	Widget widget;
	if (auto factory = type in widgetFactories)
	{
		widget = widgetFactories[type](properties);
	}
	else
	{
		widget = new Widget;
	}

	widget["type"] = type;
	widget["style"] = type;
	
	if (auto behavior = type in widgetBehaviors)
	{
		behavior.attachTo(widget);
	}

	return widget;
}