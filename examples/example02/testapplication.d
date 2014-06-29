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
	this(uvec2 windowSize, string caption)
	{
		super(windowSize, caption);
	}

	DockingRootBehavior dockManager;
	size_t frameCounter;

	void addFrame()
	{
		auto frame = context.createWidget("frame");
		frame["caption"] = "Frame " ~ to!string(frameCounter++);
		frame["minSize"] = ivec2(100, 100);

		dockManager.registerFrame(frame);
	}

	override void load(in string[] args)
	{
		writeln("---------------------- System info ----------------------");
		foreach(item; getHardwareInfo())
			writeln(item);
		writeln("---------------------------------------------------------\n");

		fpsHelper.limitFps = false;

		// ----------------------------- Creating widgets -----------------------------
		templateManager.parseFile("test2.sdl");

		auto mainLayer = context.createWidget("mainLayer");
		context.addRoot(mainLayer);

		auto frameLayer = context.createWidget("frameLayer");
		context.addRoot(frameLayer);

		context.getWidgetById("createFrame")
			.addEventHandler(
				delegate bool(Widget w, PointerClickEvent e){
					addFrame();
					return true;
			});

		context.getWidgetById("printTree")
			.addEventHandler(
				delegate bool(Widget w, PointerClickEvent e){
					printTree();
					return true;
			});

		auto dockingRoot = context.getWidgetById("dockingroot");

		dockManager = cast(DockingRootBehavior)dockingRoot.getWidgetBehavior!DockingRootBehavior;
		dockManager.registerUndockedStorage(frameLayer);

		addFrame();


		writeln("\n----------------------------- Load end -----------------------------\n");
	}

	override void closePressed()
	{
		isRunning = false;
	}
}