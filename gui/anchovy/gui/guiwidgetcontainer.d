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

module anchovy.gui.guiwidgetcontainer;

import anchovy.gui.all;

public import anchovy.gui.interfaces.ilayoutmanager;

/**
 * Widget that is used as a container for other widgets.
 * 
 * Can apply layout to its client area by using provided layout manager.
 */
class GuiWidgetContainer : GuiWidget
{
public:
	this(Rect rect, in string styleName, GuiSkin skin = null)
	{
		super(rect, styleName, skin);
	}

	void addWidget(GuiWidget widget)
	{
		widget.parent = this;
		widget.calcStaticRect(_staticRect);
		_children ~= widget;
	}

//+-------------------------------------------------------------------------------+
//|                                  Handlers                                     |
//+-------------------------------------------------------------------------------+

	override void calcStaticRect(Rect parentStaticRect)
	{
		_staticRect = _rect.relativeToParent(parentStaticRect);
		foreach_reverse(widget; _children)
		{
			widget.calcStaticRect(_staticRect);
		}
	}
	
	override void drawContent(IGuiRenderer renderer)
	{
		foreach(widget; _children)
		{
			widget.draw(renderer);
		}
	}
	
	override bool pointerPressed(ivec2 pointerPosition, PointerButton button)
	{
		if (!_staticRect.contains(pointerPosition)) return false;
		foreach_reverse(widget; _children)
		{
			if (widget.pointerPressed(pointerPosition, button))
			{
				return true;
			}
		}
		
		return false;
	}
	
	override bool pointerReleased(ivec2 pointerPosition, PointerButton button)
	{
		if (!_staticRect.contains(pointerPosition)) return false;
		foreach_reverse(widget; _children)
		{
			if (widget.pointerReleased(pointerPosition, button))
			{
				return true;
			}
		}
		window.hoveredWidget = this;
		return true;
	}
	
	override bool pointerMoved(ivec2 newPointerPosition)
	{		
		if (!_staticRect.contains(newPointerPosition)) return false;
		foreach_reverse(widget; _children)
		{
			if (widget.pointerMoved(newPointerPosition))
			{
				return true;
			}
		}
		
		return true;
	}


//+-------------------------------------------------------------------------------+
//|                                  Properties                                   |
//+-------------------------------------------------------------------------------+

	void layoutManager(ILayoutManager newLayoutManager) @property
	{
		_layoutManager = newLayoutManager;
		updateLayout();
	}

	/// Must return children array.
	GuiWidget[] children() @property
	{
		return _children;
	}

protected:

	override protected void skinChanged()
	{
		foreach (widget; _children)
		{
			widget.handleParentSkinChange();
		}
	}

	void updateLayout()
	{
	}

	void updateLayoutResize(ivec2 deltaSize)
	{
	}

	/// Used to layout children in client area.
	/// 
	/// If is null, no layout would be done. I.e. absolute positioning.
	ILayoutManager _layoutManager;

	///All the children of this widget.
	GuiWidget[]	_children;	
}

