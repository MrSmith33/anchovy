/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module testapplication;

import std.stdio : writeln;

import anchovy.graphics.windows.glfwwindow;
import anchovy.gui;

import anchovy.gui.application.application;
import anchovy.gui.databinding.list;

class TestApplication : Application!GlfwWindow
{
	override void load(in string[] args)
	{
		writeln("---------------------- System info ----------------------");
		foreach(item; getHardwareInfo())
			writeln(item);
		writeln("---------------------------------------------------------\n");

		fpsHelper.limitFps = false;

		// ----------------------------- Creating widgets -----------------------------
		templateManager.parseFile("example01.sdl");

		auto mainLayer = context.createWidget("mainLayer");
		context.addRoot(mainLayer);

		auto frameLayer = context.createWidget("frameLayer");
		context.addRoot(frameLayer);

		auto frame = context.getWidgetById("test-frame");
		Widget closeButton = frame["subwidgets"].get!(Widget[string])["close"];
		closeButton.addEventHandler(delegate bool(Widget widget, PointerClickEvent event){
			frame["isVisible"] = false;
			return true;
		});

		context.getWidgetById("showFrame").addEventHandler(delegate bool(Widget widget, PointerClickEvent event){
			frame["isVisible"] = true;
			return true;
		});

		auto button1 = context.getWidgetById("button1");
		button1.addEventHandler(delegate bool(Widget widget, PointerClickEvent event){
			widget["text"] = to!string(event.pointerPosition);
			writeln("Clicked at ", event.pointerPosition);
			return true;
		});
		button1.addEventHandler(delegate bool(Widget widget, PointerLeaveEvent event)
			{widget["text"] = "Click me!"; return true;});

		auto image = context.getWidgetById("fontTexture");
		image.setProperty!("texture")(guiRenderer.getFontTexture);

		auto firstName = context.getWidgetById("firstName");
		auto lastName = context.getWidgetById("lastName");
		auto fullName = context.getWidgetById("fullName");
		auto calc = delegate(Variant firstName, Variant lastName) => Variant(firstName.coerce!dstring ~ " "d
			 ~ lastName.coerce!dstring);

		fullName.property("text").pipeFrom(calc, firstName.property("text"), lastName.property("text"));

		auto showTooltip = context.getWidgetById("showTooltip");
		showTooltip.addEventHandler(delegate bool(Widget widget, PointerClickEvent event){
			context.tooltipManager.showTooltip("It's a tooltip!!!", ivec2(10, 10));
			return true;
		});
		auto hideTooltip = context.getWidgetById("hideTooltip");
		hideTooltip.addEventHandler(delegate bool(Widget widget, PointerClickEvent event){
			context.tooltipManager.hideTooltip();
			return true;
		});

		auto horiText = context.getWidgetById("hori-pos");
		auto vertText = context.getWidgetById("vert-pos");

		auto horiScroll = context.getWidgetById("hori-scroll");
		horiScroll.property("sliderPos").bindTo(horiText.property("text"), (Variant val) => Variant(to!string(val)));
		auto vertScroll = context.getWidgetById("vert-scroll");
		vertScroll.property("sliderPos").bindTo(vertText.property("text"), (Variant val) => Variant(to!string(val)));

		auto list = new SimpleList!dstring;

		auto stringList = context.getWidgetById("stringlist");

		stringList.setProperty!("list", List!dstring)(list);

		ulong counter = 0;

		list.push("first");
		list.push("second");
		list.push("third");
		list.push("fourth");

		auto fpsLabel = context.getWidgetById("fpsLabel");
		auto fpsSlot = (FpsHelper* helper){fpsLabel["text"] = "FPS: "~to!string(helper.fps); list.push(to!dstring(++counter)~": "~to!dstring(helper.fps));};
		fpsHelper.fpsUpdated.connect(fpsSlot);

		//printTree();

		writeln("\n----------------------------- Load end -----------------------------\n");
	}

	override void closePressed()
	{
		isRunning = false;
	}
}
