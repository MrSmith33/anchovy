/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.interfaces.iwidgetbehavior;

import anchovy.gui.widget;

abstract class IWidgetBehavior
{
	void attachPropertiesTo(Widget widget){}
	void attachTo(Widget widget);
}
