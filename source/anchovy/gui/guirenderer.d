/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.guirenderer;

import std.array;
import std.stdio;

import anchovy.graphics;
import anchovy.graphics.texture;
import anchovy.graphics.font.fontmanager;
import anchovy.graphics.shaderprogram;
import anchovy.gui;

string textvshader=`
#version 330
layout (location = 0) in vec2 Position;
layout (location = 1) in vec2 TexCoord;
uniform vec2 gPosition;
uniform vec2 gHalfTarget;
uniform sampler2D gSampler;
out vec2 TexCoord0;

void main()
{
	gl_Position = vec4(((Position.x+gPosition.x)/gHalfTarget.x)-1, 1-((Position.y+gPosition.y)/gHalfTarget.y), 0.0, 1.0);
	ivec2 texSize = textureSize(gSampler, 0);
	TexCoord0 = TexCoord/texSize;
}`;

string textfshader=`
#version 330
in vec2 TexCoord0;

out vec4 FragColor;

uniform sampler2D gSampler;
uniform vec4 gColor;

void main()
{
	FragColor = texture2D(gSampler, TexCoord0).r*gColor;
}
`;

/// Gives means for rendering widgets and text lines.
class SkinnedGuiRenderer : IGuiRenderer
{
	this(IRenderer renderer, GuiSkin skin)
	{
		_renderer = renderer;
		_fontManager = new FontManager();
		_fontTexture = _fontManager.getFontAtlasTex();
		_textShader = new ShaderProgram(textvshader, textfshader);
		_skin = skin;

		if (!_textShader.compile)
			writeln("Text shader failed compilation: ", _textShader.errorLog);

		_renderer.bindShaderProgram(_textShader);
		checkGlError;
	}

	/// Returns texture that stores cached glyps of all loaded fonts.
	override Texture getFontTexture()
	{
		return _fontTexture;
	}

	/// Returns font manager used by this renderer.
	override ref FontManager fontManager() @property
	{
		return _fontManager;
	}

	GuiSkin skin() @property
	{
		return _skin;
	}

	/// Creates textline with font from current skin.
	/// If font not found then normal font will be used.
	override TextLine createTextLine(string fontName = "normal")
	{
		auto line = new TextLine();
		_lines ~= line;

		line.fontName = fontName;

		Font* font = fontName in _skin.fonts;

		if (font is null)
		{
			font = "normal" in _skin.fonts;
		}

		line.font = *font;

		return line;
	}

	/// Draws background of widget.
	override void drawControlBack(Widget widget, Rect staticRect)
	{
		if (_clientAreaStack.length > 0)
		{
			Rect clip = _clientAreaStack.back;
			if (clip.width*clip.height == 0) return;
		}

		string styleName = widget.getPropertyAs!("style", string);
		string stateName = widget.getPropertyAs!("state", string);

		GuiStyle* styleptr = styleName in _skin.styles;

		// No style in skin.
		if (styleptr is null)
		{
			_renderer.setColor(Color(255, 255, 255, 255));
			_renderer.fillRect(staticRect);
			_renderer.setColor(Color(255, 0, 0, 255));
			_renderer.drawRect(staticRect);
		}
		else // Widget has style.
		{
			GuiStyle style = *styleptr;

			if (!(stateName in style.states)) // Fallback to deafult.
			{
				stateName = "normal";
			}

			GuiStyleState state = style[stateName];

			TexRectArray[string] geometryList = widget.getPropertyAs!("geometry", TexRectArray[string]);

			TexRectArray* geometry = stateName in geometryList;

			if (geometry is null) // Geometry for current state is no cached yet.
			{
				ivec2 size = widget.getPropertyAs!("size", ivec2);
				TexRectArray newGeometry = buildWidgetGeometry(size, state);

				geometry = &newGeometry;
				geometryList[stateName] = newGeometry;

				widget.setProperty!"geometry"(geometryList);
			}

			_renderer.setColor(Color(255, 255, 255, 255));
			_renderer.drawTexRectArray(*geometry,
										ivec2(staticRect.x - state.outline.left,staticRect.y - state.outline.top),
			                           _skin.texture);
		}
	}

	/// Draws line of text aligning it to the position.
	override void drawTextLine(TextLine line, ivec2 position, in AlignmentType alignment)
	{
		if (_clientAreaStack.length > 0)
		{
			Rect clip = _clientAreaStack.back;
			if (clip.width*clip.height == 0) return;
		}

		if (!line.isInited)
		{
			return;
		}
		line.update;

		int renderX, renderY;

		if (alignment & HoriAlignment.LEFT)
			renderX = position.x;
		else if (alignment & HoriAlignment.CENTER)
			renderX = position.x - (line.width / 2);
		else
			renderX = position.x - line.width;

		if (alignment & VertAlignment.TOP)
			renderY = position.y + line.height;
		else if (alignment & VertAlignment.CENTER)
			renderY = position.y + (line.height / 2);
		else
			renderY = position.y;

		_renderer.drawTexRectArray(line.geometry, ivec2(renderX , renderY), _fontTexture, _textShader);
	}

	/// Draws line of text aligning it inside rectangle.
	override void drawTextLine(TextLine line, in Rect area, in AlignmentType alignment)
	{
		if (_clientAreaStack.length > 0)
		{
			Rect clip = _clientAreaStack.back;
			if (clip.width*clip.height == 0) return;
		}

		if (!line.isInited)
		{
			return;
		}
		line.update;

		int renderX, renderY;

		if (alignment & HoriAlignment.LEFT)
			renderX = area.x;
		else if (alignment & HoriAlignment.CENTER)
			renderX = area.x + (area.width/2) - (line.width / 2);
		else if (alignment & HoriAlignment.RIGHT)
			renderX = area.x + area.width - line.width;
		else
			renderX = area.x;

		if (alignment & VertAlignment.TOP)
			renderY = area.y;
		else if (alignment & VertAlignment.CENTER)
			renderY = area.y + (area.height/2) - (line.height / 2);
		else if (alignment & VertAlignment.BOTTOM)
			renderY = area.y + area.height - line.height;
		else
			renderY = area.y;

		_renderer.drawTexRectArray(line.geometry, ivec2(renderX , renderY), _fontTexture, _textShader);
	}

	/// Pushes new clip rect onto stack.
	/// Useful for containers which clips their children.
	/// Must be called when parent begins drawing its children.
	override void pushClientArea(Rect area)
	{
		_clientAreaStack ~= area;
		setClientArea(_clientAreaStack.back);
	}

	/// Pops clip rect from stack.
	/// Useful for containers which clips their children.
	/// Must be called when parent ends drawing its children.
	override void popClientArea()
	{
		_clientAreaStack.popBack;

		if (_clientAreaStack.empty)
		{
			glScissor(0, 0, _renderer.windowSize.x, _renderer.windowSize.y);
			return;
		}

		setClientArea(_clientAreaStack.back);
	}

	/// Sets clip rect to given area.
	/// Make sure to call this to reset rendering area for the window.
	override void setClientArea(Rect area)
	{
		glScissor(area.x, _renderer.windowSize.y - area.y - area.height,  area.width, area.height);
	}

	/// Returns internal render.
	IRenderer renderer() @property
	{
		return _renderer;
	}

	/// Creates geometry for given gui style state and size.
	TexRectArray buildWidgetGeometry(ivec2 size, in GuiStyleState state)
	{
		TexRectArray geometry = new TexRectArray;
		RectOffset fb = state.fixedBorders; // defines splitting of texture in 9 pieces.

		int widgetHeight = size.y + state.outline.top + state.outline.bottom;
		int widgetWidth = size.x + state.outline.left + state.outline.right;

		if (fb.left > 0) // left 3 parts
		{

			if (fb.top > 0) // left-top
			{
				Rect texRect;
				with(state.atlasRect)
					texRect = Rect(x, y, fb.left, fb.top);
				geometry.appendQuad(Rect(0, 0, fb.left, fb.top), texRect);
			}
			if (fb.bottom > 0) // left-bottom
			{
				Rect texRect;
				with(state.atlasRect)
					texRect = Rect(x, y + height - fb.bottom, fb.left, fb.bottom);
				geometry.appendQuad(Rect(0, widgetHeight - fb.bottom, fb.left, fb.bottom), texRect);
			}
			if (fb.vertical < widgetHeight) // left
			{
				Rect texRect;
				with(state.atlasRect)
					texRect = Rect(x, y + fb.top, fb.left, height - fb.vertical);
				geometry.appendQuad(Rect(0, fb.top, fb.left, widgetHeight - fb.vertical), texRect);
			}
		}

		if (fb.top > 0 && fb.horizontal < widgetWidth) // top
		{
			Rect texRect;
			with(state.atlasRect)
				texRect = Rect(x + fb.left, y, width - fb.horizontal, fb.top);
			geometry.appendQuad(Rect(fb.left, 0, widgetWidth - fb.horizontal, fb.top), texRect);
		}

		if (fb.horizontal < widgetWidth && fb.vertical < widgetHeight) // center
		{
			Rect texRect;
			with(state.atlasRect)
				texRect = Rect(x + fb.left, y + fb.top, width - fb.horizontal, height - fb.vertical);
			geometry.appendQuad(Rect(fb.left, fb.top, widgetWidth - fb.horizontal, widgetHeight - fb.vertical), texRect);
		}

		if (fb.bottom > 0 && fb.horizontal < widgetWidth) // bottom
		{
			Rect texRect;
			with(state.atlasRect)
				texRect = Rect(x + fb.left, y + height - fb.bottom, width - fb.horizontal, fb.bottom);
			geometry.appendQuad(Rect(fb.left, widgetHeight - fb.bottom, widgetWidth - fb.horizontal, fb.bottom), texRect);
		}

		if (fb.right > 0) // right 3 parts
		{
			if (fb.top > 0) // right-top
			{
				Rect texRect;
				with(state.atlasRect)
					texRect = Rect((x+width) - fb.right, y, fb.right, fb.top);
				geometry.appendQuad(Rect(widgetWidth - fb.right, 0, fb.right, fb.top), texRect);
			}
			if (fb.bottom > 0) // right-bottom
			{
				Rect texRect;
				with(state.atlasRect)
					texRect = Rect((x+width) - fb.right, y + height - fb.bottom, fb.right, fb.bottom);
				geometry.appendQuad(Rect(widgetWidth - fb.right, widgetHeight - fb.bottom, fb.right, fb.bottom), texRect);
			}
			if (fb.vertical < widgetHeight) // right
			{
				Rect texRect;
				with(state.atlasRect)
					texRect = Rect((x+width) - fb.right, y + fb.top, fb.right, height - fb.vertical);
				geometry.appendQuad(Rect(widgetWidth - fb.right, fb.top, fb.right, widgetHeight - fb.vertical), texRect);
			}
		}

		geometry.load;

		return geometry;
	}

private:

	Rect[] _clientAreaStack;
	IRenderer _renderer;
	FontManager _fontManager;
	ShaderProgram _textShader;
	Texture _fontTexture;
	GuiSkin _skin;
	TextLine[] _lines;
}
