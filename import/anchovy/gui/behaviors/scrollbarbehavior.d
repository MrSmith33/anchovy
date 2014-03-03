/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.scrollbarbehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

// version = Button_debug;

alias ScrollbarBehaviorVert = ScrollbarBehavior!true;
alias ScrollbarBehaviorHori = ScrollbarBehavior!false;

class ScrollbarBehavior(bool vertical) : IWidgetBehavior
{
protected:
	Widget _slider;
	Widget _body;
	Widget _widget;
	double _sliderSize = 0.5;
	double _sliderPos = 0.0;

public:

	override void attachTo(Widget widget)
	{
		_body = widget["subwidgets"].get!(Widget[string]).get("body", null);
		_slider = widget["subwidgets"].get!(Widget[string]).get("slider", null);
		_widget = widget;

		if (_slider && _body)
		{
			_body.size.valueChanged.connect((FlexibleObject obj, Variant value){updateSize();});
			_slider.position.valueChanging.connect(&handleSliderMoved);

			_widget["sliderSize"] = new ValueProperty(_widget, cast(double)_sliderSize);
			_widget["sliderPos"] = new ValueProperty(_widget, cast(double)_sliderPos);

			_widget.property("sliderPos").valueChanging.connect(&handleSliderPositionChanging);

			updateSize();
		}
	}

	void updateSize()
	{
		static if (vertical)
		{
			_slider.setProperty!"size"(ivec2(_body.size.value.get!ivec2.x, cast(int)(_body.size.value.get!ivec2.y * _sliderSize)));
			_slider.setProperty!"position"(ivec2(0, 
				cast(int)((_body.size.value.get!ivec2.y - _slider["size"].get!ivec2.y) * _widget["sliderPos"].get!double)));
		}
		else
		{
			_slider.setProperty!"size"(ivec2(cast(int)(_body.size.value.get!ivec2.x * _sliderSize), _body.size.value.get!ivec2.y));
			_slider.setProperty!"position"(
				ivec2(cast(int)((_body.size.value.get!ivec2.x - _slider["size"].get!ivec2.x) * _widget["sliderPos"].get!double), 0));
		}
	}

	void handleSliderPositionChanging(FlexibleObject widget, Variant* position)
	{
		double* pos = (*position).peek!double;
		if (!pos) *pos = (*position).coerce!double;

		if (pos)
		{
			if (*pos < 0) *pos = 0;
			else if (*pos > 1.0) *pos = 1.0;
		}

		*position = *pos;
	}

	void handleSliderMoved(FlexibleObject slider, Variant* position)
	{
		int newPosition;
		int bodySize;
		int sliderSize;

		static if (vertical)
		{
			int pos = position.get!ivec2.y;
			bodySize = _body.size.value.get!ivec2.y;
			sliderSize = _slider.size.value.get!ivec2.y;
			newPosition = pos < 0 ? 0 : (pos + sliderSize > bodySize ? bodySize - sliderSize : pos);
			(*position) = ivec2(0, newPosition);
		}
		else
		{
			int pos = position.get!ivec2.x;
			bodySize = _body.size.value.get!ivec2.x;
			sliderSize = _slider.size.value.get!ivec2.x;
			newPosition = pos < 0 ? 0 : (pos + sliderSize > bodySize ? bodySize - sliderSize : pos);
			(*position) = ivec2(newPosition, 0);
		}

		double sliderPos = cast(double)newPosition / cast(double)(bodySize - sliderSize);
		_widget["sliderPos"] = sliderPos is double.nan ? 0 : sliderPos;

		writeln("slider moved ", sliderPos);
	}

}