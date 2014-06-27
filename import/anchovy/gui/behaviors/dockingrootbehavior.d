/**
Copyright: Copyright (c) 2013 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.dockingrootbehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;
import std.math : abs;

// version = Button_debug;

enum dragTreshold = 10;

class DockingRootBehavior : IWidgetBehavior
{
protected:
	Widget _dockingRoot;
	Widget _undockedStorage;
	Rect _dropRect;
	Widget _hoveredDocked;
	Widget _hoveredDockedParent;
	Sides _hoveredSide;
	VerticalLayout vlayout;
	HorizontalLayout hlayout;
	HorizontalLayout boxlayout;

public:

	this()
	{
		vlayout = new VerticalLayout;
		hlayout = new HorizontalLayout;
		boxlayout = new HorizontalLayout;
	}

	override void attachTo(Widget widget)
	{
		_dockingRoot = widget;
		_dockingRoot.addEventHandler(&handleDraw);
		_dockingRoot["isDocked"] = true;
	}

	void registerUndockedStorage(Widget storage)
	{
		assert(storage);

		_undockedStorage = storage;
	}

	void registerFrame(Widget frame)
	{
		assert(frame);
		assert(_undockedStorage);

		frame["isDocked"] = false;

		// extract frame header
		auto frameHeader = frame["subwidgets"].get!(Widget[string]).get("header", null);

		if (frameHeader && frameHeader.getWidgetBehavior!DragableBehavior)
		{
			// replace handler
			frameHeader.removeEventHandlers!DragEvent;
			frameHeader.addEventHandler(&handleFrameHeaderDrag);
			frameHeader.addEventHandler(&handleFrameHeaderDragEnd);
		}

		_undockedStorage.addChild(frame);
	}

	bool handleFrameHeaderDrag(Widget frameHeader, DragEvent event)
	{
		Widget frame = frameHeader["root"].get!Widget;

		if (frame["isDocked"].get!bool == true)
		{
			if (abs(event.delta.x) > dragTreshold || abs(event.delta.y) > dragTreshold)
			{
				handleUndock(frame);
				// Center header after undocking
				ivec2 newPosition = event.pointerPosition - frame.getPropertyAs!("prefSize", ivec2) / 2;
				frame["position"] = newPosition;
				event.dragOffset = event.pointerPosition - newPosition;
			}
		}
		else
		{
			frame["position"] = frame.getPropertyAs!("position", ivec2) + event.delta;
			checkForDropAt(event.pointerPosition);
		}

		return true;
	}

	bool handleFrameHeaderDragEnd(Widget frameHeader, DragEndEvent event)
	{
		Widget frame = frameHeader["root"].get!Widget;

		if (_hoveredDocked)
		{
			handleDock(frame, _hoveredDocked, _hoveredDockedParent, _hoveredSide);
		}

		return true;
	}

	void checkForDropAt(ivec2 position)
	{
		Widget[] widgetChain = buildPathToLeaf!(EventDispatcher.containsPointer)(_dockingRoot, position);

		_hoveredDocked = null;
		_hoveredDockedParent = null;

		// Find docked widget
		foreach_reverse(widget; widgetChain)
		{
			if (widget.hasProperty!"isDocked" && widget.getPropertyAs!("isDocked", bool))
			{
				_hoveredDocked = widget;
				break;
			}
		}

		Rect widgetRect;

		// If docked is found get its rect, or return otherwise
		if (_hoveredDocked)
		{
			widgetRect = _hoveredDocked.getPropertyAs!("staticRect", Rect);
			if (_hoveredDocked !is _dockingRoot)
			{
				_hoveredDockedParent = _hoveredDocked.getPropertyAs!("parent", Widget);
			}
		}
		else
		{
			return;
		}

		// Find corner positions
		ivec2 leftTop = widgetRect.position;
		ivec2 rightBottom = widgetRect.position + widgetRect.size;
		ivec2 rightTop = widgetRect.position;
			rightTop.x += widgetRect.size.x;
		ivec2 leftBottom = widgetRect.position;
			leftBottom.y += widgetRect.size.y;

		// Find the sector of rect hit by cursor
		// \T/
		// LXR
		// /B\

		// D = (х3 - х1) * (у2 - у1) - (у3 - у1) * (х2 - х1)
		// diagonal \
		int cursorPos1 = (position.x - leftTop.x) * (rightBottom.y - leftTop.y)
						- (position.y - leftTop.y) * (rightBottom.x - leftTop.x);

		// diagonal /
		int cursorPos2 = (position.x - leftBottom.x) * (rightTop.y - leftBottom.y)
						- (position.y - leftBottom.y) * (rightTop.x - leftBottom.x);

		// Calculate rect that will be highlighted
		_dropRect = widgetRect;

		if (cursorPos1 > 0) //right top
		{
			if (cursorPos2 > 0) // left top
			{
				_dropRect.height /= 2;
				_hoveredSide = Sides.top;
			}
			else // right bottom
			{
				_dropRect.width /= 2;
				_dropRect.x += _dropRect.width;
				_hoveredSide = Sides.right;
			}
		}
		else // left bottom
		{
			if (cursorPos2 > 0) // left top
			{
				_dropRect.width /= 2;
				_hoveredSide = Sides.left;
			}
			else // right bottom
			{
				_dropRect.height /= 2;
				_dropRect.y += _dropRect.height;
				_hoveredSide = Sides.bottom;
			}
		}
	}

	void handleDock(Widget floating, Widget docked, Widget dockedParent, Sides side)
	{
		assert(docked);

		writeln("dock");
		floating["isDocked"] = true;
		floating.detachFromParent;

		// Drop over the empty dockRoot
		if (!dockedParent)
		{
			docked.addChild(floating);
			docked.setProperty!("layout", ILayout)(boxlayout);
		}
		else
		{

		}

		_hoveredDocked = null;
		_hoveredDockedParent = null;
	}

	void handleUndock(Widget docked)
	{
		writeln("undock");

		docked.detachFromParent;
		_undockedStorage.addChild(docked);
		
		docked["isDocked"] = false;
	}

	bool handleDraw(Widget dockRoot, DrawEvent event)
	{
		if (_hoveredDocked)
		{
			event.guiRenderer.renderer.setColor(Color(0,0,255, 64));
			event.guiRenderer.renderer.fillRect(_dropRect);
		}

		return true;
	}
}

