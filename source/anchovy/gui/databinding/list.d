/**
Copyright: Copyright (c) 2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.databinding.list;

import anchovy.utils.signal : Signal;

abstract class List(ItemType)
{
	alias ItemAddedSignal = Signal!(size_t, ItemType);
	alias ItemRemovedSignal = Signal!(size_t, ItemType);
	alias ItemChangedSignal = Signal!(size_t, ItemType);
	alias ListChangedSignal = Signal!();

	ItemAddedSignal itemAddedSignal;
	ItemRemovedSignal itemRemovedSignal;
	ItemChangedSignal itemChangedSignal;
	ListChangedSignal listChangedSignal;


	ItemType opIndex(size_t index);
	ItemType opIndexAssign(ItemType data, size_t index);

	size_t length() @property;

	size_t push(ItemType item);
	ItemType remove(size_t index);

	final ItemType pop()
	{
		return remove(length - 1);
	}
}

import std.algorithm : remove;

class SimpleList(ItemType) : List!ItemType
{
protected:
	ItemType[] _array;

public:

	override ItemType opIndex(size_t index)
	{
		return _array[index];
	}

	override ItemType opIndexAssign(ItemType data, size_t index)
	{
		_array[index] = data;
		listChangedSignal.emit();
		itemChangedSignal.emit(index, _array[index]);

		return _array[index];
	}

	override size_t length() @property
	{
		return _array.length;
	}

	override size_t push(ItemType item)
	{
		_array ~= item;

		listChangedSignal.emit();
		itemAddedSignal.emit(length - 1, _array[length-1]);

		return length - 1;
	}

	override ItemType remove(size_t index)
	{
		ItemType item = _array[index];
		_array.remove(index);

		listChangedSignal.emit();
		itemRemovedSignal.emit(index, item);

		return item;
	}
}
