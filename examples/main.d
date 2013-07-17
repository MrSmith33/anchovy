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

module main;

import std.conv, std.datetime, std.file, std.random, std.stdio, std.utf, core.cpuid;

import derelict.opengl3.gl3;

import anchovy.graphics.windows.glfwwindow;
import anchovy.graphics.texture;
import anchovy.graphics.shaderprogram;
import anchovy.graphics.renderers.ogl3renderer;

import anchovy.graphics.font.fontmanager;
import anchovy.graphics.font.textureatlas;

import anchovy.gui.all;
import anchovy.gui.baselayoutmanager;
import fpshelper;
import anchovy.gui.timermanager;

import anchovy.utils.string : ZToString;

class GuiTestWindow : GlfwWindow
{
	void run(in string[] args)
	{
		load(args);
		double lastTime = glfwGetTime();
		double newTime;
		while(running)
		{	
			processEvents();
			newTime = glfwGetTime();
			//writeln(newTime);
			update(newTime - lastTime);
			lastTime = newTime;

			draw();
			swapBuffer;
			fpsHelper.sleepAfterFrame(lastTime - glfwGetTime());
		}
	}

	void update(double dt)
	{
		fpsHelper.update(dt);
		timerManager.updateTimers(glfwGetTime());
	}

	void load(in string[] args)
	{
		writeln("CPU vendor: ", vendor);
		writeln("CPU name: ", processor);
		writeln("Cores: ", coresPerCPU, " Threads: ", threadsPerCPU);
		writeln("CPU chache levels: ", cacheLevels);
		writeln("GPU vendor: ", ZToString(glGetString(GL_VENDOR)));
		writeln("Renderer: ", ZToString(glGetString(GL_RENDERER)));
		writeln("OpenGL version: ", ZToString(glGetString(GL_VERSION)));
		writeln("GLSL version: ", ZToString(glGetString(GL_SHADING_LANGUAGE_VERSION)));
		writeln("--------------------------------------------------------------------");
		dstring russianChars = 	"АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюяїє";
		renderer = new Ogl3Renderer(this);
		guiRenderer = new SkinnedGuiRenderer(renderer);
		fpsHelper.maxFps = 120;
		timerManager = new TimerManager(delegate double(){return glfwGetTime();});

		assert(renderer !is null);
		assert(guiRenderer !is null);
		assert(guiRenderer.fontManager !is null);
		guiRenderer.fontManager.charCache ~= russianChars;

		renderer.setClearColor(Color(50, 10, 45));
		string graySkinSource = cast(string)read("skingray.json");
		auto skinParser = new JsonGuiSkinParser;
		graySkin = skinParser.parse(graySkinSource);
		writeln(graySkin);
		graySkin.loadResources(guiRenderer);
		
		guiwin = new GuiWindow(guiRenderer, timerManager, Rect(0, 0, width, height), graySkin);
		guiwin.setClipboardStringCallback = (dstring newStr) => setClipboard(to!string(newStr));
		guiwin.getClipboardStringCallback = delegate dstring(){return to!dstring(getClipboard());};
		setClipboard("abc");
		GuiLayer mainLayer = new GuiLayer(graySkin);
		guiwin.addWidget(mainLayer);

		/*Button button1 = new Button(Rect(20, 20, 60, 40));
		button1.caption = "Click me!";
		button1.onClick = (IWidget w, ivec2 p){w.caption = to!dstring(p);};
		button1.onLeave = (IWidget w){w.caption = "Click me!";};
		mainLayer.addWidget(button1);*/

		Label l = new Label(Rect(100, 20, 30, 10));
		l.caption = "English Русский Українська";
		mainLayer.addWidget(l);

		auto hscrollBar = new HScrollbar(Rect(20,150,100, 18));
		mainLayer.addWidget(hscrollBar);

		auto vscrollBar = new VScrollbar(Rect(20,170,18, 100));
		mainLayer.addWidget(vscrollBar);
		
		auto list = new List(Rect(200,100,100, 200));
		mainLayer.addWidget(list);
		
		auto addListItemButton = new Button(Rect(120, 100, 80, 24));
		addListItemButton.caption = "Add item";
		int itemId;
		addListItemButton.onClick = (IWidget w, ivec2 p){list.append("Item"~to!string(itemId));++itemId;};
		mainLayer.addWidget(addListItemButton);
		                  
		Frame frame1 = new Frame(Rect(100, 200, 200, 300));
		mainLayer.addWidget(frame1);
		frame1.onClose = (IWidget w){writeln("close button was pressed");};

		Button button2 = new Button(Rect(2, 2, 120, 24));
		button2.caption = "button2";

		button2.onEnter = (IWidget w) => writeln("pointer entered button2");
		button2.onLeave = (IWidget w) => writeln("pointer leaved button2");
		frame1.addWidget(button2);
		
		Edit edit1 = new Edit(Rect(2, 28, 120, 24)); 
		edit1.text = "edit me!";
		edit1.anchor = Sides.LEFT| Sides.TOP | Sides.RIGHT;
		frame1.addWidget(edit1);

		auto vscrollBar2 = new VScrollbar(Rect(165,1,18, 246));
		vscrollBar2.anchor = Sides.BOTTOM | Sides.TOP | Sides.RIGHT;
		frame1.addWidget(vscrollBar2);

		auto hscrollBar2 = new HScrollbar(Rect(1,246,165, 18));
		hscrollBar2.anchor = Sides.BOTTOM | Sides.LEFT | Sides.RIGHT;
		frame1.addWidget(hscrollBar2);

		button2.onClick = (IWidget w, Point2i) => edit1.paste("abc");

		Checkbox check1 = new Checkbox(Rect(2,56, 11,11));
		check1.onToggle = (IWidget w) => writeln((cast(Checkbox)w).isChecked ? "checked" : "unchecked");
		frame1.addWidget(check1);

		auto radio1 = new RadioButton(Rect(2,69, 12,12));
		radio1.group = 1;
		radio1.onToggle = (IWidget w) => writeln((cast(Checkbox)w).isChecked() ? "1 checked" : "1 unchecked");
		frame1.addWidget(radio1);
		auto radio2 = new RadioButton(Rect(2,82, 12,12));
		radio2.group = 1;
		radio2.onToggle = (IWidget w) => writeln((cast(Checkbox)w).isChecked ? "2 checked" : "2 unchecked");
		frame1.addWidget(radio2);
		auto radio3 = new RadioButton(Rect(2,96, 12,12));
		radio3.group = 1;
		radio3.onToggle = (IWidget w) => writeln((cast(Checkbox)w).isChecked ? "3 checked" : "3 unchecked");
		frame1.addWidget(radio3);

		/*Frame calculator = new Frame(Rect(300, 200, 98, 200));
		mainLayer.addWidget(calculator);

		Button bDel = new Button(Rect(28,28,50,24));
		bDel.caption = "<-";
		Button bC = new Button(Rect(2,28,24,24));
		bC.caption = "C";
		Button b7 = new Button(Rect(2,54,24,24));
		b7.caption = "7";
		Button b8 = new Button(Rect(28,54,24,24));
		b8.caption = "8";
		Button b9 = new Button(Rect(54,54,24,24));
		b9.caption = "9";
		Button b4 = new Button(Rect(2,80,24,24));
		b4.caption = "4";
		Button b5 = new Button(Rect(28,80,24,24));
		b5.caption = "5";
		Button b6 = new Button(Rect(54,80,24,24));
		b6.caption = "6";
		Button b1 = new Button(Rect(2,106,24,24));
		b1.caption = "1";
		Button b2 = new Button(Rect(28,106,24,24));
		b2.caption = "2";
		Button b3 = new Button(Rect(54,106,24,24));
		b3.caption = "3";
		Button b0 = new Button(Rect(2,132,50,24));
		b0.caption = "0";
		Button bDot = new Button(Rect(54,132,24,24));
		bDot.caption = ".";

		calculator.addWidget(bDel);
		calculator.addWidget(bC);
		calculator.addWidget(b0);
		calculator.addWidget(b1);
		calculator.addWidget(b2);
		calculator.addWidget(b3);
		calculator.addWidget(b4);
		calculator.addWidget(b5);
		calculator.addWidget(b6);
		calculator.addWidget(b7);
		calculator.addWidget(b8);
		calculator.addWidget(b9);
		calculator.addWidget(bDot);*/


		fpsLabel = new Label(Rect(0, 0, 30, 10));
		fpsLabel.anchor = Sides.RIGHT | Sides.TOP;
		fpsLabel.caption = "0";
		fpsLabel.position = ivec2(width - 200, 10);
		guiwin.addWidget(fpsLabel);
		fpsHelper.onFpsUpdate = delegate(ref FpsHelper helper){fpsLabel.caption = "FPS: " ~ to!dstring(cast(uint)helper.fps) ~
			" dt: " ~ to!dstring(helper.deltaTime);};

		renderer.enableAlphaBlending();
		glEnable(GL_SCISSOR_TEST);
		guiRenderer.fontManager.getFontAtlasTex;

		//Frame bigFrame = new Frame(Rect(500, 20, 1000, 1000));
		//mainLayer.addWidget(bigFrame);
	}

	void draw()
	{
		glClear(GL_COLOR_BUFFER_BIT); 
		renderer.setColor(Color4f(1 ,0.5,0,0.5));
		renderer.fillRect(0, 0, 50, 50);
		renderer.setColor(Color(255, 255, 255));
		renderer.drawTexRect(width - 255, height - 255, 256, 256, 0, 0, 256, 256, guiRenderer.getFontTexture);
		/*renderer.setColor(Color4f(1 ,0.5,0,0.5));
		renderer.drawRect(50, 0, 100, 50);
		renderer.drawTexRect(50, 100, 32, 32, 0, 0, 32, 32, testTexture);*/
		guiwin.draw();

		glUseProgram(0);
	}

	override bool quit()
	{
		running = false;
		return true;
	}

	override void windowResized(in uint newWidth, in uint newHeight)
	{
		fpsLabel.position = ivec2(newWidth - 200, 10);
		reshape(newWidth, newHeight);
		guiwin.size = uvec2(newWidth, newHeight);
	}

	override void mousePressed(in uint mouseButton)
	{
		guiwin.pointerPressed(getMousePosition, cast(PointerButton)mouseButton);
	}

	override void mouseReleased(in uint mouseButton)
	{
		guiwin.pointerReleased(getMousePosition, cast(PointerButton)mouseButton);
	}

	override void mouseMoved(in int newX, in int newY)
	{
		guiwin.pointerMoved(ivec2(newX, newY));
	}

	KeyModifiers getCurrentKeyModifiers()
	{
		KeyModifiers modifiers;
		if (isKeyPressed(KeyCode.KEY_LEFT_SHIFT) || isKeyPressed(KeyCode.KEY_RIGHT_SHIFT))
			modifiers |= KeyModifiers.SHIFT;
		if (isKeyPressed(KeyCode.KEY_LEFT_CONTROL) || isKeyPressed(KeyCode.KEY_RIGHT_CONTROL))
			modifiers |= KeyModifiers.CONTROL;
		if (isKeyPressed(KeyCode.KEY_LEFT_ALT) || isKeyPressed(KeyCode.KEY_RIGHT_ALT))
			modifiers |= KeyModifiers.ALT;
		return modifiers;
	}

	override void keyPressed(in uint keyCode)
	{
		if (keyCode == GLFW_KEY_ESCAPE)
		{
			running = false;
			return;
		}
		guiwin.keyPressed(cast(KeyCode)keyCode, getCurrentKeyModifiers());
	}

	override void keyReleased(in uint keyCode)
	{
		guiwin.keyReleased(cast(KeyCode)keyCode, getCurrentKeyModifiers());
	}

	override void charReleased(in dchar unicode)
	{
		guiwin.charEntered(unicode);
	}

	GuiWindow guiwin;
	GuiSkin graySkin;

	TimerManager timerManager;

	Label fpsLabel;

	uint testTexture;

	IRenderer renderer;
	IGuiRenderer guiRenderer;

	bool running = true;
	FpsHelper fpsHelper;
}

void main(string[] args)
{
	GuiTestWindow window;
		window = new GuiTestWindow();
		window.init(512, 512, "GUI testing");
		window.run(args);
	window.releaseWindow;
}