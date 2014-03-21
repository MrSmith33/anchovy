/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.scrollbarbehavior;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

alias ScrollbarBehaviorVert = ScrollbarBehavior!true;
alias ScrollbarBehaviorHori = ScrollbarBehavior!false;

class ScrollbarBehavior(bool vertical) : IWidgetBehavior
{
protected:
	Widget _slider;
	Widget _body;
	Widget _widget;

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

			_widget["sliderSize"] = new ValueProperty(_widget, 0.5);
			_widget["sliderPos"] = new ValueProperty(_widget, 0.0);

			_widget.property("sliderPos").valueChanging.connect(&handleSliderPositionChanging);
			_widget.property("sliderSize").valueChanging.connect(&handleSliderPositionChanging);

			updateSize();
		}
	}

	void updateSize()
	{
		static if (vertical)
		{
			_slider.setProperty!"size"(ivec2(_body.size.value.get!ivec2.x, cast(int)(_body.size.value.get!ivec2.y * _widget["sliderSize"].get!double)));
			_slider.setProperty!"position"(ivec2(0, 
				cast(int)((clamp(_body.size.value.get!ivec2.y - _slider["size"].get!ivec2.y, 0, int.max)) * _widget["sliderPos"].get!double)));
		}
		else
		{
			_slider.setProperty!"size"(ivec2(cast(int)(_body.size.value.get!ivec2.x * _widget["sliderSize"].get!double), _body.size.value.get!ivec2.y));
			_slider.setProperty!"position"(
				ivec2(cast(int)((_body.size.value.get!ivec2.x - _slider["size"].get!ivec2.x) * _widget["sliderPos"].get!double), 0));
		}
	}

	double clampToNormal(double num)
	{
		return num < 0 ? 0 : (num > 1.0 ? 1.0 : num);
	}

	void handleSliderPositionChanging(FlexibleObject widget, Variant* position)
	{
		double* pos = (*position).peek!double;
		if (!pos) *pos = (*position).coerce!double;

		if (pos)
		{
			*pos = clampToNormal(*pos);
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
			newPosition = pos < 0 ? 0 : ((pos + sliderSize) > bodySize ? bodySize - sliderSize : pos);
			(*position) = ivec2(newPosition, 0);
		}

		double sliderPos = cast(double)newPosition / cast(double)(bodySize - sliderSize);
		_widget["sliderPos"] = sliderPos is double.nan ? 0 : sliderPos;

		//writeln("slider moved ", sliderPos);
	}

}