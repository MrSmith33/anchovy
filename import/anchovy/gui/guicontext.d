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

module anchovy.gui.guicontext;

import anchovy.gui.all;
import anchovy.gui.interfaces.iwidgetbehavior : IWidgetBehavior;


class GuiContext
{
	alias WidgetCreator = Widget delegate();

	WidgetCreator[string] widgetFactories;
	IWidgetBehavior[string] widgetBehaviors;

	Widget[] roots;

	bool isLayoutValid; // Will be updated in update method

	void invalidateWidgetLayout(Widget container)
	{
		isLayoutValid = false;
	}

	void doLayout()
	{
		foreach(root; roots)
		{
			root.propagateEventChildrenFirst(new MinimizeLayoutEvent);
			root.propagateEventParentFirst(new ExpandLayoutEvent);
		}
	}

	void update(double deltaTime)
	{
		if (!isLayoutValid)
		{
			doLayout();
			isLayoutValid = true;
		}

	}

	//InputManager inputManager;
	//EventManager eventManager;
protected:
	KeyModifiers modifiers;

	/// Gui renderer used for drawing all children widgets.
	IGuiRenderer	_guiRenderer;

	/// Used for timers.
	TimerManager	_timerManager;

	/// Current input owner If set, this widget will receive all pointer moved events.
	/// See_Also: inputOwnerWidget
	Widget		_inputOwnerWidget;

	/// Currently dragging widget. Will receive onDrag events.
	Widget		_draggingWidget;

	/// Last clicked widget. Used for double-click checking.
	/// See_Also: lastClickedWidget
	Widget		_lastClickedWidget;
	
	Widget		_pressedWidget;

	/// Hovered widget. Widget over which pointer is located.
	/// See_Also: hoveredWidget
	Widget		_hoveredWidget;

	/// Focused widget.
	/// 
	/// Will receive all key events if input is not grabbed by other widget.
	Widget		_focusedWidget;

	/// This will be called when widget sets clipboard string.
	void delegate(dstring newClipboardString) _setClipboardStringCallback;

	/// This will be called when widget requests clipboard string.
	dstring delegate() _getClipboardStringCallback;

public:

	this(IGuiRenderer guiRenderer, TimerManager timerManager, GuiSkin skin)
	in
	{
		assert(guiRenderer);
		assert(skin);
		assert(timerManager);
	}
	body
	{
		_guiRenderer = guiRenderer;
		_timerManager = timerManager;
	}

	void addRoot(Widget root)
	{
		root.setProperty!"userSize"(_guiRenderer.renderer.windowSize);
		roots ~= root;
	}

	Widget createWidget(string type, Widget parent = null)
	{
		Widget widget;

		if (auto factory = type in widgetFactories)
		{
			widget = widgetFactories[type]();
		}
		else
		{
			widget = new Widget;
		}

		widget["type"] = type;
		widget["style"] = type;
		widget["context"] = this;

		if (parent !is null)
		{
			addChild(parent, widget);
		}
		else
		{
			widget["parent"] = null;
		}

		
		if (auto behavior = type in widgetBehaviors)
		{
			behavior.attachTo(widget);
		}

		return widget;
	}

//+-------------------------------------------------------------------------------+
//|                                  Properties                                   |
//+-------------------------------------------------------------------------------+

@property
{
/// Sets new size for all root widgets.
	void size(ivec2 newSize)
	{
		foreach(widget; roots)
		{
			widget.setProperty!"userSize"(newSize);
		}
	}
	
	/// Used to get last clicked widget.
	Widget lastClickedWidget() @safe
	{
		return _lastClickedWidget;
	}

	/// Used to set last clicked widget.
	void lastClickedWidget(Widget widget) @safe
	{
		_lastClickedWidget = widget;
	}

	/// Used to get current hovered widget.
	Widget hoveredWidget() @safe
	{
		return _hoveredWidget;
	}

	/// Used to set current hovered widget.
	void hoveredWidget(Widget widget) @trusted
	{
		if (_hoveredWidget !is widget)
		{
			if (_hoveredWidget !is null)
			{
				auto event = new PointerLeaveEvent;
				event.context = this;
				_hoveredWidget.handleEvent(event);
			}
			if (widget !is null)
			{
				auto event = new PointerEnterEvent;
				event.context = this;
				widget.handleEvent(event);
			}
			_hoveredWidget = widget;
		}
	}

	/// Used to get current focused input owner widget
	Widget inputOwnerWidget() @safe pure
	{
		return _inputOwnerWidget;
	}

	/// Used to set current focused input owner widget
	void inputOwnerWidget(Widget widget) @trusted
	{
		_inputOwnerWidget = widget;
	}
	
	/// Used to get current focused input owner widget
	Widget pressedWidget() @safe pure
	{
		return _pressedWidget;
	}

	/// Used to set current focused input owner widget
	void pressedWidget(Widget widget) @trusted
	{
		_pressedWidget = widget;
	}

	/// Used to get current focused widget
	Widget focusedWidget() @safe pure
	{
		return _focusedWidget;
	}

	/// Used to set current focused widget
	void focusedWidget(Widget widget)
	{
		if (_focusedWidget !is widget)
		{
			if (_focusedWidget !is null)
			{
				auto event = new FocusLoseEvent;
				event.context = this;
				_focusedWidget.handleEvent(event);
			}
			if (widget !is null)
			{
				auto event = new FocusGainEvent;
				event.context = this;
				widget.handleEvent(event);
			}
			_focusedWidget = widget;
		}
	}

	/// Used to get current clipboard string
	dstring clipboardString()
	{
		if (_getClipboardStringCallback !is null) 
			return _getClipboardStringCallback();
		else
			return "";
	}

	/// Used to set current clipboard string
	void clipboardString(dstring newString)
	{
		if (_setClipboardStringCallback !is null) 
			_setClipboardStringCallback(newString);
	}

	/// Will be used by window to provide clipboard functionality.
	void getClipboardStringCallback(dstring delegate() callback)
	{
		_getClipboardStringCallback = callback;
	}

	/// ditto
	void setClipboardStringCallback(void delegate(dstring) callback)
	{
		_setClipboardStringCallback = callback;
	}

	TimerManager timerManager()
	{
		return _timerManager;
	}
}

//+-------------------------------------------------------------------------------+
//|                                Event handling                                 |
//+-------------------------------------------------------------------------------+

	static bool containsPointer(Widget widget, ivec2 pointerPosition)
	{
		return widget.getPropertyAs!("staticRect", Rect).contains(pointerPosition);
	}

	void handleEvent(Event event)
	{
		foreach(widget; roots)
		{
			widget.recursiveHandleEvent(event);
		}
	}

	void draw()
	{
		auto event = new DrawEvent(_guiRenderer);
		event.context = this;

		foreach(root; roots)
		{
			root.propagateEventParentFirst(event);
		}
	}

	/// Handler for key press event.
	/// 
	/// Must be called by user application.
	bool keyPressed(in KeyCode key, KeyModifiers modifiers)
	{
		if (_focusedWidget !is null)
		{
			auto event = new KeyPressEvent(key, modifiers);
			event.context = this;
			_focusedWidget.handleEvent(event);
		}
		return false;
	}

	/// Handler for key release event.
	/// 
	/// Must be called by user application.
	bool keyReleased(in KeyCode key, KeyModifiers modifiers)
	{
		if (_focusedWidget !is null)
		{
			auto event = new KeyReleaseEvent(key, modifiers);
			event.context = this;
			_focusedWidget.handleEvent(event);
		}
		return false;
	}

	/// Handler for char enter event.
	/// 
	/// Must be called by user application.
	bool charEntered(in dchar chr)
	{
		if (_focusedWidget !is null)
		{
			auto event = new CharEnterEvent(chr);
			event.context = this;
			_focusedWidget.handleEvent(event);
		}
		return false;
	}

	/// Handler for pointer press event.
	/// 
	/// Must be called by user application.
	bool pointerPressed(ivec2 pointerPosition, PointerButton button)
	{	
		auto event = new PointerPressEvent(pointerPosition, button);
		event.context = this;
		
		foreach_reverse(rootWidget; roots)
		{
			Widget[] widgetChain = buildPathToLeaf!(containsPointer)(rootWidget, pointerPosition);

			Widget[] eventConsumerChain = propagateEventSinkBubble(widgetChain, event);

			if (eventConsumerChain.length > 0)
			{
				if (eventConsumerChain[$-1].isFocusable)
					focusedWidget = eventConsumerChain[$-1];
				
				pressedWidget = eventConsumerChain[$-1];
				
				break;
			}
		}

		focusedWidget = null;

		return false;
	}

	/// Handler for pointer release event.
	/// 
	/// Must be called by user application.
	bool pointerReleased(ivec2 pointerPosition, PointerButton button)
	{
		scope event = new PointerReleaseEvent(pointerPosition, button);
		event.context = this;
		
		foreach_reverse(rootWidget; roots)
		{
			Widget[] widgetChain = buildPathToLeaf!(containsPointer)(rootWidget, pointerPosition);

			Widget[] eventConsumerChain = propagateEventSinkBubble(widgetChain, event);

			if (eventConsumerChain.length > 0)
			{
				if (pressedWidget is eventConsumerChain[$-1])
				{
					scope clickEvent = new PointerClickEvent(pointerPosition, button);
					clickEvent.context = this;

					pressedWidget.handleEvent(clickEvent);

					lastClickedWidget = pressedWidget;
				}
				break;
			}
		}

		pressedWidget = null;

		return false;
	}


	/// Handler for pointer move event.
	/// 
	/// Must be called by user application.
	bool pointerMoved(ivec2 newPointerPosition, ivec2 delta)
	{	
		auto event = new PointerMoveEvent(newPointerPosition, delta);
		event.context = this;
		
		if (pressedWidget !is null)
		{
			bool handled = pressedWidget.handleEvent(event);

			if (handled)
			{
				hoveredWidget = pressedWidget;

				return false;
			}
		}
		else
		{	
			foreach_reverse(rootWidget; roots)
			{
				Widget[] widgetChain = buildPathToLeaf!(containsPointer)(rootWidget, newPointerPosition);

				Widget[] eventConsumerChain = propagateEventSinkBubble(widgetChain, event);

				if (eventConsumerChain.length > 0)
				{
					hoveredWidget = eventConsumerChain[$-1];

					return false;
				}
			}
		}

		hoveredWidget = null;
		
		return false;
	}
}