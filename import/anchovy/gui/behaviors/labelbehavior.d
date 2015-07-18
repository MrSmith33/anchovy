/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.labelbehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;


class LabelBehavior : IWidgetBehavior
{
public:

	override void attachTo(Widget widget)
	{
		widget.removeEventHandlers!DrawEvent();
		widget.addEventHandler(&handleDraw);

		if (widget.peekPropertyAs!("text", string) is null)
			widget.setProperty!"text"("");
		if (widget.peekPropertyAs!("fontName", string) is null)
			widget.setProperty!"fontName"("normal");

		GuiContext context = widget.getPropertyAs!("context", GuiContext);

		TextLine line = context.guiRenderer.createTextLine(widget.getPropertyAs!("fontName", string));

		widget.setProperty!"line"(line);
		widget.setProperty!"prefSize"(line.size);

		widget.property("text").valueChanged.connect(&onTextChanged);
	}

	void onTextChanged(FlexibleObject obj, Variant newText)
	{
		auto str = newText.coerce!dstring;

		TextLine line = obj.getPropertyAs!("line", TextLine);

		line.text = str;

		obj["prefSize"] = line.size;
		invalidateLayout(cast(Widget)obj);
	}

	bool handleDraw(Widget widget, DrawEvent event)
	{
		if (event.sinking && widget["isVisible"] == true)
		{
			event.guiRenderer.renderer.setColor(Color(0, 0, 0, 255));
			event.guiRenderer.drawTextLine(widget.getPropertyAs!("line", TextLine),
				widget.getPropertyAs!("staticPosition", ivec2), AlignmentType.LEFT_TOP);
		}

		return true;
	}
}
