/*
Copyright (c) 2013 Andrey Penechko

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license the "Software" to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

// Provides optimized ways to interact with FlexibleObject descendants properties, which have some
// built in properties.
//
// If property name is statically specified and there is built in property with that name then it will be bound to it without looking into property array,
// otherwise it will look into property array. This will speed up binding of properties which is accessible at compile time.
module anchovy.utils.flexibleobject.flexibleaccess;

import std.traits : hasMember;
import std.variant : Variant;
import anchovy.utils.flexibleobject.flexibleobject : FlexibleObject;


private template hasStaticProperty(T, string property)
{
	enum hasStaticProperty = __traits(hasMember, T, property);
}

//
//
static Variant getProperty(FlexibleObjectType : FlexibleObject)(FlexibleObjectType w, string propname)
{
	return w[propname];
}

// ditto
static Variant getProperty(string propname, FlexibleObjectType : FlexibleObject)(FlexibleObjectType w)
{
	static if(hasStaticProperty!(FlexibleObjectType, propname))
	{
		return mixin("w."~propname);
	}
	else
	{
		return w[propname];
	}
}

//
//
//
static T getPropertyAs(T)(string propname, FlexibleObject w)
{
	return w[propname].get!T;
}

// ditto
static T getPropertyAs(string propname, T, FlexibleObjectType : FlexibleObject)(FlexibleObjectType w)
{
	static if(hasStaticProperty!(FlexibleObjectType, propname))
	{
		return mixin("w."~propname~".value.get!T");
	}
	else
	{
		return w[propname].get!T;
	}
}

//
//
//
static T getPropertyAsBase(T)(string propname, FlexibleObject w)
{
	auto property = w[propname];

	if (property.convertsTo!T)
		return property.get!T;
	else
		return null;
}

// ditto
static T getPropertyAsBase(string propname, T, FlexibleObjectType : FlexibleObject)(FlexibleObjectType w)
{
	static if(hasStaticProperty!(FlexibleObjectType, propname))
	{
		auto property = mixin("w."~propname~".value");
	
		if (property.convertsTo!T)
			return property.get!T;
		else
			return null;
	}
	else
	{
		auto property = w[propname];
	
		if (property.convertsTo!T)
			return property.get!T;
		else
			return null;
	}
}


// Peek property value
static T* peekPropertyAs(T)(string propname, FlexibleObject w)
{
	return w[propname].peek!T;
}

// ditto
static T* peekPropertyAs(string propname, T, FlexibleObjectType : FlexibleObject)(FlexibleObjectType w)
{
	static if(hasStaticProperty!(FlexibleObjectType, propname))
	{
		return mixin("w."~propname~".value.peek!T");
	}
	else
	{
		return w[propname].peek!T;
	}
}

//
//
//
static T coercePropertyAs(T)(FlexibleObject w, string propname)
{
	return w[propname].coerce!T;
}

// ditto
static T coercePropertyAs(string propname, T, FlexibleObjectType : FlexibleObject)(FlexibleObjectType w)
{
	static if(hasStaticProperty!(FlexibleObjectType, propname))
	{
		return mixin("w."~propname~".value.coerce!T");
	}
	else
	{
		return w[propname].coerce!T;
	}
}

//
//
//
static void setProperty(ValueType)(FlexibleObject w, string propname, ValueType value)
{
	w[propname] = value;
}

// ditto
static void setProperty(string propname, ValueType, FlexibleObjectType : FlexibleObject)(FlexibleObjectType w, ValueType value)
{
	static if(hasStaticProperty!(FlexibleObjectType, propname))
	{
		auto property = mixin("w."~propname);
		if (property.value != value)
		{
			auto oldValue = property.value;

			static if (is(ValueType:Variant))
			{
				Variant var = value;
				property.valueChanged.emit(w, oldValue, &var);
				property.value = var;
			}
			else
			{
				Variant var = Variant(value);
				property.valueChanged.emit(w, oldValue, &var);
				property.value = var;
			}
		}
	}
	else
	{
		w[propname] = value;
	}
}

// Binds property1 to property2. when property2 changes, property1 will be notified.
static void bindProperty(T1 : FlexibleObject, T2 : FlexibleObject)(T1 object1, string property1, T2 object2, string property2)
{
	assert(false);
}
// ditto
static void bindProperty(string property1, string property2, T1 : FlexibleObject, T2 : FlexibleObject)(FlexibleObject object1, FlexibleObject object2)
{
	assert(false);
}
// ditto
static void bindProperty(string property2, T1 : FlexibleObject, T2 : FlexibleObject)(FlexibleObject object1, string property1, FlexibleObject object2)
{
	assert(false);
}
// ditto
static void bindProperty(string property1, T1 : FlexibleObject, T2 : FlexibleObject)(FlexibleObject object1, FlexibleObject object2, string property2)
{
	assert(false);
}