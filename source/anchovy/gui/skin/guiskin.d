/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.skin.guiskin;

import anchovy.gui;
import anchovy.graphics.interfaces.irenderer;
import anchovy.graphics.texture;
import anchovy.core.types;

class GuiSkin
{
	string skinFilename;
	//May be replaced by atlas
	Texture texture;
	string textureFilename;
	string name;

	Font[string] fonts;
	FontInfo[] fontInfos;
	GuiStyle[string] styles;

	void addStyle(string styleName, GuiStyle style)
	{
		styles[styleName] = style;
	}

	void loadResources(IGuiRenderer guiRenderer)
	{
		texture = guiRenderer.renderer.createTexture(textureFilename);
		foreach(ref FontInfo info; fontInfos)
		{
			uint font = guiRenderer.fontManager.createFont(info.filename, info.size);
			fonts[info.name] = guiRenderer.fontManager.getFont(font);
			fonts[info.name].verticalOffset = info.verticalOffset;
		}
	}

	GuiStyle opIndex(string styleName)
	{
		return styles.get(styleName, null);
	}

	override string toString() const
	{
		string result;
		result ~= "GuiSkin(Name:'" ~ name~"', textureFilename: '"~textureFilename~"'\n";

		foreach(string styleName, ref style; styles)
		{
			result ~= styleName~"("~ style.toString ~ "\n";
		}

		result ~=")\n";
		return result;
	}
}

struct FontInfo
{
	string name;
	string filename;
	uint size;
	int verticalOffset;
}

class GuiStyle
{
	GuiStyleState[string] states;
	string fontName; // "normal" by default

	GuiStyleState opIndex(string stateName) const
	{
		const(GuiStyleState)* state = stateName in states;
		if (state is null) return states["normal"];
		return *state;
	}

	override string toString() const
	{
		return "fixedBord:"~to!string(states["normal"].fixedBorders.toString) ~
			" contPadd:"~to!string(states["normal"].contentPadding.toString) ~
				" rect:"~to!string(states["normal"].atlasRect) ~
				"minSize: "~to!string(states["normal"].minSize);
	}
}

struct GuiStyleState
{
	///Defines position and sizes of controls texture in skin teture
	Rect atlasRect;

	/// Minimal size of the widget. If not explicitly specified equal to atlasRect size.
	/// It is highly recommended to set it to size equal or greater than atlasRect size to prevent glitches.
	ivec2 minSize;

	/// Maximal size of the widget. By default equal to [0,0]. If maxSize is zero maxSize is not limited.
	ivec2 maxSize;

	/// Defines offset of content rect from widget borders.
	RectOffset contentPadding;

	/// Defines outline of skin rect. Useful for drawing highlighting.
	/// If skin has drawn outline, with this parameter set
	/// guiRenderer will draw that sides outside of rect.
	RectOffset outline;

	/// Defines non-stretchable borders of texture.
	/// Corner parts will stay non-stretched.
	/// Left/right sides will be stretched vertically.
	/// Top/bottom sides will be stretched horizontally.
	/// Middle part will be stretched
	RectOffset fixedBorders;

	Color textColor;
	Color backgroundColor;
}
