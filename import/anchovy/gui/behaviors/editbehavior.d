/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/


module anchovy.gui.behaviors.editbehavior;

import std.algorithm;
import std.stdio;
import std.utf : count, toUTFindex;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;
import anchovy.gui.behaviors.labelbehavior;

class EditBehavior : LabelBehavior
{
	override void attachTo(Widget widget)
	{
		super.attachTo(widget);
		_widget = widget;

		widget.addEventHandler(&keyPressed);
		widget.addEventHandler(&keyReleased);
		widget.addEventHandler(&charEntered);
		widget.addEventHandler(&focusGained);
		widget.addEventHandler(&focusLost);
		widget.addEventHandler(&pointerPressed);
		widget.addEventHandler(&pointerReleased);
		widget.addEventHandler(&pointerMoved);

		_context = widget.getPropertyAs!("context", GuiContext);

		_textLine = widget.getPropertyAs!("line", TextLine);
		widget["style"] = "edit";

		widget.property("size").valueChanged.connect((FlexibleObject obj, Variant value){calcTextXPos();});

		widget.setProperty!"isFocusable"(true);
		_contentOffset = RectOffset(2);

		_isEditable = true;

	}

	override bool handleDraw(Widget widget, DrawEvent event)
	{
		if (event.sinking)
		{
			ivec2 staticPos = widget.getPropertyAs!("staticPosition", ivec2);
			Rect staticRect = widget.getPropertyAs!("staticRect", Rect);

			event.guiRenderer.drawControlBack(widget, staticRect);
			assert(_textLine);

			event.guiRenderer.pushClientArea(staticRect);
				event.guiRenderer.renderer.setColor(Color(0,0,0));
				event.guiRenderer.drawTextLine(_textLine, ivec2(staticPos.x + _textPos.x + _contentOffset.left, staticPos.y), AlignmentType.LEFT_TOP);
				
				if (_isFocused && _isCursorVisible && _isCursorBlinkVisible)
				{
					event.guiRenderer.renderer.fillRect(Rect(staticPos.x + _cursorRenderPos + _textPos.x + _contentOffset.left,
				                                	staticPos.y + staticRect.size.y/2 - _textLine.height/2,
				                                	1, _textLine.height));
				}
				if (_hasSelectedText)
				{
					event.guiRenderer.renderer.setColor(Color(0,0,255, 64));
					size_t selectionStartX = calcCharOffset(cast(uint)_selectionStart);
						event.guiRenderer.renderer.fillRect(Rect(staticPos.x + _textPos.x + _contentOffset.left + cast(uint)selectionStartX,
					                                	staticPos.y + staticRect.size.y/2 - _textLine.height/2,
						                               	calcCharOffset(cast(uint)_selectionEnd) - cast(uint)selectionStartX, _textLine.height));
				}
			event.guiRenderer.popClientArea;
		}

		return true;
	}

	
	bool keyPressed(Widget widget, KeyPressEvent event)
	{
		if (!_isEditable) return true;
		
		bool doTextUpdate = true;
		bool doDeselect = true;

		if (event.modifiers & KeyModifiers.CONTROL)
		{
			if (event.keyCode == KeyCode.KEY_C)
			{
				event.context.clipboardString = to!string(copy());
				doDeselect = false;
			}		
			else if (event.keyCode == KeyCode.KEY_V)
			{
				paste(to!dstring(event.context.clipboardString));
			}	
			else if (event.keyCode == KeyCode.KEY_X)
			{
				event.context.clipboardString = to!string(copy());
				removeSelectedText();
			}
			else
			{
				doTextUpdate = false;
			}
		}
		else if (event.keyCode == KeyCode.KEY_BACKSPACE)
		{
			if (_hasSelectedText)
			{
				removeSelectedText();
			}
			else if (_textLine.text.length > 0 && _cursorPos > 0)
			{
				_cursorRenderPos -= _textLine.font.getGlyph(_textLine.text[_cursorPos-1]).metrics.advanceX;
				_textLine.text = _textLine.text[0.._cursorPos-1] ~ _textLine.text[_cursorPos..$];
				--_cursorPos;
				onCursorMove();
			}
		}
		else if (event.keyCode == KeyCode.KEY_LEFT)
		{
			moveCursorLeft();
		}
		else if (event.keyCode == KeyCode.KEY_RIGHT)
		{
			moveCursorRight();
		}
		else if (event.keyCode == KeyCode.KEY_DELETE)
		{
			if (_hasSelectedText)
			{
				removeSelectedText();
			}
			else if (_cursorPos < _textLine.text.length)
			{
				_textLine.text = _textLine.text[0.._cursorPos]~_textLine.text[_cursorPos+1..$];
				onCursorMove();
			}

		}
		else if (event.keyCode == KeyCode.KEY_HOME)
		{
			setCursorPos(0);
		}
		else if (event.keyCode == KeyCode.KEY_END)
		{
			setCursorPos(_textLine.text.length);
		}
		else if (event.keyCode == KeyCode.KEY_ENTER)
		{
			widget.setProperty!"text"(_textLine.text);
		}
		else
		{
			doTextUpdate = false;
		}
		
		if (doTextUpdate)
		{
			calcTextXPos();
			if (doDeselect)
			{
				deselect();
			}
		}
		
		return true;
	}
	
	bool keyReleased(Widget widget, KeyReleaseEvent)
	{
		return true;
	}

	bool charEntered(Widget widget, CharEnterEvent event)
	{
		if (_isEditable)
		{
			normalizeSelection();
			_textLine.text = _textLine.text[0.._selectionStart] ~ event.character ~ _textLine.text[_selectionEnd..$];
			setCursorPos(_selectionStart+1);
			deselect();
			calcTextXPos();
		}

		return true;
	}

	bool pointerPressed(Widget widget, PointerPressEvent event)
	{
		if (event.button == PointerButton.PB_LEFT)
		{
			moveCursorToClickPos(event.pointerPosition);
		
			_selectionStart = _cursorPos;
			_selectionEnd = _cursorPos;
			return true;
		}

		return true;
	}

	bool pointerReleased(Widget widget, PointerReleaseEvent event)
	{
		return true;
	}

	bool pointerMoved(Widget widget, PointerMoveEvent event)
	{
		if (event.context.eventDispatcher.pressedWidget is widget )
		{
			moveCursorToClickPos(event.pointerPosition);
			_selectionEnd = _cursorPos;
			updateSelection();
		}

		return true;
	}
	
	bool focusGained(Widget widget, FocusGainEvent event)
	out
	{
		assert(_blinkTimer);
	}
	body
	{
		assert(_blinkTimer is null);
		assert(_isCursorBlinkVisible);

		widget.setProperty!"state"("focused");
		_isFocused = true;

		_blinkTimer = event.context.timerManager.addTimer(_blinkInterval, &onCursorBlink, double.nan, TimerTickType.PROCESS_LAST);
		
		return true;
	}
	
	bool focusLost(Widget widget, FocusLoseEvent event)
	{
		widget.setProperty!"state"("normal");
		_isFocused = false;

		event.context.timerManager.stopTimer(_blinkTimer);
		_blinkTimer = null;

		_isCursorBlinkVisible = true;

		widget.setProperty!"text"(_textLine.text);
				
		return true;
	}


	/// Set current cursor blink interval in seconds.
	/// newInterval must be greater than zero.
	void blinkInterval(double newInterval) @property
	in
	{
		assert(newInterval > 0);
	}
	body
	{
		_blinkInterval = newInterval;
		if (_blinkTimer) _blinkTimer.delay = newInterval;
	}

	/// Get current cursor blink interval in seconds.
	double blinkInterval() @property
	{
		return _blinkInterval;
	}

	void paste(dstring text)
	{
		removeSelectedText();
		_textLine.text = _textLine.text[0.._cursorPos] ~ text ~ _textLine.text[_cursorPos..$];
		setCursorPos(_cursorPos + text.length);
	}

	dstring copy()
	{
		return selectedText();
	}

	/// Used as a callback to blink timer.
	protected double onCursorBlink(double timesUpdated)
	{
		if ((timesUpdated % 2) > 0)
			_isCursorBlinkVisible = !_isCursorBlinkVisible;

		return 0;
	}

	dstring text() @property
	{
		if (_textLine is null) return "";
		return _textLine.text;
	}
	
	dstring text(string newText) @property
	{
		if (_textLine is null) return "";
		_textLine.text = newText;
		_widget.setProperty!"text"(_textLine.text);

		return _textLine.text;
	}

	dstring selectedText() @property
	{
		if (_selectionStart > _selectionEnd)
		{
			return _textLine.text[_selectionEnd.._selectionStart];
		}
		else
		{
			return _textLine.text[_selectionStart.._selectionEnd];
		}
	}

	void isEditable(bool editable) @property
	{
		_isEditable = editable;
	}

	bool isEditable() @property
	{
		return _isEditable = true;
	}

	void removeSelectedText()
	{
		normalizeSelection();
		_textLine.text = _textLine.text[0.._selectionStart] ~ _textLine.text[_selectionEnd..$];
		setCursorPos(_selectionStart);
		deselect();
	}

	void deselect()
	{
		_selectionStart = _cursorPos;
		_selectionEnd = _cursorPos;
		_hasSelectedText = false;
	}

	void select(size_t start, size_t end)
	{
		_selectionStart = start;
		_selectionEnd   = end;

		normalizeSelection();
		updateSelection();
	}

protected:

	/// Swaps _selectionStart and _selectionEnd if _selectionStart > _selectionEnd.
	/// Should be used before text editing.
	void normalizeSelection()
	{
		if (_selectionStart > _selectionEnd)
		{
			size_t temp = _selectionEnd;
			_selectionEnd = _selectionStart;
			_selectionStart = temp;
		}
	}

	void updateSelection()
	{
		_selectionStart = clamp!size_t(_selectionStart, 0, _textLine.text.length);
		_selectionEnd = clamp!size_t(_selectionEnd, 0, _textLine.text.length);

		if (_selectionEnd - _selectionStart > 0)
			_hasSelectedText = true;
		else
			_hasSelectedText = false;
	}

	void moveCursorToClickPos(ivec2 pointerPosition)
	in
	{
		assert(_textLine);
	}
	body
	{
		if (_textLine.text.length > 0)
		{
			ivec2 staticPos = _widget.getPropertyAs!("staticPosition", ivec2);
			int clickX = pointerPosition.x - (staticPos.x + _contentOffset.left + _textPos.x);

			Font textFont = _textLine.font;
			int charCenter;
			int charX = 0;
			uint charIndex = 0;

			while (true)
			{
				charCenter = charX + (textFont.getGlyph(_textLine.text[charIndex]).metrics.advanceX/2);
				if (charCenter > clickX) break;

				charX += textFont.getGlyph(_textLine.text[charIndex]).metrics.advanceX;
				++charIndex;

				if (charIndex == _textLine.text.length) break;
			}

			if (_cursorPos != charIndex)
			{
				_cursorPos = charIndex;
				_cursorRenderPos = charX;
				onCursorMove();
			}
		}
	}

	/// If cursor changes its position the blinking delay must be reset.
	void onCursorMove()
	{
		if (_blinkTimer)
		{
			_context.timerManager.resetTimer(_blinkTimer);
			_isCursorBlinkVisible = true;
		}

		calcTextXPos();
	}

	void moveCursorRight()
	{
		if (_cursorPos < _textLine.text.length)
		{
			_cursorRenderPos += _textLine.font.getGlyph(_textLine.text[_cursorPos]).metrics.advanceX;
			++_cursorPos;
			onCursorMove();
		}
	}

	void moveCursorLeft()
	{
		if (_cursorPos > 0)
		{
			_cursorRenderPos -= _textLine.font.getGlyph(_textLine.text[_cursorPos-1]).metrics.advanceX;
			--_cursorPos;
			onCursorMove();
		}
	}

	void setCursorPos(size_t position)
	{
		scope(exit) onCursorMove();

		if (position > _textLine.text.length)
		{
			_cursorPos = cast(uint)_textLine.text.length;
			_cursorRenderPos = _textLine.width;
			return;
		}
		else if (position < 0)
		{
			_cursorPos = 0;
			_cursorRenderPos = 0;
			return;
		}

		Font textFont = _textLine.font;
		int charX = 0;
		uint charIndex = 0;

		while (true)
		{
			if (charIndex == position) break;

			Glyph* glyph = textFont.getGlyph(_textLine.text[charIndex]);
			assert(glyph !is null);
			charX += glyph.metrics.advanceX;
			++charIndex;
			
			if (charIndex == _textLine.text.length) break;
		}

		_cursorPos = charIndex;
		_cursorRenderPos = charX;
	}

	/// Returns offset in pixels from the begining of text
	uint calcCharOffset(uint index)
	{
		if (index > _textLine.text.length)
			return _textLine.width;

		int charX = 0;
		uint charIndex = 0;
		
		while (true)
		{
			if (charIndex == index) break;
			
			charX += _textLine.font.getGlyph(_textLine.text[charIndex]).metrics.advanceX;
			++charIndex;
		}

		return charX;
	}

	void calcTextXPos()
	{
		int contentWidth = _widget.getPropertyAs!("size", ivec2).x - _contentOffset.horizontal;

		if (_textLine.width < contentWidth)
		{
			_textPos.x = 0;
		}
		else
		{
			if (_cursorRenderPos + _textPos.x > contentWidth || _cursorPos == _textLine.text.length)
			{
				_textPos.x = contentWidth - _cursorRenderPos;
			}
			else if (_cursorRenderPos + _textPos.x < 0)
			{
				_textPos.x = -_cursorRenderPos;
			}
			else if (_textPos.x + _textLine.width < contentWidth)
			{
				_textPos.x = contentWidth - _textLine.width;
			}
		}

		//writeln("contentWidth ", contentWidth, " _cursorRenderPos ", _cursorRenderPos, " x ", _textPos.x);
	}
	
protected:
	TextLine _textLine;
	GuiContext _context;

private:

	RectOffset _contentOffset;
	bool _isEditable = true;
	bool _isCursorVisible = true;
	bool _hasSelectedText = false;

	/// When blinking is true and _isCursorVisible is true, then cursor will be visible.
	bool _isCursorBlinkVisible = true;
	bool _isFocused = false;

	/// if there is no current selection _selectionStart and _selectionEnd are equal to _cursorPos.
	size_t _selectionStart, _selectionEnd;

	int _cursorPos = 0;
	int _cursorRenderPos = 0;
	ivec2 _textPos;

	double _blinkInterval = 0.25f;

	/// Used for cursor blinking.
	Timer _blinkTimer;

	Widget _widget;
}
