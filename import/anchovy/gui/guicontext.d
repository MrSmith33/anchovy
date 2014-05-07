/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.guicontext;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior : IWidgetBehavior;
public import anchovy.gui.widgetmanager;

//version = Debug_guicontext;

class GuiContext
{
	alias WidgetCreator = Widget delegate();
	alias LayoutCreator = ILayout delegate();
	alias BehaviorCreator = IWidgetBehavior delegate();

	WidgetCreator[string] widgetFactories;
	LayoutCreator[string] layoutFactories;
	BehaviorCreator[][string] behaviorFactories;

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
			root.propagateEventParentFirst(new UpdatePositionEvent);
		}
	}

	void update(double deltaTime)
	{
		if (!isLayoutValid)
		{
			doLayout();
			isLayoutValid = true;

			if (pressedWidget is null)
			{
				scope moveEvent = new PointerMoveEvent(lastPointerPosition, ivec2(0, 0));
				moveEvent.context = this;
				updateHovered(moveEvent);
			}
		}
	}

protected:

	// Key modifiers
	uint modifiers;

	/// Gui renderer used for drawing all children widgets.
	IGuiRenderer	_guiRenderer;

	/// Used for timers.
	TimerManager	_timerManager;

	TemplateManager _templateManager;

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

	WidgetManager _wman;

	ivec2 lastPointerPosition = ivec2(int.max, int.max);

	/// This will be called when widget sets clipboard string.
	void delegate(dstring newClipboardString) _setClipboardStringCallback;

	/// This will be called when widget requests clipboard string.
	dstring delegate() _getClipboardStringCallback;

public:

	this(IGuiRenderer guiRenderer, TimerManager timerMan, TemplateManager templateMan, GuiSkin skin)
	in
	{
		assert(guiRenderer);
		assert(skin);
		assert(timerMan);
	}
	body
	{
		_guiRenderer = guiRenderer;
		_timerManager = timerMan;
		_templateManager = templateMan;
		_wman = WidgetManager(this);
	}

	void addRoot(Widget root)
	{
		root.setProperty!"size"(cast(ivec2)_guiRenderer.renderer.windowSize);
		roots ~= root;
	}

	/// Returns widget found by given id.
	Widget getWidgetById(string id)
	{
		return _wman.getWidgetById(id);
	}

	Widget createWidget(string type, Widget parent = null)
	{
		return _wman.createWidget(type, parent);
	}

//+-------------------------------------------------------------------------------+
//|                                  Properties                                   |
//+-------------------------------------------------------------------------------+

@property
{
	TemplateManager templateManager()
	{
		return _templateManager;
	}

	IGuiRenderer guiRenderer()
	{
		return _guiRenderer;
	}

/// Sets new size for all root widgets.
	void size(ivec2 newSize)
	{
		foreach(widget; roots)
		{
			widget.setProperty!"size"(newSize);
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
				//write("focused ", widget, " ");
				//write(widget["name"], " ", widget["type"]);
			}
			//writeln;

			_focusedWidget = widget;
		}
	}

	/// Used to get current clipboard string
	string clipboardString()
	{
		if (_getClipboardStringCallback !is null) 
			return to!string(_getClipboardStringCallback());
		else
			return "";
	}

	/// Used to set current clipboard string
	void clipboardString(string newString)
	{
		if (_setClipboardStringCallback !is null) 
			_setClipboardStringCallback(to!dstring(newString));
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

	void draw()
	{
		auto event = new DrawEvent(_guiRenderer);
		event.context = this;

		foreach(root; roots)
		{
			root.propagateEventSinkBubbleTree(event);
		}
	}

	/// Handler for key press event.
	/// 
	/// Must be called by user application.
	bool keyPressed(in KeyCode key, uint modifiers)
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
	bool keyReleased(in KeyCode key, uint modifiers)
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
		lastPointerPosition = pointerPosition;

		auto event = new PointerPressEvent(pointerPosition, button);
		event.context = this;
		
		foreach_reverse(rootWidget; roots)
		{
			Widget[] widgetChain = buildPathToLeaf!(containsPointer)(rootWidget, pointerPosition);

			Widget[] eventConsumerChain = propagateEventSinkBubble(widgetChain, event);

			if (eventConsumerChain.length > 0)
			{
				if (eventConsumerChain[$-1].getPropertyAs!("isFocusable", bool))
					focusedWidget = eventConsumerChain[$-1];
				
				pressedWidget = eventConsumerChain[$-1];
				
				return false;
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
		lastPointerPosition = pointerPosition;

		scope event = new PointerReleaseEvent(pointerPosition, button);
		event.context = this;

		root_loop:
		foreach_reverse(rootWidget; roots)
		{
			Widget[] widgetChain = buildPathToLeaf!(containsPointer)(rootWidget, pointerPosition);

			foreach_reverse(item; widgetChain) // test if pointer over pressed widget.
			{
				if (item is pressedWidget)
				{
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
					}

					pressedWidget = null;

					return true;
				}
			}
		}

		if (pressedWidget !is null) // no one handled event. Let's pressed widget know that pointer released.
		{
			pressedWidget.handleEvent(event); // pressed widget will know if pointer unpressed somwhere else.

			scope moveEvent = new PointerMoveEvent(pointerPosition, ivec2(0, 0));
			moveEvent.context = this;
			updateHovered(moveEvent); // So widget knows if pointer released not over it.
		}

		pressedWidget = null;
	
		return false;
	}


	/// Handler for pointer move event.
	/// 
	/// Must be called by user application.
	bool pointerMoved(ivec2 newPointerPosition, ivec2 delta)
	{	
		lastPointerPosition = newPointerPosition;

		scope event = new PointerMoveEvent(newPointerPosition, delta);
		event.context = this;
		
		if (pressedWidget !is null)
		{
			bool handled = pressedWidget.handleEvent(event);

			if (handled)
			{
				hoveredWidget = pressedWidget;

				return true;
			}
		}
		else
		{	
			if (updateHovered(event))
				return true;
		}

		hoveredWidget = null;
		
		return false;
	}

	bool updateHovered(PointerMoveEvent event)
	{
		foreach_reverse(rootWidget; roots)
		{
			Widget[] widgetChain = buildPathToLeaf!(containsPointer)(rootWidget, event.pointerPosition);

			Widget[] eventConsumerChain = propagateEventSinkBubble(widgetChain, event);

			if (eventConsumerChain.length > 0)
			{
				hoveredWidget = eventConsumerChain[$-1];

				return true;
			}
		}

		hoveredWidget = null;

		return false;
	}
}