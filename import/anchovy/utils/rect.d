module anchovy.utils.rect;

import std.conv;
import dlib.math.utils: clampValue = clamp;
import dlib.math.vector;
import anchovy.utils.rectoffset;

struct Rect
{
	union
	{
		struct
		{
			int x, y, width, height;
		}
		int[4] arrayof;
	}

	this(int[4] array) @safe
	{
		arrayof = array;
	}

	this(int a, int b, int c, int d) @safe
	{
		x = a;
		y = b;
		width = c;
		height = d;
	}

	this(ivec2 position, ivec2 size)
	{
		x = position.x;
		y = position.y;
		width = size.x;
		height = size.y;
	}

	void move(ivec2 delta)
	{
		x += delta.x;
		y += delta.y;
	}

	bool contains(ivec2 point) nothrow @trusted
	{
		return contains(point.x, point.y);
	}

	bool contains(int pointX, int pointY) nothrow @trusted
	{
		if(pointX < x) return false;
		if(pointY < y) return false;
		if(pointX > x + width) return false;
		if(pointY > y + height) return false;
		return true;
	}

	void cropOffset(RectOffset offset) nothrow
	{
		x += offset.left;
		y += offset.top;
		width -= offset.horizontal;
		height -= offset.vertical;
	}

	Rect croppedByOffset(RectOffset offset) nothrow
	{
		Rect result;
		result.x = x + offset.left;
		result.y = y + offset.top;
		result.width = width - offset.horizontal;
		result.height = height - offset.vertical;
		return result;
	}

	/// Increases size by deltaSize.
	void grow(ivec2 deltaSize)
	{
		width += deltaSize.x;
		height += deltaSize.y;

		if (width < 0) width = 0;
		if (height < 0) height = 0;
	}

	Rect growed(ivec2 deltaSize)
	{
		Rect newRect;
		newRect.width = width + deltaSize.x;
		newRect.height = height + deltaSize.y;
		
		if (newRect.width < 0) newRect.width = 0;
		if (newRect.height < 0) newRect.height = 0;

		return newRect;
	}

	Rect relativeToParent(Rect parent) @safe
	{
		return Rect(x + parent.x, y + parent.y, width, height);
	}

	/// Returns true if size was changed
	void clampSize(uvec2 minSize, uvec2 maxSize) nothrow
	{
		if (maxSize.x == 0)
		{
			width = clampValue!uint(width, minSize.x, width);
		}
		else
		{
			width = clampValue!uint(width, minSize.x, maxSize.x);
		}

		if (maxSize.y == 0)
		{
			height = clampValue!uint(height, minSize.y, height);
		}
		else
		{
			height = clampValue!uint(height, minSize.y, maxSize.y);
		}
	}
	
	ivec2 position() @property
	{
		return ivec2(x, y);
	}

	ivec2 size() @property
	{
		return ivec2(width, height);
	}

	string toString()
	{
		return to!string(arrayof);
	}
}

unittest
{
	Rect rect = Rect(-5, -5, 10, 10);

	assert(!rect.contains(-10, 0));
	assert(!rect.contains(6, 0));
	assert(!rect.contains(0, -6));
	assert(!rect.contains(9, 6));
	assert(rect.contains(0, 0));
}