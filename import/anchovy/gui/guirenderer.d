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

module anchovy.gui.guirenderer;

import std.array;
import std.stdio;

import anchovy.graphics.all;
import anchovy.graphics.font.fontmanager;
import anchovy.graphics.shaderprogram;
import anchovy.gui.all;

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

class SkinnedGuiRenderer : IGuiRenderer
{
	this(IRenderer renderer, GuiSkin skin = null)
	{
		_renderer = renderer;
		_fontManager = new FontManager();
		_fontTexture = renderer.registerTexture(_fontManager.getFontAtlasTex());
		_textShader = new ShaderProgram(textvshader, textfshader);
		_skin = skin;
		if (!_textShader.compile)
			writeln(_textShader.errorLog);
		_renderer.bindShaderProgram(_textShader);
		//_textShader.setUniform!float("gSampler", 0);
		checkGlError;
	}

	override uint getFontTexture()
	{
		return _fontTexture;
	}

	override ref FontManager fontManager() @property
	{
		return _fontManager;
	}

	override void drawControlBack(Widget widget, Rect staticRect)
	{
		/*GuiStyle* styleptr;
		if (widget.skin !is null)
		{
			styleptr = widget.style in widget.skin.styles;
		}

		if (styleptr is null)
		{*/
			_renderer.setColor(Color(255, 255, 255, 255));
			_renderer.fillRect(staticRect);
			_renderer.setColor(Color(255, 0, 0, 255));
			_renderer.drawRect(staticRect);
		/*}
		else
		{
			GuiStyle style = *styleptr;
			if ((widget.state in widget.geometry) is null)
			{
				widget.geometry[widget.state] = buildWidgetGeometry(widget, style);
			}
			GuiStyleState state = style[widget.state];
			_renderer.setColor(Color(255, 255, 255, 255));
			_renderer.drawTexRectArray(widget.geometry[widget.state],
			                           staticRect.x - state.outline.left,
			                           staticRect.y - state.outline.top,
			                           widget.skin.texture);
		}*/
	}

	override void drawTextLine(ref TextLine line, ivec2 position, in AlignmentType alignment)
	{
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
			renderY = position.y;
		else if (alignment & VertAlignment.CENTER)
			renderY = position.y - (line.height / 2);
		else 
			renderY = position.y - line.height;

		_renderer.drawTexRectArray(line.geometry, renderX , renderY, _fontTexture, _textShader);
	}

	override void drawTextLine(ref TextLine line, in Rect area, in AlignmentType alignment)
	{
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
			renderX = area.x + line.x;
		
		if (alignment & VertAlignment.TOP)
			renderY = area.y;
		else if (alignment & VertAlignment.CENTER)
			renderY = area.y + (area.height/2) - (line.height / 2);
		else if (alignment & VertAlignment.BOTTOM)
			renderY = area.y + area.height - line.height;
		else
			renderY = area.y + line.y;
		
		_renderer.drawTexRectArray(line.geometry, renderX , renderY, _fontTexture, _textShader);
	}

	override void pushClientArea(Rect area)
	{
		_clientAreaStack ~= area;
		setClientArea(_clientAreaStack.back);
	}
	
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

	override void setClientArea(Rect area)
	{
		glScissor(area.x, _renderer.windowSize.y - area.y - area.height,  area.width, area.height);
	}

	IRenderer renderer() @property
	{
		return _renderer;
	}

	/*TexRectArray buildWidgetGeometry(ref Widget widget, in GuiStyle style)
	{
		TexRectArray geometry = new TexRectArray;
		GuiStyleState state = style[widget.state];
		RectOffset fb = state.fixedBorders;
		int widgetHeight = widget.prefferedSize.y + state.outline.top + state.outline.bottom;
		int widgetWidth = widget.prefferedSize.x + state.outline.left + state.outline.right;
		//writeln("w: ", widgetWidth, ", h: ", widgetHeight);
		assert(geometry !is null);
		if (fb.left > 0)
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
		if (fb.right > 0)
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
	}*/

private:
	Rect[] _clientAreaStack;
	IRenderer _renderer;
	FontManager _fontManager;
	ShaderProgram _textShader;
	uint _fontTexture;
	GuiSkin _skin;
}

