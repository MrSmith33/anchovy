/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.interfaces.iguiskinparser;

import anchovy.gui;

interface IGuiSkinParser
{
	GuiSkin parse(string skinData);
}

