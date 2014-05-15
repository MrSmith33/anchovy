/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.radiobehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

version = Radio_debug;


class RadioBehavior : CheckBehavior
{
	override void attachPropertiesTo(Widget widget)
	{
		super.attachPropertiesTo(widget);
		widget.setProperty!("group", int) = 0;
		widget.property("group").valueChanged.connect(&onGroupChanged);
		widget.property("isChecked").valueChanged.connect(&onCheckedChanged);
	}

	override void attachTo(Widget widget)
	{
		widget.addEventHandler(&handleGroupSelectionChanged);
		super.attachTo(widget);
	}

	override bool onClick(Widget widget, PointerClickEvent event)
	{
		widget.setProperty!"isChecked"(true);

		return true;
	}

	void onCheckedChanged(FlexibleObject a, Variant b)
	{
		auto context = a.getPropertyAs!("context", GuiContext);
		auto groupId = a.getPropertyAs!("group", int);

		auto selected = context.widgetManager.getGroupSelected(groupId);

		if (b == false && selected is a)
		{
			context.widgetManager.setGroupSelected(groupId, null);
		}
		else if (b == true)
		{
			context.widgetManager.setGroupSelected(groupId, cast(Widget)a);
		}
	}

	void onGroupChanged(FlexibleObject a, Variant b)
	{
		auto groupId = a.getPropertyAs!("group", int);
		writefln("group changed %s", groupId);
		a.setProperty!("isChecked", bool)(false);
	}

	bool handleGroupSelectionChanged(Widget widget, GroupSelectionEvent event)
	{
		version(Radio_debug) "selected changed %s %s".writefln(event.selected, event.selected is widget);
		widget.setProperty!("isChecked", bool)(event.selected is widget);

		return true;
	}
}