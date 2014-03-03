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

class TestApplication : Application!GlfwWindow
{
	this(uvec2 windowSize, string caption)
	{
		super(windowSize, caption);
	}

	override void load(in string[] args)
	{
		fpsHelper.limitFps = false;

		// ----------------------------- Creating widgets -----------------------------
		templateManager.parseFile("test.sdl");

		auto mainLayer = context.createWidget("mainLayer");
		context.addRoot(mainLayer);

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

		auto fpsLabel = context.getWidgetById("fpsLabel");
		auto fpsSlot = (FpsHelper* helper){fpsLabel["text"] = to!string(helper.fps);};
		fpsHelper.fpsUpdated.connect(fpsSlot);

		auto firstName = context.getWidgetById("firstName");
		auto lastName = context.getWidgetById("lastName");
		auto fullName = context.getWidgetById("fullName");
		auto calc = (FlexibleObject a, Variant b){fullName["text"] = firstName["text"].coerce!dstring ~ " "d
			 ~ lastName["text"].coerce!dstring;};
		firstName.property("text").valueChanged.connect(calc);
		lastName.property("text").valueChanged.connect(calc);

		auto horiText = context.getWidgetById("hori-pos");
		auto vertText = context.getWidgetById("vert-pos");
		auto updateHori = (FlexibleObject a, Variant b){horiText["text"] = to!string(b);};
		auto updateVert = (FlexibleObject a, Variant b){vertText["text"] = to!string(b);};

		auto horiScroll = context.getWidgetById("hori-scroll");
		horiScroll.property("sliderPos").valueChanged.connect(updateHori);
		auto vertScroll = context.getWidgetById("vert-scroll");
		vertScroll.property("sliderPos").valueChanged.connect(updateVert);

		horiScroll["sliderPos"] = 0.2;
		vertScroll["sliderPos"] = 0.3;

		writeln("\n----------------------------- Load end -----------------------------\n");
	}

	override void closePressed()
	{
		isRunning = false;
	}
}