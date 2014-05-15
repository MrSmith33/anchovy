/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.utils.textline;

import anchovy.gui;
public import anchovy.graphics.texrectarray;
import anchovy.graphics.interfaces.irenderer;
import anchovy.graphics.font.fontmanager;

class TextLine
{

public:

	this()
	{
		_text = "";
	}

	void font(Font newFont) @property
	{
		if (newFont is null) return;
		_font = newFont;
		if (!_isInited || newFont != _font)
			init();
	}

	Font font() @property
	{
		return _font;
	}

	bool isInited() @property
	{
		return _isInited;
	}
	
	void update()
	{
		if (text.length == 0 || !_isInited) return;
		if (_isDirty)
		{
			_geometry.load;
			_isDirty = false;
		}
	}

	uint width() @property
	{
		return _width;
	}

	uint height() @property
	{
		return _height;
	}

	ivec2 size() @property
	{
		return ivec2(_width, _height);
	}

	TexRectArray geometry() @property
	{
		return _geometry;
	}

	dstring text() @property
	{
		return _text;
	}

	dstring text(in string newText) @property
	{
		return text = to!dstring(newText);
	}

	dstring text(in dstring newText) @property
	{
		if (_text == newText)
		{
			return _text;
		}

		_text = newText;
		if (!_isInited) return _text;

		_geometry.vertieces = null;
		_cursorX = 0;
		
		appendGlyphs(_text, _font);
		_isDirty = true;

		return _text;
	}

	string fontName() @property
	{
		return _fontName;
	}

	void fontName(string newFontName) @property
	{
		_fontName = newFontName;
	}

	///Supports chaining
	TextLine append(in string text)
	{
		return append(to!dstring(text));
	}

	TextLine append(in dstring text)
	{
		appendGlyphs(_text, _font);
		_isDirty = true;
		return this;
	}

protected:

	void init()
	{
		_geometry = new TexRectArray;
		_height = _font.size;
		appendGlyphs(_text, _font);
		_isInited = true;
	}

	void appendGlyphs(in dstring text, Font font)
	{
		foreach(dchar chr; text)
		{
			Glyph* glyph = font.getGlyph(chr);
			if (glyph !is null && chr == '\t')
			{
				_cursorX += glyph.metrics.advanceX * _tabSize;
				continue;
			}
			if (glyph is null) glyph = font.getGlyph('?');
			
			int x  =  glyph.metrics.offsetX + _cursorX;
			int y  =  font.verticalOffset - glyph.metrics.offsetY;
			int w  =  glyph.metrics.width;
			int h  =  glyph.metrics.height;
			int tx =  glyph.atlasPosition.x;
			int ty =  glyph.atlasPosition.y;
			
			//whitespace
			if (w == 0 || h == 0)
			{
				_cursorX += glyph.metrics.advanceX;
				continue;
			}

			_geometry.appendQuad(Rect(x, y, w, h), Rect(tx, ty, w, h));
			_cursorX += glyph.metrics.advanceX;
		}

		_width = _cursorX;
	}

protected:
	uint _width;
	uint _height;
	dstring _text;
	bool _isInited = false;
	
	TexRectArray _geometry;
	uint _cursorX;
	bool _isDirty = true;
	
	Font _font;
	string _fontName;
	
	ubyte _tabSize = 4;
}