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

module anchovy.gui.interfaces.iwidget;

import anchovy.gui.all;

alias void delegate(Event event) EventHandler;
alias void delegate(IWidget widget, ivec2 point) ClickHandler;
alias void delegate(IWidget widget) RegularHandler;

/// Used to specify Widget.anchor.
enum Sides
{
	LEFT = 1,
	RIGHT = 2,
	TOP = 4,
	BOTTOM = 8,
}

/// Will be splitted in few interfaces.
abstract class IWidget
{
public:

	void calcStaticRect(Rect parentStaticRect);
	
	//+-------------------------------------------------------------------------------+
	//|                                   Drawing                                     |
	//+-------------------------------------------------------------------------------+
	
	void draw(IGuiRenderer renderer) @trusted;
	
	//+-------------------------------------------------------------------------------+
	//|                                Event handling                                 |
	//+-------------------------------------------------------------------------------+
	
	bool charEntered(in dchar chr);
	
	void focusGained();
	
	void focusLost();
	
	bool pointerPressed(ivec2 pointerPosition, PointerButton button);
	
	bool pointerReleased(ivec2 pointerPosition, PointerButton button);
	
	bool pointerMoved(ivec2 newPointerPosition);
	
	void pointerEntered();
	
	void pointerLeaved();
	
	bool keyPressed(in KeyCode key, KeyModifiers modifiers);
	
	bool keyReleased(in KeyCode key, KeyModifiers modifiers);
	
	//+-------------------------------------------------------------------------------+
	//|                                  Properties                                   |
	//+-------------------------------------------------------------------------------+
	@property
	{
		/** 
		Anchored sides of the widget.
		Can be constructed by ORing Anchor values.
		Examples:
		---
		widget.anchor = Sides.LEFT | Sides.RIGHT;
		 ---
		*/
		uint anchor();
		
		/// ditto
		void anchor(uint newAnchor);
		
		dstring caption();
		
		void caption(dstring newCaption);
		
		// Used internally by gui renderer.
		ref TexRectArray[string] geometry() @safe;
		
		void parent(Widget newParent);
		
		Widget parent() @safe;
		
		void position(ivec2 newPosition) @safe;
		ivec2 position() @safe;
		
		// Add checks and discardGeometry
		void rect(Rect newRect) @safe;
		Rect rect() @safe;
		
		void skin(GuiSkin newSkin);
		GuiSkin skin() @safe;
		
		string state() @safe;
		void state(string newStateName);
		
		Rect staticRect();
		
		string styleName() @safe;
		void styleName(string newStyleName) @safe;

		void size(ivec2 newSize);
		ivec2 size();

		int width() @safe;
		void width(int newWidth);
		
		int height() @safe;
		void height(int newHeight);
		
		int x() @safe;
		void x(int newX) @safe;
		
		int y() @safe;
		void y(int newX) @safe;

	//+-------------------------------------------------------------------------------+
	//|                                Event handling                                 |
	//+-------------------------------------------------------------------------------+
		
		void onClick(ClickHandler newHandler) @safe;
		
		void onEnter(RegularHandler newHandler) @safe;
		
		void onLeave(RegularHandler newHandler) @safe;
		
		GuiWindow window() @safe;
	}
}