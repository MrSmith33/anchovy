/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.tooltipmanager;

import anchovy.gui;

struct TooltipManager
{
private:
	GuiContext _context;

	Widget _tooltip;
	Widget _overlay;

public:

	@disable this();

	this(GuiContext context)
	{
		_context = context;
	}

	void showTooltip(string text, ivec2 pos)
	{
		if (_tooltip is null)
		{
			_tooltip = _context.getWidgetById("tooltip");
			if (_tooltip is null)
			{
				_tooltip = _context.createWidget("tooltip");
			}
		}

		if (_overlay is null)
		{
			_overlay = _context.getWidgetById("overlay");
			if (_overlay is null)
			{
				_overlay = _context.createWidget("widget");
				_overlay["id"] = "overlay";
				_overlay["isVisible"] = false;
				_overlay.setProperty!("layout", ILayout) = new AbsoluteLayout;
				_context.addRoot(_overlay);
			}
		}

		_tooltip["text"] = text;
		_tooltip["position"] = pos;
		_tooltip["isVisible"] = true;
		_overlay.addChild(_tooltip);
	}

	void hideTooltip()
	{
		_overlay.removeChild(_tooltip);
	}
}