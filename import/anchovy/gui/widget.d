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

module anchovy.gui.widget;

import std.traits;
import anchovy.gui.all;
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

static this()
{
	widgetFactories["widget"] = delegate Widget(Variant[]){return new Widget; };
}

/// Container for common properties
class Widget : FlexibleObject
{
public:

	this()
	{
		properties["type"] = new ValueProperty("widget");
		properties["anchor"] = anchor = new ValueProperty(defaultAnchor);
		properties["children"] = children = new ValueProperty(cast(Widget[])[]);
		properties["parent"] = parent = new ValueProperty(null);

		properties["position"] = position = new ValueProperty(ivec2(0,0));
		properties["staticPosition"] = staticPosition = new ValueProperty(ivec2(0,0));

		properties["minSize"] = minSize = new ValueProperty(ivec2(0,0));
		properties["userSize"] = userSize = new ValueProperty(ivec2(0,0));
		properties["prefferedSize"] = prefferedSize = new ValueProperty(ivec2(0,0));
		properties["staticRect"] = staticRect = new ValueProperty(Rect(0,0,0,0));

		properties["skin"] = skin = new ValueProperty("");
		properties["state"] = state = new ValueProperty("normal");
		properties["style"] = style = new ValueProperty("");

		properties["isFocusable"] = isFocusable = new ValueProperty(false);
		properties["isEnabled"] = isEnabled = new ValueProperty(true);
		properties["isHovered"] = isHovered = new ValueProperty(false);

		auto onParentChanged = (FlexibleObject obj, Variant old, Variant* newParent){
			writeln("Parent changed to ", (*newParent).get!Widget["name"], " for ", obj["name"]);
			if(auto parent = newParent.peek!Widget)
			{
				obj["staticPosition"] = (*parent).getPropertyAs!("staticPosition", ivec2) + obj.getPropertyAs!("position", ivec2);
			}
		};

		auto onPositionChanged = (FlexibleObject obj, Variant old, Variant* newPosition){
			writeln("Position changed to ", (*newPosition).get!ivec2);
			if (auto parent = obj.peekPropertyAs!("parent", Widget))
			{
				obj["staticPosition"] = (*parent).getPropertyAs!("staticPosition", ivec2) + (*newPosition).get!ivec2;
			}
		};

		property("parent").valueChanged.connect(onParentChanged);
		property("position").valueChanged.connect(onPositionChanged);

		auto onStaticPositionChanged = (FlexibleObject obj, Variant old, Variant* newStaticPosition){
			obj["staticRect"] = Rect((*newStaticPosition).get!ivec2, obj.getPropertyAs!("userSize", ivec2));
			writeln(obj["staticRect"]);
		};

		auto onUserSizeChanged = (FlexibleObject obj, Variant old, Variant* newUserSize){
			obj["staticRect"] = Rect(obj.getPropertyAs!("staticPosition", ivec2), (*newUserSize).get!ivec2);
			writeln(obj["staticRect"]);
		};
		
		property("staticPosition").valueChanged.connect(onStaticPositionChanged);
		property("userSize").valueChanged.connect(onUserSizeChanged);
	}


	ValueProperty anchor;

	ValueProperty children;
	ValueProperty parent;

	ValueProperty position;
	ValueProperty staticPosition;

	ValueProperty minSize;
	ValueProperty userSize;
	ValueProperty prefferedSize;
	ValueProperty staticRect;

	ValueProperty skin;
	ValueProperty state;
	ValueProperty style;

	ValueProperty isFocusable;
	ValueProperty isEnabled;
	ValueProperty isHovered;
	
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

	/// Returns true if event was handled
	/// This handler will be called by Gui class twice, before and after visiting its children.
	/// In first case sinking flag will be true;
	bool handleEvent(Event e)
	{
		bool result = false;
		if (auto handlers = typeid(e) in _eventHandlers)
		{
			foreach(h; *handlers)
				result |= h(this, e);
		}
		return result;
	}

	bool recursiveHandleEvent(Event e)
	{
		e.sinking = true;
		handleEvent(e);

		bool handled = false;
		foreach (widget; this.getPropertyAs!("children", Widget[])) {
			e.sinking = true;
			handled |= widget.recursiveHandleEvent(e);
		}
		
		e.bubbling = true;
		return handleEvent(e) || handled;
	}

	
	/// Event handlers.
	bool delegate(Widget, Event)[][TypeInfo] _eventHandlers;
}

void addChild(Widget widget, Widget child)
{
	widget.setProperty!"children"(widget["children"] ~ child);
	child.setProperty!"parent"(widget);
}