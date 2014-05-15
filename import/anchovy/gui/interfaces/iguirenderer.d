/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.interfaces.iguirenderer;

import anchovy.graphics.texture;

public import anchovy.graphics.interfaces.irenderer;

import anchovy.gui;

enum HoriAlignment
{
	NONE   = 1<<0,
	LEFT   = 1<<1,
	CENTER = 1<<2,
	RIGHT  = 1<<3,
}

enum VertAlignment
{
	NONE   = 1<<4,
	TOP    = 1<<5,
	CENTER = 1<<6,
	BOTTOM = 1<<7,
}

enum AlignmentType
{
	NONE_NONE   = HoriAlignment.NONE | VertAlignment.NONE,
	NONE_TOP    = HoriAlignment.NONE | VertAlignment.TOP,
	NONE_CENTER = HoriAlignment.NONE | VertAlignment.CENTER,
	NONE_BOTTOM = HoriAlignment.NONE | VertAlignment.BOTTOM,

	LEFT_NONE   = HoriAlignment.LEFT | VertAlignment.NONE,
	LEFT_TOP    = HoriAlignment.LEFT | VertAlignment.TOP,
	LEFT_CENTER = HoriAlignment.LEFT | VertAlignment.CENTER,
	LEFT_BOTTOM = HoriAlignment.LEFT | VertAlignment.BOTTOM,
	
	CENTER_NONE   = HoriAlignment.CENTER | VertAlignment.NONE,
	CENTER_TOP    = HoriAlignment.CENTER | VertAlignment.TOP,
	CENTER_CENTER = HoriAlignment.CENTER | VertAlignment.CENTER,
	CENTER_BOTTOM = HoriAlignment.CENTER | VertAlignment.BOTTOM,

	RIGHT_NONE   = HoriAlignment.RIGHT | VertAlignment.NONE,
	RIGHT_TOP    = HoriAlignment.RIGHT | VertAlignment.TOP,
	RIGHT_CENTER = HoriAlignment.RIGHT | VertAlignment.CENTER,
	RIGHT_BOTTOM = HoriAlignment.RIGHT | VertAlignment.BOTTOM,
}

interface IGuiRenderer
{
	Texture getFontTexture();
	ref FontManager fontManager() @property;
	TextLine createTextLine(string fontName = "normal");

	void drawControlBack(Widget widget, Rect staticRect);

	/// draws text line with alignment specified relative to point
	void drawTextLine(TextLine line, ivec2 position, in AlignmentType alignment);

	/// draws text line with alignment specified relative to rectangle
	void drawTextLine(TextLine line, in Rect area, in AlignmentType alignment);
	void pushClientArea(Rect area);
	void popClientArea();
	void setClientArea(Rect area);
	IRenderer renderer() @property;
}