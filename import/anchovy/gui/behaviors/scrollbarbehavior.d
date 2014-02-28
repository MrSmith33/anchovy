/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.scrollbarbehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

// version = Button_debug;

class ScrollbarBehavior : IWidgetBehavior
{
protected:
	Widget _slider;
	Widget _body;
	double _sliderSize = 0.5;
	double _sliderPos = 0.0;

public:

	override void attachTo(Widget widget)
	{
		_body = widget["subwidgets"].get!(Widget[string]).get("body", null);
		_slider = widget["subwidgets"].get!(Widget[string]).get("slider", null);

		if (_slider && _body)
		{
			_body.size.valueChanged.connect((FlexibleObject obj, Variant value){updateSize();});
			updateSize();
		}
	}

	void updateSize()
	{
		_slider.setProperty!"size"(ivec2(_body.size.value.get!ivec2.x, cast(int)(_body.size.value.get!ivec2.y * _sliderSize)));
		_slider.setProperty!"position"(ivec2(0, cast(int)((_body.size.value.get!ivec2.y - _slider["size"].get!ivec2.y) * _sliderPos)));
	}

}