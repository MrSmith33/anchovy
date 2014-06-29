/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.application.application;

import std.stdio : writeln;
import anchovy.core.interfaces.iwindow;
import anchovy.gui;

public import anchovy.gui.application.eventaggregator;
public import anchovy.gui.application.fpshelper;

class Application(WindowType)
{
	IWindow window;
	EventAggregator!WindowType aggregator;
	FpsHelper fpsHelper;
	TimerManager timerManager;
	bool isRunning = true;

	IRenderer renderer;
	IGuiRenderer guiRenderer;

	GuiContext context;
	TemplateManager templateManager;

	this(uvec2 windowSize, string caption)
	{
		window = new WindowType();

		aggregator = new EventAggregator!WindowType(this, window);
		
		window.init(windowSize, caption);
	}

	void run(in string[] args)
	{
		init(args);
		load(args);

		double lastTime = window.elapsedTime;
		double newTime;

		while(isRunning)
		{	
			window.processEvents();

			newTime = window.elapsedTime;

			update(newTime - lastTime);

			lastTime = newTime;

			draw();

			fpsHelper.sleepAfterFrame(lastTime - window.elapsedTime);
		}

		window.releaseWindow;
	}

	string[] getHardwareInfo()
	{
		import core.cpuid;
		import anchovy.utils.string : ZToString;

		return [
			"CPU vendor: " ~ vendor,
			"CPU name: " ~ processor,
			"Cores: " ~ to!string(coresPerCPU),
			"Threads: " ~ to!string(threadsPerCPU),
			"CPU chache levels: " ~ to!string(cacheLevels),
			"GPU vendor: " ~ ZToString(glGetString(GL_VENDOR)),
			"Renderer: " ~ ZToString(glGetString(GL_RENDERER)),
			"OpenGL version: " ~ ZToString(glGetString(GL_VERSION)),
			"GLSL version: " ~ ZToString(glGetString(GL_SHADING_LANGUAGE_VERSION)),
		];
	}

	void init(in string[] args)
	{

		dstring cyrillicChars = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюяє"d;

		// ----------------------------- Setting renderer -----------------------------
		renderer = new Ogl3Renderer(window);
		renderer.setClearColor(Color(50, 10, 45));

		// ----------------------------- Skin loading ---------------------------------
		string graySkinSource = cast(string)read("skingray.json");
		auto skinParser = new JsonGuiSkinParser;
		auto graySkin = skinParser.parse(graySkinSource);

		// ----------------------------- Gui renderer ---------------------------------
		guiRenderer = new SkinnedGuiRenderer(renderer, graySkin);
		guiRenderer.fontManager.charCache ~= cyrillicChars;
		graySkin.loadResources(guiRenderer);

		timerManager = new TimerManager(delegate double(){return window.elapsedTime;});

		// ----------------------------- Template classes -----------------------------
		auto templateParser = new TemplateParser;
		templateManager = new TemplateManager(templateParser);

		// ----------------------------- Setting context ------------------------------
		context = new GuiContext(guiRenderer, timerManager, templateManager, graySkin);
		context.setClipboardStringCallback = (dstring newStr) => window.clipboardString = to!string(newStr);
		context.getClipboardStringCallback = delegate dstring(){return to!dstring(window.clipboardString);};
		context.attachDefaultBehaviors();
		context.attachDefaultLayouts();

		// ----------------------------- Rendering settings ---------------------------
		renderer.enableAlphaBlending();
		glEnable(GL_SCISSOR_TEST);
	}

	void load(in string[] args)
	{

	}

	void update(double dt)
	{
		fpsHelper.update(dt);
		timerManager.updateTimers(window.elapsedTime);
		context.update(dt);
	}

	void draw()
	{
		guiRenderer.setClientArea(Rect(0, 0, window.size.x, window.size.y));
		glClear(GL_COLOR_BUFFER_BIT);

		context.eventDispatcher.draw();

		window.swapBuffers();
	}

	void closePressed()
	{
	}

	void printTree()
	{
		void printWidget(Widget widget, string spacing)
		{
			auto children = widget["children"].get!(Widget[]);
			writefln("-%s %s", widget["type"], widget["name"]);

			if (children.length > 0)
			{
				foreach(child; children[0..$-1])
				{
					writef("%s ├", spacing);
					printWidget(child, spacing~" |");
				}
				writef("%s └", spacing);
				printWidget(children[$-1], spacing~"  ");
			}
		}

		foreach(root; context.roots)
		{
			printWidget(root, "");
		}
		writeln;
	}
}