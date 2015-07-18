/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.eventdispatcher;

import anchovy.gui;

struct EventDispatcher
{
private:
	GuiContext _context;

	ivec2 _lastPointerPosition = ivec2(int.max, int.max);

	/// Current input owner If set, this widget will receive all pointer moved events.
	/// See_Also: inputOwnerWidget
	Widget		_inputOwnerWidget;

	/// Currently dragging widget. Will receive onDrag events.
	Widget		_draggingWidget;

	/// Last clicked widget. Used for double-click checking.
	/// See_Also: lastClickedWidget
	Widget		_lastClickedWidget;

	/// Currently pressed widget
	Widget		_pressedWidget;

	/// Hovered widget. Widget over which pointer is located.
	/// See_Also: hoveredWidget
	Widget		_hoveredWidget;

	/// Focused widget.
	///
	/// Will receive all key events if input is not grabbed by other widget.
	Widget		_focusedWidget;

	bool isLayoutValid; // Will be updated in update method

public:

	@disable this();

	this(GuiContext context)
	{
		_context = context;
	}

@property
{
	ivec2 lastPointerPosition()
	{
		return _lastPointerPosition;
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
				event.context = _context;
				_hoveredWidget.handleEvent(event);
			}

			if (widget !is null)
			{
				auto event = new PointerEnterEvent;
				event.context = _context;
				widget.handleEvent(event);
			}

			_context.tooltipManager.onWidgetHovered(widget);
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
				event.context = _context;
				_focusedWidget.handleEvent(event);
			}

			if (widget !is null)
			{
				auto event = new FocusGainEvent;
				event.context = _context;
				widget.handleEvent(event);
			}

			_focusedWidget = widget;
		}
	}
}

	//+-------------------------------------------------------------------------------+
	//|                                Event handling                                 |
	//+-------------------------------------------------------------------------------+

	static bool containsPointer(Widget widget, ivec2 pointerPosition)
	{
		return widget.getPropertyAs!("staticRect", Rect).contains(pointerPosition);
	}

	void invalidateWidgetLayout(Widget container)
	{
		isLayoutValid = false;
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
				moveEvent.context = _context;
				updateHovered(moveEvent);
			}
		}
	}

	void doLayout()
	{
		foreach(root; _context.roots)
		{
			root.propagateEventChildrenFirst(new MinimizeLayoutEvent);
			root.propagateEventParentFirst(new ExpandLayoutEvent);
			root.propagateEventParentFirst(new UpdatePositionEvent);
		}
	}

	void draw()
	{
		auto event = new DrawEvent(_context.guiRenderer);
		event.context = _context;

		foreach(root; _context.roots)
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
			event.context = _context;
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
			event.context = _context;
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
			event.context = _context;
			_focusedWidget.handleEvent(event);
		}

		return false;
	}

	/// Handler for pointer press event.
	///
	/// Must be called by user application.
	bool pointerPressed(ivec2 pointerPosition, PointerButton button)
	{
		_lastPointerPosition = pointerPosition;

		auto event = new PointerPressEvent(pointerPosition, button);
		event.context = _context;

		foreach_reverse(rootWidget; _context.roots)
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
		_lastPointerPosition = pointerPosition;

		scope event = new PointerReleaseEvent(pointerPosition, button);
		event.context = _context;

		root_loop:
		foreach_reverse(rootWidget; _context.roots)
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
							clickEvent.context = _context;

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
			moveEvent.context = _context;
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
		_lastPointerPosition = newPointerPosition;

		scope event = new PointerMoveEvent(newPointerPosition, delta);
		event.context = _context;

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
		foreach_reverse(rootWidget; _context.roots)
		{
			Widget[] widgetChain = buildPathToLeaf!(containsPointer)(rootWidget, event.pointerPosition);

			foreach_reverse(widget; widgetChain)
			{
				if (widget.getPropertyAs!("respondsToPointer", bool))
				{
					hoveredWidget = widget;
					return true;
				}
			}
		}

		hoveredWidget = null;

		return false;
	}
}
