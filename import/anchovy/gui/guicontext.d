/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.guicontext;

import anchovy.gui;

//version = Debug_guicontext;

class GuiContext
{
	alias WidgetCreator = Widget delegate();
	alias LayoutCreator = ILayout delegate();
	alias BehaviorCreator = IWidgetBehavior delegate();

	WidgetCreator[string] widgetFactories;
	LayoutCreator[string] layoutFactories;
	BehaviorCreator[][string] behaviorFactories;

protected:

	Widget[] _roots;
	Widget _overlay;

	// Key modifiers
	uint modifiers;

	/// Gui renderer used for drawing all children widgets.
	IGuiRenderer	_guiRenderer;

	/// Used for timers.
	TimerManager	_timerManager;

	TemplateManager _templateManager;

	WidgetManager _wman;

	EventDispatcher _eventDispatcher;

	TooltipManager _tooltipManager;

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
		_eventDispatcher = EventDispatcher(this);
		_tooltipManager = TooltipManager(this);

		_overlay = createWidget("widget");
		_overlay["isVisible"] = false;
		_overlay.setProperty!("layout", ILayout) = new AbsoluteLayout;
	}

	void update(double deltaTime)
	{
		_eventDispatcher.update(deltaTime);
	}

	void addRoot(Widget root)
	{
		root.setProperty!"size"(cast(ivec2)_guiRenderer.renderer.windowSize);
		_roots ~= root;
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
	Widget overlay()
	{
		return _overlay;
	}

	auto roots()
	{
		import std.range : chain, repeat;

		return chain(_roots, _overlay.repeat(1));
	}

	TemplateManager templateManager()
	{
		return _templateManager;
	}

	TimerManager timerManager()
	{
		return _timerManager;
	}

	ref WidgetManager widgetManager()
	{
		return _wman;
	}

	ref EventDispatcher eventDispatcher()
	{
		return _eventDispatcher;
	}

	ref TooltipManager tooltipManager()
	{
		return _tooltipManager;
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
}
}