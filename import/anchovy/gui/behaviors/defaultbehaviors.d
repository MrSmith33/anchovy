/**
Copyright: Copyright (c) 2013 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.defaultbehaviors;

import anchovy.gui.interfaces.iwidgetbehavior;
import anchovy.gui.widget;

import anchovy.gui.behaviors.buttonbehavior;
import anchovy.gui.behaviors.checkbehavior;
import anchovy.gui.behaviors.dockingrootbehavior;
import anchovy.gui.behaviors.dragablebehavior;
import anchovy.gui.behaviors.editbehavior;
import anchovy.gui.behaviors.framebehavior;
import anchovy.gui.behaviors.imagebehavior;
import anchovy.gui.behaviors.labelbehavior;
import anchovy.gui.behaviors.listbehavior;
import anchovy.gui.behaviors.radiobehavior;
import anchovy.gui.behaviors.scrollbarbehavior;

import anchovy.gui.guicontext;

void attachDefaultBehaviors(GuiContext context)
{
	context.widgetFactories["widget"] = { return new Widget;};
	context.widgetFactories["check"] = {
		Widget widget = new Widget;

		widget["isChecked"]=false;
		widget["style"]="check";

		return widget;
	};


	context.behaviorFactories["dockingroot"] ~= delegate IWidgetBehavior (){return new DockingRootBehavior;};
	context.behaviorFactories["frame"] ~= delegate IWidgetBehavior (){return new FrameBehavior;};
	context.behaviorFactories["button"] ~= delegate IWidgetBehavior (){return new ButtonBehavior;};
	context.behaviorFactories["label"] ~= delegate IWidgetBehavior (){return new LabelBehavior;};
	context.behaviorFactories["image"] ~= delegate IWidgetBehavior (){return new ImageBehavior;};
	context.behaviorFactories["label"] ~= delegate IWidgetBehavior (){return new LabelBehavior;};
	context.behaviorFactories["check"] ~= delegate IWidgetBehavior (){return new CheckBehavior;};
	context.behaviorFactories["edit"] ~= delegate IWidgetBehavior (){return new EditBehavior;};
	context.behaviorFactories["dragable"] ~= delegate IWidgetBehavior (){return new DragableBehavior;};
	context.behaviorFactories["radio"] ~= delegate IWidgetBehavior (){return new RadioBehavior;};
	context.behaviorFactories["scrollbar-vert"] ~= delegate IWidgetBehavior (){return new ScrollbarBehaviorVert;};
	context.behaviorFactories["scrollbar-hori"] ~= delegate IWidgetBehavior (){return new ScrollbarBehaviorHori;};
	context.behaviorFactories["widgetlist"] ~= delegate IWidgetBehavior (){return new WidgetListBehavior;};
	context.behaviorFactories["stringlist"] ~= delegate IWidgetBehavior (){return new StringListBehavior;};
}