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
	
public:

	@disable this();

	this(GuiContext context)
	{
		_context = context;
	}

	void onWidgetHovered(Widget widget)
	{
		if (widget is null)
		{
			hideTooltip();

			return;
		}

		if (widget.hasProperty("tooltip"))
		{
			showTooltip(widget.coercePropertyAs!("tooltip", string),
				_context.eventDispatcher.lastPointerPosition() + ivec2(0, 20));
		}
		else
		{
			hideTooltip();
		}
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

		_tooltip["text"] = text;
		_tooltip["position"] = pos;
		_context.overlay.addChild(_tooltip);
	}

	void hideTooltip()
	{
		_context.overlay.removeChild(_tooltip);
	}
}