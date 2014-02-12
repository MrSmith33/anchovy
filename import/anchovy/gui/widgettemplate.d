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

module anchovy.gui.widgettemplate;

import anchovy.gui.all;
import std.algorithm;

class SubwidgetTemplate
{
	Variant[string] properties;
	SubwidgetTemplate[] subwidgets;

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
			result ~= " " ~key ~":" ~ to!string(properties[key]);
		}
		result ~= "\n";

		foreach(sub; subwidgets)
		{
			result ~= sub.toStringImpl(padding ~ "  ");
		}

		return result;
	}
}

struct ForwardedProperty
{
	string propertyName; // property that will be created in root.
	string targetPropertyName; // property to bind to.
	string targetName; // target child.
}

class WidgetTemplate
{
	ForwardedProperty[] forwardedProperties; //indexed by property name.
	SubwidgetTemplate tree; // the widget itself.
	SubwidgetTemplate[string] subwidgetsmap;
	SubwidgetTemplate childrenContainer; // by default root itself.

	Widget create(GuiContext context)
	{
		// returns null if not found.
		SubwidgetTemplate findSubwidgetByName(string name)
		{
			SubwidgetTemplate* subwidget;

			subwidget = name in subwidgetsmap;

			return *subwidget;
		}

		Widget createSubwidget(SubwidgetTemplate sub, Widget parent = null)
		{
			Widget subwidget = context.createWidget(sub.properties["type"].get!string, parent);
			
			foreach(propertyKey; sub.properties.byKey)
			{
				subwidget[propertyKey] = sub.properties[propertyKey];
			}

			foreach(forwardedProperty; forwardedProperties)
			{
				SubwidgetTemplate widget = findSubwidgetByName(forwardedProperty.targetName);
				// add binding to property
			}

			return subwidget;
		}

		Widget result = createSubwidget(tree);

		return result;
	}
}