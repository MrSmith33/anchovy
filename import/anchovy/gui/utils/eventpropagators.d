/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.utils.eventpropagators;

import std.traits;
import anchovy.gui;

/// 
enum PropagatingStrategy
{
	/// First visits parent then child until target is reached.
	/// Then sets event's bubbling flag to true and visits widgets from
	/// target to root.
	SinkBubble,

	/// First visits target then its parent etc, until reaches root.
	/// Then sets event's sinking flag to true and visits widgets from root to target.
	BubbleSink,

	/// Visit all the subtree from bottom up. parent gets visited after all its children was visited.
	/// Also called Pre-order.
	ChildrenFirst,

	/// Visits all subtree from root to leafs, visiting parent first and then all its subtrees. Depth-first.
	/// Also called Post-order.
	ParentFirst
}

enum OnHandle
{
	StopTraversing,
	ContinueTraversing
}

Widget[] propagateEventSinkBubble(OnHandle onHandle = OnHandle.StopTraversing)(Widget[] widgets, Event event)
{
	// Phase 1: event sinking to target.
	event.sinking = true;

	foreach(index, widget; widgets)
	{
		event.handled = event.handled || widget.handleEvent(event);

		static if(onHandle == OnHandle.StopTraversing)
		{
			if (event.handled) return widgets[0..index+1];
		}
	}

	// Phase 2: event bubling from target.
	event.bubbling = true;
	foreach_reverse(index, widget; widgets)
	{
		event.handled = event.handled || widget.handleEvent(event);
		
		static if(onHandle == OnHandle.StopTraversing)
		{
			if (event.handled) return widgets[0..index+1];
		}
	}

	return [];
}

void propagateEventParentFirst(Widget root, Event event)
{
	event.sinking = true;

	void propagateEvent(Widget root)
	{
		root.handleEvent(event);
		
		foreach(child; root.getPropertyAs!("children", Widget[]))
		{
			propagateEvent(child);
		}
	}

	propagateEvent(root);
}

void propagateEventSinkBubbleTree(Widget root, Event e)
{
	e.sinking = true;
	root.handleEvent(e);

	foreach (widget; root.getPropertyAs!("children", Widget[]))
	{
		e.sinking = true;
		widget.propagateEventSinkBubbleTree(e);
	}
	
	e.bubbling = true;
	root.handleEvent(e);
}

void propagateEventChildrenFirst(Widget root, Event event)
{
	event.bubbling = true;

	void propagateEvent(Widget root)
	{
		foreach(child; root.getPropertyAs!("children", Widget[]))
		{
			propagateEvent(child);
		}

		root.handleEvent(event);
	}

	propagateEvent(root);
}

/// Tests all root's children with pred.
/// Then calls itself with found child.
/// Adds widgets satisfying pred to returned array.
/// Root widget is added first.
/// Can be used to find widget that is under cursor
/// Parameters:
///   pred function like bool fun(Widget widget, ...)
///   root root of widget subtree/tree
Widget[] buildPathToLeaf(alias pred, T...)(Widget root, T data)
{
	Widget[] path;

	bool traverse(Widget root)
	{
		if(!pred(root, data)) return false;
		
		path ~= root;

		foreach(child; root.getPropertyAs!("children", Widget[]))
		{
			if (traverse(child))
			{
				return true;
			}
		}

		return true;
	}

	traverse(root);

	return path;
}