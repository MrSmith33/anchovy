/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.templates.widgettemplate;

import anchovy.gui;
import std.algorithm;

class SubwidgetTemplate
{
	Variant[string] properties;
	SubwidgetTemplate[] subwidgets;
	ForwardedProperty[] forwardedProperties;

	override string toString()
	{
		return toStringImpl("");
	}

	string toStringImpl(string padding)
	{
		string result;
		result ~= padding ~ to!string(properties["type"]);

		foreach(key; properties.byKey)
		{
			result ~= " " ~ key ~ ":" ~ to!string(properties[key]);
		}
		foreach(fprop; forwardedProperties)
		{
			result ~= " alias " ~ fprop.propertyName ~" = " ~ fprop.targetPropertyName;
		}
		result ~= "\n";

		foreach(sub; subwidgets)
		{
			result ~= sub.toStringImpl(padding ~ "   ");
		}

		return result;
	}
}

struct ForwardedProperty
{
	string propertyName; // property that will be created in root.
	string targetPropertyName; // property to bind to.
}

class WidgetTemplate
{
	SubwidgetTemplate tree; // the widget itself.
	SubwidgetTemplate[string] subwidgetsmap;
	string baseType;
	string name;
	string container;

	SubwidgetTemplate findSubwidgetByName(string name)
	{
		SubwidgetTemplate* subwidget;

		subwidget = name in subwidgetsmap;

		return *subwidget;
	}

	override string toString()
	{
		return tree.toString() ~ 
				"base: " ~ baseType ~ " cont: " ~ container~"\n";
	}
}