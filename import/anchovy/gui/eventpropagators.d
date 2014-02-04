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

module anchovy.gui.eventpropagators;

import std.traits;
import anchovy.gui.all;

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

void propagateEventChildrenFirst(Widget root, Event event)
{
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