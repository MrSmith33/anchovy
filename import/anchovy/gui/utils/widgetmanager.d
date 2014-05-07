/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.utils.widgetmanager;

import anchovy.gui;

//version = Debug_wman;

alias WidgetCreator = Widget delegate();
alias LayoutCreator = ILayout delegate();
alias BehaviorCreator = IWidgetBehavior delegate();

struct WidgetManager
{
	//WidgetCreator[string] widgetFactories;
	//LayoutCreator[string] layoutFactories;
	//BehaviorCreator[][string] behaviorFactories;

	@disable this();

	this(GuiContext context)
	{
		_context = context;
	}

	/// Returns widget found by given id.
	Widget getWidgetById(string id)
	{
		if (auto widget = id in _ids)
		{
			return *widget;
		}
		else
			return null;
	}

	Widget createWidget(string type, Widget parent = null)
	{
		Widget widget;
		IWidgetBehavior[] behaviors;

		void attachBehaviorProperties(Widget _widget)
		{
			//----------------------- Attaching behaviors properties ---------------------------

			if (auto factories = type in _context.behaviorFactories)
			{
				IWidgetBehavior behavior;

				foreach(factory; *factories)
				{
					behavior = factory();
					behavior.attachPropertiesTo(_widget);
					behaviors ~= behavior;
				}
			}
		}

		//----------------------- Instatiating templates ---------------------------

		//writeln("template for ", type, " is ", _templateManager.getTemplate(type));
		if (WidgetTemplate templ = _context.templateManager.getTemplate(type))
		{
			//----------------------- Base type construction -----------------------

			Widget baseWidget;

			if (templ.baseType != "widget")
			{
				baseWidget = createWidget(templ.baseType);
			}
			else
			{
				baseWidget = createBaseWidget(type); // Create using factory.
				attachBehaviorProperties(baseWidget);
			}

			baseWidget["type"] = type;
			baseWidget["context"] = _context; // widget may access context before construction ends.
			baseWidget.setProperty!("subwidgets", Widget[string])(null);

			//----------------------- Template construction ------------------------
			// Recursively creates widgets as stated in template. widget is root of that tree.
			widget = createSubwidget(templ.tree, baseWidget, baseWidget);

			if (templ.container)
			{
				auto subwidgets = widget.getPropertyAs!("subwidgets", Widget[string]);
				auto container = subwidgets[templ.container];
				if (container)
				{
					version(Debug_wman) writefln("Adding container %s", templ.container);
					widget["container"] = container;
				}
			}

			widget["template"] = templ;
		}
		else
		{
			// if there is no template, lets create regular one.
			widget = createBaseWidget(type);
			attachBehaviorProperties(widget);
		}

		// default style
		if (widget["style"] == Variant(null))
		{
			widget["style"] = type;
		}

		widget["context"] = _context; // if widget attempts to override context.

		// adding parent
		if (parent !is null)
		{
			addChild(parent, widget);
		}
		else
		{
			widget["parent"] = null;
		}

		//----------------------- Attaching behaviors ---------------------------
		foreach(behavior; behaviors)
		{
			behavior.attachTo(widget);
		}

		return widget;
	}

private:

	/// Stores widgets with id property.
	Widget[string] _ids;

	GuiContext _context;

	//---------------------------- Helpers ---------------------------------
	Widget createBaseWidget(string type)
	{
		if (auto factory = type in _context.widgetFactories)
		{
			return _context.widgetFactories[type]();
		}
		else
		{
			return new Widget;
		}
	}

	import std.conv : parse;
	import std.string : munch;

	Variant parseProperty(string name, ref Variant value, Widget widget)
	{
		switch(name)
		{
			case "layout":
			version(Debug_wman) writeln("found layout property: ", value.get!string);
				if (auto factory = value.get!string in _context.layoutFactories)
				{
					auto result = Variant((*factory)());
					//writeln(result);

					return result;
				}
				version(Debug_wman) writefln("Error: unknown layout '%s' found", value.get!string);
				break;
			case "minSize", "prefSize":
				try
				{
					string nums = value.get!string;
					int w = parse!int(nums);
					munch(nums, " \t\n\r");
					int h = parse!int(nums);
					return Variant(ivec2(w, h));
				}
				catch (Exception e)
				{
					writefln("Error parsing %s %s", name, e);
				}
				return Variant(ivec2(16, 16));
			case "id":
				string id = value.get!string;
				if (id in _ids)
				{
					writeln("Duplicate id found: ", id, ", overriding...");
				}
				_ids[id] = widget;

				return value;
			default:
				return value;
		}

		return value;
	}

	Widget createSubwidget(SubwidgetTemplate sub, Widget subwidget, Widget root)
	{
		//----------------------- Forwarding properties ------------------------
		foreach(forwardedProperty; sub.forwardedProperties)
		{
			version(Debug_wman) writeln("forwarding ", forwardedProperty.propertyName ," to ",
				forwardedProperty.targetPropertyName);
			root[forwardedProperty.propertyName] = subwidget.property(forwardedProperty.targetPropertyName);
		}

		//------------------------ Assigning properties ------------------------
		foreach(propertyKey; sub.properties.byKey)
		{
			version(Debug_wman)writeln("new property ", propertyKey);
			Variant value = parseProperty(propertyKey, sub.properties[propertyKey], subwidget);
			version(Debug_wman)writeln("Parsed value ", value);
			version(Debug_wman) writeln("Assigning properties ", propertyKey," ",value,
			 " ", subwidget["name"], " ", subwidget["type"], " ", root["name"], " ", root["type"]);
			subwidget[propertyKey] = value;
			version(Debug_wman) writeln(subwidget[propertyKey]);
		}

		Variant* name = "name" in sub.properties;
		if(name)
		{
			if (auto subtemplateName = name.peek!string)
			{
				Widget[string] subwidgets = root["subwidgets"].get!(Widget[string]);
				subwidgets[*subtemplateName] = subwidget;
				root["subwidgets"] = subwidgets;
			}
		}
		
		//------------------------ Creating subwidgets -------------------------
		foreach(subtemplate; sub.subwidgets)
		{
			version(Debug_wman) writefln("%s: Adding subwidget %s", subwidget["name"], subtemplate.properties["type"].get!string);
			createSubwidget(subtemplate, createWidget(subtemplate.properties["type"].get!string, subwidget), root);
		}

		return subwidget;
	}
}