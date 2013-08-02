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

module anchovy.gui.eventpropagator;

import std.traits;
import anchovy.gui.all;

/// Helper struct for propagating event through widget tree.
///
/// Event propagation results in a list of widgets stored in eventConsumerChain.
/// Widgets are arranged in the order from widget that originally has handled event to the root widget.
struct EventPropagator
{
	/// Widget chain that have handled event.
	///
	/// Actual event consumer is first, its parent second...
	IWidget[] eventConsumerChain;

	/// does actual event propagation.
	///
	/// Returns: true if event was handled.
	bool propagateEvent(alias fun, Event, IWidget)(Event event, IWidget widget)
	{
		bool widgetHandledEvent;
		
		// Phase 1: event sinking into widget.
		event.sinking = true;
		
		widgetHandledEvent = widget.handleEvent(event);
		if (widgetHandledEvent)
		{
			eventConsumerChain ~= widget;
			return true;
		}

		// Phase 2: event sinking into each widget's child.
		bool anyChildHandledEvent = false;
		foreach (child; widget.children)
		{
			event.sinking = true;
			anyChildHandledEvent |= propagateEvent!(fun)(event, child);
		}
		
		// Phase 3: event bubling into widget.
		event.sinking = false;
		
		widgetHandledEvent = widget.handleEvent(event);
		
		if (widgetHandledEvent || anyChildHandledEvent)
		{
			eventConsumerChain ~= widget;
			return true;
		}
		
		return false;
	}
}