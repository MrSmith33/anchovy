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

module anchovy.gui.gui;

import anchovy.gui.all;

class Gui
{
public:

	this(IGuiRenderer guiRenderer, TimerManager timerManager, GuiSkin globalSkin)
	in
	{
		assert(guiRenderer);
		assert(globalSkin);
		assert(timerManager);
	}
	body
	{
		//super(rect, "", globalSkin);
		//_staticRect = rect;

		_guiRenderer = guiRenderer;
		_timerManager = timerManager;
	}
	
	void addChild(IWidget widget)
	{
		_rootWidgets ~= widget;
	}
	
//+-------------------------------------------------------------------------------+
//|                                Event handling                                 |
//+-------------------------------------------------------------------------------+

	static bool containsPointer(Event event, IWidget widget)
	{
		return widget.staticRect.contains((cast(PointerButtonEvent)event).pointerPosition);
	}

	void handleEvent(Event event)
	{
		foreach(widget; _rootWidgets)
		{
			widget.recursiveHandleEvent(event);
		}
	}
	
	void draw()
	{

		//glScissor(0, 0, _rect.width, _rect.height);
	}

	/// Handler for key press event.
	/// 
	/// Must be called by user application.
	bool keyPressed(in KeyCode key, KeyModifiers modifiers)
	{
		/*if (_focusedWidget !is null)
		{
			_focusedWidget.keyPressed(key, modifiers);
			return true;
		}*/
		return false;
	}

	/// Handler for key release event.
	/// 
	/// Must be called by user application.
	bool keyReleased(in KeyCode key, KeyModifiers modifiers)
	{
		/*
		if (_focusedWidget !is null)
		{
			_focusedWidget.keyReleased(key, modifiers);
			return true;
		}*/
		return false;
	}

	/// Handler for char enter event.
	/// 
	/// Must be called by user application.
	bool charEntered(in dchar chr)
	{
		/*
		if (_focusedWidget !is null)
		{
			_focusedWidget.charEntered(chr);
			return true;
		}*/
		return false;
	}

	/// Handler for pointer press event.
	/// 
	/// Must be called by user application.
	bool pointerPressed(ivec2 pointerPosition, PointerButton button)
	{	
		EventPropagator propagator;
		auto event = new PointerPressEvent(pointerPosition, button);
		event.gui = this;
		

		
		foreach_reverse(rootWidget; _rootWidgets)
		{
			if (propagator.propagateEvent!(containsPointer)(event, rootWidget))
				break;
		}

		return false;
	}

	/// Handler for pointer release event.
	/// 
	/// Must be called by user application.
	bool pointerReleased(ivec2 pointerPosition, PointerButton button)
	{

		return false;
	}


	/// Handler for pointer move event.
	/// 
	/// Must be called by user application.
	bool pointerMoved(ivec2 newPointerPosition)
	{
		return false;
	}

//+-------------------------------------------------------------------------------+
//|                                  Properties                                   |
//+-------------------------------------------------------------------------------+

	
	/// Used to get last clicked widget
	IWidget lastClickedWidget() @property @safe pure
	{
		return _lastClickedWidget;
	}

	/// Used to set last clicked widget
	void lastClickedWidget(IWidget widget) @property @safe pure
	{
		_lastClickedWidget = widget;
	}

	/// Used to get current hovered widget
	IWidget hoveredWidget() @property @safe pure
	{
		return _hoveredWidget;
	}

	/// Used to set current hovered widget
	void hoveredWidget(IWidget widget) @property @trusted
	{
		if (_hoveredWidget !is widget)
		{
			if (_hoveredWidget !is null)
			{
				auto event = new PointerLeaveEvent;
				event.gui = this;
				_hoveredWidget.handleEvent(event);
			}
			if (widget !is null)
			{
				auto event = new PointerEnterEvent;
				event.gui = this;
				widget.handleEvent(event);
			}
			_hoveredWidget = widget;
		}
	}

	/// Used to get current focused input owner widget
	IWidget inputOwnerWidget() @property @safe pure
	{
		return _inputOwnerWidget;
	}

	/// Used to set current focused input owner widget
	void inputOwnerWidget(IWidget widget) @property @trusted
	{
		debug writeln("new input owner widget ", widget);
		_inputOwnerWidget = widget;
	}

	/// Used to get current focused widget
	IWidget focusedWidget() @property @safe pure
	{
		return _focusedWidget;
	}

	/// Used to set current focused widget
	void focusedWidget(IWidget widget) @property
	{
		if (_focusedWidget !is widget)
		{
			if (_focusedWidget !is null)
			{
				auto event = new FocusLoseEvent;
				event.gui = this;
				_focusedWidget.handleEvent(event);
			}
			if (widget !is null)
			{
				auto event = new FocusGainEvent;
				event.gui = this;
				widget.handleEvent(event);
			}
			_focusedWidget = widget;
		}
	}

	/// Used to get current clipboard string
	dstring clipboardString() @property
	{
		if (_getClipboardStringCallback !is null) 
			return _getClipboardStringCallback();
		else
			return "";
	}

	/// Used to set current clipboard string
	void clipboardString(dstring newString) @property
	{
		if (_setClipboardStringCallback !is null) 
			_setClipboardStringCallback(newString);
	}

	/// Will be used by window to provide clipboard functionality.
	void getClipboardStringCallback(dstring delegate() callback) @property
	{
		_getClipboardStringCallback = callback;
	}

	/// ditto
	void setClipboardStringCallback(void delegate(dstring) callback) @property
	{
		_setClipboardStringCallback = callback;
	}

	/// Used to set currently checked radio button in the group.
	/// Previous checked radio button in specified group will be unchecked.
	/*void setCheckedForGroup(uint group, RadioButton rbutton)
	{
		if ((group in _checkGroups) !is null)
		{
			_checkGroups[group].isChecked = false;
		}
		_checkGroups[group] = rbutton;

		if (rbutton !is null)
			rbutton.isChecked = true;
	}*/

	TimerManager timerManager() @property
	{
		return _timerManager;
	}

	KeyModifiers modifiers; /// TODO: Incapsulation


	protected:


	/// Gui renderer used for drawing all children widgets.
	IGuiRenderer	_guiRenderer;

	/// Used for timers.
	TimerManager	_timerManager;

	/// Current input owner If set, this widget will receive all pointer moved events.
	/// See_Also: inputOwnerWidget
	IWidget		_inputOwnerWidget;

	/// Currently dragging widget. Will receive onDrag events.
	IWidget		_draggingWidget;

	/// Last clicked widget. Used for double-click checking.
	/// See_Also: lastClickedWidget
	IWidget		_lastClickedWidget;

	/// Hovered widget. Widget over which pointer is located.
	/// See_Also: hoveredWidget
	IWidget		_hoveredWidget;

	/// Focused widget.
	/// 
	/// Will receive all key events if input is not grabbed by other widget.
	IWidget		_focusedWidget;

	/// Stores checked radio button for each radio group.
	/// See_Also: setCheckedForGroup
	//RadioButton[uint] _checkGroups;

	IWidget[] _rootWidgets;

	/// This will be called when widget sets clipboard string.
	void delegate(dstring newClipboardString) _setClipboardStringCallback;

	/// This will be called when widget requests clipboard string.
	dstring delegate() _getClipboardStringCallback;
}