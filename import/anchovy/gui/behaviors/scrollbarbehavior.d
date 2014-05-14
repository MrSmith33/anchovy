/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.scrollbarbehavior;

import anchovy.core.math;
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

	override void attachPropertiesTo(Widget widget)
	{
		widget["sliderSize"] = new ValueProperty(_widget, 0.5);
		widget["sliderPos"] = new ValueProperty(_widget, 0.0);
	}

	override void attachTo(Widget widget)
	{
		_body = widget["subwidgets"].get!(Widget[string]).get("body", null);
		_slider = widget["subwidgets"].get!(Widget[string]).get("slider", null);
		_widget = widget;

		if (_slider && _body)
		{
			_body.size.valueChanged.connect((FlexibleObject obj, Variant value){updateSize();});

			_slider.addEventHandler(&handleSliderDrag);
			_slider.position.valueChanging.connect(&handleSliderMoving);

			_widget.property("sliderPos").valueChanging.connect(&handleSliderPositionChanging);
			_widget.property("sliderSize").valueChanging.connect(&handleSliderSizeChanging);

			updateSize();
		}
	}

	void updateSize()
	{
		ivec2 minSize = _slider.getPropertyAs!("minSize", ivec2);
		ivec2 bodySize = _body.size.value.get!ivec2;

		static if (vertical)
		{
			int size = cast(int)(bodySize.y * _widget["sliderSize"].get!double);
			_slider.setProperty!"size"(ivec2(bodySize.x, max(size, minSize.y)));

			int position = cast(int)((clamp(bodySize.y - _slider["size"].get!ivec2.y, 0, int.max)) *
				_widget["sliderPos"].get!double);
			_slider.setProperty!"position"(ivec2(0, position));
		}
		else
		{
			int size = cast(int)(bodySize.x * _widget["sliderSize"].get!double);
			_slider.setProperty!"size"(ivec2(max(size, minSize.x), bodySize.y));

			int position = cast(int)((clamp(bodySize.x - _slider["size"].get!ivec2.x, 0, int.max)) *
				_widget["sliderPos"].get!double);
			_slider.setProperty!"position"(ivec2(position, 0));
		}
	}

	double clampToNormal(double num)
	{
		return num < 0 ? 0 : (num > 1.0 ? 1.0 : num);
	}

	// clamps value to [0.0..1.0]
	void handleSliderPositionChanging(FlexibleObject widget, Variant* value)
	{
		double* val = (*value).peek!double;
		if (!val) *val = (*value).coerce!double;

		if (val)
		{
			*val = clampToNormal(*val);
		}

		*value = *val;
	}

	void handleSliderSizeChanging(FlexibleObject widget, Variant* value)
	{
		handleSliderPositionChanging(widget, value);

		updateSize();
	}

	bool handleSliderDrag(Widget widget, DragEvent event)
	{
		_slider["position"] = _slider.getPropertyAs!("position", ivec2) + event.delta;
		return true;
	}

	void handleSliderMoving(FlexibleObject slider, Variant* position)
	{
		int newPosition;
		int bodySize;
		int sliderSize;

		static if (vertical)
		{
			int pos = position.get!ivec2.y;
			bodySize = _body.size.value.get!ivec2.y;
			sliderSize = _slider.size.value.get!ivec2.y;
			newPosition = pos < 0 ? 0 : ((pos + sliderSize) > bodySize ? bodySize - sliderSize : pos);
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