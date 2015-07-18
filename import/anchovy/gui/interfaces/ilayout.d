/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.interfaces.ilayout;

import anchovy.gui;

///
/// Relative positions will be only affected. Static positions must be updated by container.
interface ILayout
{
	/// Called by widget when MinimizeLayout event occurs.
	void minimize(Widget root);

	/// Called by widget when ExpandLayout event occurs.
	void expand(Widget root);

	/// Called by container to update its children positions and sizes.
	void onContainerResized(Widget root, ivec2 oldSize, ivec2 newSize);
}
