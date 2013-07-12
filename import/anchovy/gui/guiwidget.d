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

module anchovy.gui.guiwidget;

import anchovy.gui.all;

public import anchovy.gui.interfaces.iwidget;

enum defaultAnchor = Sides.LEFT | Sides.TOP;

///
abstract class GuiWidget : IWidget
{
public:

	this(Rect initRect, in string initStyleName, GuiSkin initSkin = null)
	{
		_rect = initRect;
		_prefferedSize = uvec2(_rect.width, _rect.height);
		styleName = initStyleName;
		skin = initSkin;
		_textLine = new TextLine("", null);
		init();
	}

	/// Called by a constructor.
	/// You can do custom init here.
	protected void init()
	{
	}

	override void calcStaticRect(Rect parentStaticRect) @safe
	{
		_staticRect = _rect.relativeToParent(parentStaticRect);
	}

//+-------------------------------------------------------------------------------+
//|                                   Drawing                                     |
//+-------------------------------------------------------------------------------+

	override void draw(IGuiRenderer renderer) @trusted
	in
	{
		assert(renderer !is null);
	}
	body
	{
		if (_isBackgroundVisible)
			drawBackground(renderer);

		if (_isContentVisible)
			drawContent(renderer);
	}

	void drawBackground(IGuiRenderer renderer) 
	{
		renderer.drawControlBack(this, _staticRect);
	}

	void drawContent(IGuiRenderer renderer)
	{
	}

//+-------------------------------------------------------------------------------+
//|                                Event handling                                 |
//+-------------------------------------------------------------------------------+

	protected void applySizeConstraints()
	{
		_rect.clampSize(_minSize, _maxSize);
	}

	override bool charEntered(in dchar chr)
	{
		return true;
	}

	void handleResize() @trusted
	{
		applySizeConstraints();
	}

	override void focusGained()
	{
	}
	
	override void focusLost()
	{
	}

	override bool pointerPressed(ivec2 pointerPosition, PointerButton button)
	{
		if (!_staticRect.contains(pointerPosition)) return false;
		return false;
	}

	override bool pointerReleased(ivec2 pointerPosition, PointerButton button)
	{
		if (!_staticRect.contains(pointerPosition)) return false;
		return false;
	}

	override bool pointerMoved(ivec2 newPointerPosition)
	{
		if (!_staticRect.contains(newPointerPosition)) return false;
		window.hoveredWidget = this;
		return true;
	}

	override void pointerEntered()
	{
	}
	
	override void pointerLeaved()
	{
	}

	override bool keyPressed(in KeyCode key, KeyModifiers modifiers)
	{
		return true;
	}

	override bool keyReleased(in KeyCode key, KeyModifiers modifiers)
	{
		return true;
	}

//+-------------------------------------------------------------------------------+
//|                                  Properties                                   |
//+-------------------------------------------------------------------------------+

	/** 
	Anchored sides of the widget.
	Can be constructed by ORing Anchor values.
	Examples:
	---
	widget.anchor = Anchor.LEFT | Anchor.RIGHT;
	 ---
	See_Also:
	 	_anchor
	*/
	override uint anchor() @property
	{
		return _anchor;
	}

	/// ditto
	override void anchor(uint newAnchor) @property
	{
		_anchor = newAnchor;
	}

	override dstring caption() @property
	{
		if (_textLine is null) return "";
		return _textLine.text;
	}

	override void caption(dstring newCaption) @property
	{
		if (_textLine is null) return;
		return _textLine.text = newCaption;
	}

	// Used internally by gui renderer.
	override ref TexRectArray[string] geometry() @property @safe
	{
		return _geometry;
	}

	uvec2 minSize() @property
	{
		return _minSize;
	}

	uvec2 maxSize() @property
	{
		return _maxSize;
	}

	override void parent(GuiWidget newParent) @property
	{
		_parent = newParent;
		if (skin is null && _parent !is null && _isInheritsSkin) skin = _parent.skin;
	}

	override GuiWidget parent() @property @safe
	{
		return _parent;
	}

	override void position(ivec2 newPosition) @property @safe
	{
		_rect.x = newPosition.x;
		_rect.y = newPosition.y;
		if (parent !is null)
			calcStaticRect(parent.staticRect);
	}

	override ivec2 position() @property @safe
	{
		return ivec2(_rect.x, _rect.y);
	}

	override void rect(Rect newRect) @property @safe
	{
		_rect = newRect;

		discardGeometry();
		handleResize();

		if (parent !is null)
			calcStaticRect(parent.staticRect);
	}

	override Rect rect() @property @safe
	{
		return _rect;
	}

	override void size(in uint newWidth, in uint newHeight) @property
	{
		_rect.width = newWidth;
		_rect.height = newHeight;
		
		discardGeometry();
		handleResize();
	}

	override void size(uvec2 newSize) @property
	{
		_rect.width = newSize.x;
		_rect.height = newSize.y;

		discardGeometry();
		handleResize();
	}

	override uvec2 size() @property
	{
		return uvec2(_rect.width, _rect.height);
	}

	override void skin(GuiSkin newSkin) @property
	{
		if (newSkin is null || newSkin == _skin) return;
		_skin = newSkin;
		if (auto style = _skin[_styleName])
		{
			_minSize = style["normal"].minSize;
			_maxSize = style["normal"].maxSize;
			applySizeConstraints();
		}
		applySizeConstraints();
		discardGeometry();
		skinChanged();
	}

	override GuiSkin skin() @property @safe
	{
		return _skin;
	}

	protected Font getStyleFont(in GuiSkin skin, in string styleName)
	{
		if (skin[styleName] is null) return null;
		string font = _skin[_styleName].fontName;
		Font* fontPtr = font in _skin.fonts;
		if (fontPtr is null) return null;
		return *fontPtr;
	}

	protected void setTextLineFont()
	{
		if (_textLine is null) return;
		_textLine.font = getStyleFont(_skin, _styleName);
	}

	void handleParentSkinChange()
	{
		if (_isInheritsSkin)
		{
			skin = parent.skin;
		}
	}

	protected void skinChanged()
	{
	}

	bool isInheritsSkin() @property
	{
		return _isInheritsSkin;
	}

	void isInheritsSkin(bool inherits) @property
	{
		if (_isInheritsSkin == inherits) return;

		_isInheritsSkin = inherits;

		if (_isInheritsSkin && parent !is null)
		{
			GuiSkin parentSkin = parent.skin;

			if (_skin != parentSkin)
				skin = parentSkin;
		}
	}

	override string state() @property @safe
	{
		return _state;
	}

	override void state(string newStateName) @property
	{
		_state = newStateName;
		if (_skin is null || _skin[_styleName] is null) return;
		GuiStyleState newState = _skin[_styleName][_state];
		_rect.clampSize(newState.minSize, newState.maxSize);
	}

	override Rect staticRect() @property @safe
	{
		return _staticRect;
	}

	override string styleName() @property @safe
	{
		return _styleName;
	}

	override void styleName(string newStyleName) @property @safe
	{
		_styleName = newStyleName;
	}

	override int width() @property @safe
	{
		return _rect.width;
	}

	override void width(int newWidth) @property
	{
		_rect.width = newWidth;
		discardGeometry();
		handleResize();
	}
	
	override int height() @property @safe
	{
		return _rect.height;
	}

	override void height(int newHeight) @property
	{
		_rect.height = newHeight;
		discardGeometry();
		handleResize();
	}

	override int x() @property @safe
	{
		return _rect.x;
	}

	override void x(int newX) @property @trusted
	{
		_rect.x = newX;

		if (parent !is null)
			calcStaticRect(parent.staticRect);
	}
	
	override int y() @property @safe
	{
		return _rect.y;
	}

	override void y(int newY) @property @trusted
	{
		_rect.y = newY;

		if (parent !is null)
			calcStaticRect(parent.staticRect);
	}

	override void onClick(ClickHandler newHandler) @property @safe
	{
		_onClick = newHandler;
	}

	override void onEnter(RegularHandler newHandler) @property @safe
	{
		_onEnter = newHandler;
	}

	override void onLeave(RegularHandler newHandler) @property @safe
	{
		_onLeave = newHandler;
	}

	override GuiWindow window() @property @safe
	{
		if (_parent is null) return null;
		return _parent.window;
	}

protected:

	void discardGeometry() @safe
	{
		_geometry = null;
	}

	/** Stores sides to which this widget is anchored.
	See_Also:
	 	anchor
	*/
	uint _anchor = defaultAnchor;

	/// GuiRenderer can save here widgets geometry.
	/// This geometry can be shared between few widgets.
	TexRectArray[string] _geometry;

	/// Widget name. Mainly used when assembling anchovy.gui.
	string		_name;

	//TODO: Remove this
	/// Can be used by widget for displaying caption.
	TextLine	_textLine;

	/// Parent of this widget. Can be null if have no parent.
	GuiWidget	_parent;

	/// Position is relative to parent's position.
	Rect		_rect;

	/// Position is relative to window origin.
	/// Calculated in calculateStaticRect
	Rect		_staticRect;

	/// Widget size specified when creating widget.
	/// Used by layout manager to decide widgets preffered size. 
	/// Currrently used as minimal size for frame.
	uvec2 _prefferedSize;

	/// Minimal and maximal sizes of the widget, specified by skin;
	uvec2 _minSize;
	/// ditto
	uvec2 _maxSize;

	/// 
	bool _isEnabled = true;

	/// True if widget inherits skin of parent.
	bool _isInheritsSkin = true;

	/// if true 
	bool _isContentVisible = true;

	/// 
	bool _isBackgroundVisible = true;

	/// Individual skin of the widget. Must be initialized as null if inherited from parent.
	GuiSkin		_skin;

	/// Current style state.
	string		_state = "normal";

	/// Style name in current skin.
	string		_styleName;

//+-------------------------------------------------------------------------------+
//|                                  Event handlers                               |
//+-------------------------------------------------------------------------------+

	/// Will be called when pointer button is clicked.
	ClickHandler	_onClick;

	/// Will be called when pointer have been moved onto the widget.
	RegularHandler	_onEnter;

	/// Will be called when pointer have been moved from the widget.
	RegularHandler	_onLeave;


}