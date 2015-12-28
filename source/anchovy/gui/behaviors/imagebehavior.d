/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.behaviors.imagebehavior;

import anchovy.graphics.texture;
import anchovy.graphics.bitmap;

import anchovy.gui;
import anchovy.gui.interfaces.iwidgetbehavior;

class ImageBehavior : IWidgetBehavior
{
	override void attachTo(Widget widget)
	{
		widget.removeEventHandlers!DrawEvent();

		GuiContext context = widget.getPropertyAs!("context", GuiContext);
		auto bitmap = new Bitmap(4);
		Texture texture = new Texture(bitmap, TextureTarget.target2d, TextureFormat.rgba);

		widget.setProperty!"texture"(texture);
		widget.setProperty!"bitmap"(bitmap);
		widget.addEventHandler(&handleDraw);

		auto bitmapSlot = {widget["prefSize"] = cast(ivec2)widget.getPropertyAs!("bitmap", Bitmap).size;};
		bitmap.dataChanged.connect(bitmapSlot);

		void onBitmapChanging(FlexibleObject obj, Variant* newBitmap)
		{
			widget.getPropertyAs!("bitmap", Bitmap).dataChanged.disconnect(bitmapSlot);
			if ((*newBitmap).get!Bitmap is null) return;

			auto bitmap = (*newBitmap).get!Bitmap;

			Texture texture = widget.getPropertyAs!("texture", Texture);
			texture.bitmap = bitmap;
			bitmap.dataChanged.connect(bitmapSlot);

			obj["prefSize"] = cast(ivec2)bitmap.size;
		}

		widget.property("bitmap").valueChanging.connect(&onBitmapChanging);

		void onTextureChanged(FlexibleObject obj, Variant newTexture)
		{
			if (auto bitmap = widget.getPropertyAs!("bitmap", Bitmap))
				bitmap.dataChanged.disconnect(bitmapSlot);

			auto texture = newTexture.get!Texture;
			if (texture is null) return;

			widget.setProperty!("bitmap", Bitmap)(texture.bitmap);
			texture.bitmap.dataChanged.connect(bitmapSlot);

			obj["prefSize"] = cast(ivec2)texture.bitmap.size;
		}

		widget.property("texture").valueChanged.connect(&onTextureChanged);
	}

	bool handleDraw(Widget widget, DrawEvent event)
	{
		if(widget.getPropertyAs!("hasBack", bool) && event.sinking)
		{
			Texture texture = widget.getPropertyAs!("texture", Texture);
			//writeln(texture.size);
			if (texture is null) return true;
			event.guiRenderer.renderer.setColor(Color(255, 255, 255, 255));
			event.guiRenderer.renderer.drawTexRect(widget["staticRect"].get!Rect, Rect(ivec2(0,0), cast(ivec2)texture.size), texture);
		}
		return true;
	}
}
