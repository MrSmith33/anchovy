/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.widget;

import std.traits;
import anchovy.gui;
public import anchovy.utils.flexibleobject;

enum defaultAnchor = Sides.LEFT | Sides.TOP;

/// Used to specify Widget.anchor.
enum Sides
{
	LEFT = 1,
	RIGHT = 2,
	TOP = 4,
	BOTTOM = 8,
}

//version = Debug_widget;

/// Container for common properties
class Widget : FlexibleObject
{
public:

	this()
	{
		properties["type"] = new ValueProperty(this, "widget");
		properties["anchor"] = anchor = new ValueProperty(this, defaultAnchor);
		properties["children"] = children = new ValueProperty(this, cast(Widget[])[]);
		properties["logicalChildren"] = logicalChildren = new ValueProperty(this, cast(Widget[])[]);
		properties["parent"] = parent = new ValueProperty(this, null);

		properties["position"] = position = new ValueProperty(this, ivec2(0,0));
		properties["staticPosition"] = staticPosition = new ValueProperty(this, ivec2(0,0));

		properties["minSize"] = minSize = new ValueProperty(this, ivec2(0,0));
		properties["size"] = size = new ValueProperty(this, ivec2(0,0));
		properties["prefSize"] = prefferedSize = new ValueProperty(this, ivec2(0,0));
		properties["staticRect"] = staticRect = new ValueProperty(this, Rect(0,0,0,0));

		properties["state"] = state = new ValueProperty(this, "normal");
		properties["style"] = style = new ValueProperty(this, "");
		properties["geometry"] = geometry = new ValueProperty(this, (TexRectArray[string]).init);

		properties["hasBack"] = hasBack = new ValueProperty(this, true);
		properties["isVisible"] = isVisible = new ValueProperty(this, true);
		properties["isFocusable"] = isFocusable = new ValueProperty(this, false);
		properties["isEnabled"] = isEnabled = new ValueProperty(this, true);
		properties["isHovered"] = isHovered = new ValueProperty(this, false);
		properties["respondsToPointer"] = respondsToPointer = new ValueProperty(this, true);
		properties["context"] = context = new ValueProperty(this, null);

		auto onParentChanged = (FlexibleObject obj, Variant newParent){
			(cast(Widget)obj).invalidateLayout;
		};

		auto onPositionChanged = (FlexibleObject obj, Variant newPosition){
			(cast(Widget)obj).invalidateLayout;
		};

		property("parent").valueChanged.connect(onParentChanged);
		property("position").valueChanged.connect(onPositionChanged);

		auto onStaticPositionChanged = (FlexibleObject obj, Variant newStaticPosition){
			obj["staticRect"] = Rect(newStaticPosition.get!ivec2, obj.getPropertyAs!("size", ivec2));
		};

		auto onSizeChanged = (FlexibleObject obj, Variant newSize){
			obj["staticRect"] = Rect(obj.getPropertyAs!("staticPosition", ivec2), newSize.get!ivec2);

			obj.setProperty!("geometry", TexRectArray[string])(null);

			(cast(Widget)obj).invalidateLayout;
		};

		auto onVisibilityChanged = (FlexibleObject obj, Variant isVisible)
		{
			Widget parent = obj.getPropertyAs!("parent", Widget);
			if (parent is null) return;

			Widget child = cast(Widget)obj;

			import std.algorithm : remove;

			if (obj["isVisible"] == true)
				parent.setProperty!"children"(parent["children"] ~ child);
			else
				parent["children"] = parent["children"].get!(Widget[]).remove!((a) => a == child);
		};
		
		property("staticPosition").valueChanged.connect(onStaticPositionChanged);
		property("size").valueChanged.connect(onSizeChanged);
		property("isVisible").valueChanged.connect(onVisibilityChanged);

		addEventHandler(&handleDraw);
		addEventHandler(&handleUpdatePosition);
		addEventHandler(&handleExpand);
		addEventHandler(&handleMinimize);
	}

	bool handleExpand(Widget widget, ExpandLayoutEvent event)
	{
		if (auto layout = widget.peekPropertyAs!("layout", ILayout))
		{
			layout.expand(widget);
		}

		return true;
	}

	bool handleMinimize(Widget widget, MinimizeLayoutEvent event)
	{
		if (auto layout = widget.peekPropertyAs!("layout", ILayout))
		{
			layout.minimize(widget);
		}

		return true;
	}

	bool handleUpdatePosition(Widget widget, UpdatePositionEvent event)
	{
		if (auto parent = widget.peekPropertyAs!("parent", Widget))
		{
			if (*parent !is null)
			{
				ivec2 parentPos = (*parent).getPropertyAs!("staticPosition", ivec2);
				ivec2 childPos = widget.getPropertyAs!("position", ivec2);
				ivec2 newStaticPosition = parentPos + childPos; // Workaround bug with direct summ.
				widget["staticPosition"] = newStaticPosition;
				widget["staticRect"] = Rect(newStaticPosition, widget.getPropertyAs!("size", ivec2));
			}
		}

		return true;
	}

	bool handleDraw(Widget widget, DrawEvent event)
	{
		bool clipContent = widget.hasProperty!("clipContent");

		if (event.sinking)
		{
			Rect staticRect = widget.getPropertyAs!("staticRect", Rect);

			if (clipContent)
			{
				event.guiRenderer.pushClientArea(staticRect);
			}

			if (widget.getPropertyAs!("hasBack", bool))
				event.guiRenderer.drawControlBack(widget, staticRect);
		}
		else if (clipContent)
			event.guiRenderer.popClientArea;

		return true;
	}


	ValueProperty anchor;

	ValueProperty children; // visible children
	ValueProperty logicalChildren; // all children
	ValueProperty parent;
	ValueProperty context;

	ValueProperty position;
	ValueProperty staticPosition;

	ValueProperty minSize;
	ValueProperty size;
	ValueProperty prefferedSize;
	ValueProperty staticRect;

	ValueProperty state;
	ValueProperty style;
	ValueProperty geometry;

	ValueProperty isFocusable;
	ValueProperty isEnabled;
	ValueProperty isHovered;
	ValueProperty isVisible;
	ValueProperty hasBack;
	ValueProperty respondsToPointer;
	
	void addEventHandler(T)(T handler)
	{
		static assert(isDelegate!T, "handler must be a delegate, not " ~ T.stringof);
		alias widgetType = ParameterTypeTuple!T[0];
		alias eventType = ParameterTypeTuple!T[1];
		static assert(!is(eventType == Event), "handler's parameter must not be Event class but inherited one");
		static assert(is(eventType : Event), "handler's parameter must be inherited from Event class");
		static assert(is(widgetType : Widget), "handler must accept Widget as first parameter");
		static assert(ParameterTypeTuple!T.length == 2, "handler must have only two parameters, Widget's and Event's descendant");
		_eventHandlers[typeid(eventType)] ~= cast(bool delegate(Widget, Event))handler;
	}

	void removeEventHandlers(T)()
	{
		_eventHandlers[typeid(T)] = null;
	}

	/// Returns true if event was handled
	/// This handler will be called by Gui class twice, before and after visiting its children.
	/// In first case sinking flag will be true;
	bool handleEvent(Event e)
	{
		bool result = false;
		if (auto handlers = typeid(e) in _eventHandlers)
		{
			foreach(h; *handlers)
			{
				result |= h(this, e);
			}
		}
		return result;
	}
	
	/// Event handlers.
	bool delegate(Widget, Event)[][TypeInfo] _eventHandlers;
}

Widget getParentFromWidget(Widget root)
{
	Widget* container;
	container = root.peekPropertyAs!("container", Widget);

	if (container is null) container = &root;
	assert(*container);

	return *container;
}

IWidgetBehavior getWidgetBehavior(Behavior)(Widget widget)
{
	IWidgetBehavior[] behaviors = widget.getPropertyAs!("behaviors", IWidgetBehavior[]);
	
	import std.algorithm : find;
	auto found = find!((a) => cast(Behavior)a !is null)(behaviors);

	import std.array : empty;
	if (!found.empty)
		return found[0];
	else
		return null;
}

void addChild(Widget root, Widget child)
in
{
	assert(root);
	assert(child);
}
body
{
	Widget parent = getParentFromWidget(root);

	parent.setProperty!"logicalChildren"(parent["logicalChildren"] ~ child);
	child.setProperty!"parent"(parent);
	if (child.isVisible.value == true)
		parent.setProperty!"children"(parent["children"] ~ child);
}

void removeChild(Widget root, Widget child)
{
	if (child is null) return;

	import std.algorithm : remove;

	Widget parent = getParentFromWidget(root);
	child["parent"] = null;
	parent["children"] = parent["children"].get!(Widget[]).remove!((a) => a == child);
	parent["logicalChildren"] = parent["logicalChildren"].get!(Widget[]).remove!((a) => a == child);
}

/// Says to global layout manager that this widget needs layout update.
void invalidateLayout(Widget widget)
{
	widget.getPropertyAs!("context", GuiContext).eventDispatcher.invalidateWidgetLayout(widget);
}