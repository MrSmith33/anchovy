/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.skin.jsonguiskinparser;

import std.array;
import std.conv;
import std.json;
import std.stdio;

import anchovy.core.types;

import anchovy.gui;


//version = debug_parser;

class SkinParserException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
	}
}

alias JSONValue[string] jsonObject;
alias JSONValue[] jsonArray;

static string[JSON_TYPE] jsonTypeNames;
static this()
{
	jsonTypeNames =
		[JSON_TYPE.STRING : "string",
		 JSON_TYPE.INTEGER : "int",
		 JSON_TYPE.UINTEGER : "uint",
		 JSON_TYPE.FLOAT : "float",
		 JSON_TYPE.OBJECT : "object",
		 JSON_TYPE.ARRAY : "array",
		 JSON_TYPE.TRUE : "true",
		 JSON_TYPE.FALSE : "false",
		 JSON_TYPE.NULL : "null",];
}

static const string returnDefault = "if (value.type == JSON_TYPE.NULL) return defaultValue;";

class JsonGuiSkinParser
{
	string[] warnings;
	string[] errors;

	void warn(string message)
	{
		warnings ~= message;
	}

	GuiSkin parse(string skinData)
	{
		GuiSkin skin = new GuiSkin();

		try
		{
			auto jsonValue = parseJSON(skinData);

			skin.name = getValue!string("name", jsonValue);
			skin.textureFilename = getValue!string("image", jsonValue);
			skin.fontInfos = parseFonts(getValue!jsonArray("fonts", jsonValue));
			
			foreach(i, ref value; getValue!jsonArray("styles", jsonValue))
			{
				string styleName = getValue!string("name", value);

				if (styleName == "")
				{
					warn("No style name was specified for style no " ~ to!string(i + 1) ~ " in skin " ~ skin.name);
					continue;
				}

				skin.styles[styleName] = parseStyle(value, styleName);
			}

		}
		catch(JSONException exception)
		{
			throw new SkinParserException(exception.msg);
		}

		if (!warnings.empty)
		{
			foreach(warning; warnings)
				writeln("Warning: ", warning);
				
			warnings = [];
		}

		return skin;
	}

	/**
	 * len 	Result
	 * 1 	Поля будут установлены одновременно от каждого края элемента.
	 * 2 	Первое значение устанавливает поля от верхнего и нижнего края, второе — от левого и правого.
	 * 3 	Первое значение задает поле от верхнего края, второе — одновременно от левого и правого края, а третье — от нижнего края.
	 * 4 	Поочередно устанавливается поля от верхнего, правого, нижнего и левого края.
	 */

	GuiStyle parseStyle(ref JSONValue value, string styleName)
	{
		expect(JSON_TYPE.OBJECT, value);
		
		GuiStyle parsedStyle = new GuiStyle();
		GuiStyleState nullState;

		parsedStyle.states["normal"] = parseStyleState(value, nullState);
		parsedStyle.fontName = getValue!string("font", value, "normal");

		jsonArray states = getValue!jsonArray("states", value);

		foreach(i, ref state; states)
		{
			string stateName = getValue!string("state", state);

			if (stateName == "")
			{
				warn("No state name was specified for state no "~to!string(i+1)~" in style "~styleName);
				continue;
			}

			version(debug_parser) writeln("stateName: ", stateName);

			parsedStyle.states[stateName] = parseStyleState(state, parsedStyle.states["normal"]);
		}

		return parsedStyle;
	}

	GuiStyleState parseStyleState(ref JSONValue stateValue, ref GuiStyleState globalState)
	{
		GuiStyleState parsedStyleState;
		expect(JSON_TYPE.OBJECT, stateValue);

		jsonArray fixedBordersValue = getValue!jsonArray("fixedBorders", stateValue);
		parsedStyleState.fixedBorders = RectOffset(parseRectOffset(fixedBordersValue, globalState.fixedBorders.arrayof));

		jsonArray contentPaddingValue = getValue!jsonArray("contentPadding", stateValue);
		parsedStyleState.contentPadding = RectOffset(parseRectOffset(contentPaddingValue, globalState.contentPadding.arrayof));

		jsonArray rectValue = getValue!jsonArray("rect", stateValue);
		parsedStyleState.atlasRect = Rect(parseRect(rectValue, globalState.atlasRect.arrayof));

		jsonArray outlineValue = getValue!jsonArray("outline", stateValue);
		parsedStyleState.outline = RectOffset(parseRectOffset(outlineValue, globalState.outline.arrayof));

		jsonArray minSize = getValue!jsonArray("minSize", stateValue);
		parsedStyleState.minSize = parseSize(minSize, ivec2(parsedStyleState.atlasRect.width, parsedStyleState.atlasRect.height));

		jsonArray maxSize = getValue!jsonArray("maxSize", stateValue);
		parsedStyleState.maxSize = parseSize(maxSize, ivec2(0, 0));

		return parsedStyleState;
	}

	FontInfo[] parseFonts(jsonArray inArray)
	{
		FontInfo[] outFonts;

		foreach(font; inArray)
		{
			outFonts ~= FontInfo(getValue!string("name", font),
			                     getValue!string("file", font),
			                     getValue!uint("size", font),
			                     getValue!int("verticalOffset", font));
		}

		version(debug_parser) writeln(outFonts);

		return outFonts;
	}

private:

	int[4] parseRect(jsonArray inArray, int[4] defaultValue = [0, 0, 0, 0])
	{
		if (inArray.length == 0) return defaultValue;
		
		int[4] outArray;

		foreach(i, ref element; inArray)
		{
			if (i > 3)
			{
				warn("Rect with more than 4 values found");
				break;
			}

			outArray[i] = getValue!int(element);
		}

		return outArray;
	}

	ivec2 parsePoint(jsonArray inArray, ivec2 defaultValue = ivec2(0, 0))
	{
		if (inArray.length == 0)
			return defaultValue;

		if (inArray.length == 1)
			return ivec2(getValue!int(inArray[0]), 0);

		return ivec2(getValue!int(inArray[0]), getValue!int(inArray[1]));
	}

	ivec2 parseSize(jsonArray inArray, ivec2 defaultValue = ivec2(0, 0))
	{
		if (inArray.length == 0)
			return defaultValue;

		if (inArray.length == 1)
		{
			uint size = getValue!uint(inArray[0]);

			return ivec2(size, size);
		}

		return ivec2(getValue!uint(inArray[0]), getValue!uint(inArray[1]));
	}

	int[4] parseRectOffset(jsonArray inArray, int[4] defaultValue = [0, 0, 0, 0])
	{
		if (inArray.length == 0)
		{
			return defaultValue;
		}
		else if (inArray.length == 1)
		{
			int val = getValue!int(inArray[0]);

			return [val, val, val, val];
		}
		else if (inArray.length == 2)
		{
			int vert = getValue!int(inArray[0]);
			int hor = getValue!int(inArray[1]);

			return [hor, hor, vert, vert];
		}
		else if (inArray.length == 3)
		{
			int top = getValue!int(inArray[0]);
			int hor = getValue!int(inArray[1]);
			int bottom = getValue!int(inArray[2]);

			return [hor, hor, top, bottom];
		}
		else
		{
			int top = getValue!int(inArray[0]);
			int right = getValue!int(inArray[1]);
			int bottom = getValue!int(inArray[2]);
			int left = getValue!int(inArray[3]);

			if (inArray.length > 4) warn("Rect with more than 4 values found");

			return [left, right, top, bottom];
		}
	}

	void expect(JSON_TYPE type, ref JSONValue value, string file = __FILE__, size_t line = __LINE__)
	{
		if(value.type != type && value.type != JSON_TYPE.NULL)
		{
			throw new SkinParserException("Wrong JSON type. " ~
			                              jsonTypeNames[value.type] ~
			                              " found while " ~
			                              jsonTypeNames[type] ~
			                              " expected", file, line);
		}
	}

	T getValue(T)(string key, ref JSONValue objectValue, T defaultValue = T.init)
	{
     	JSONValue* targetValue = key in objectValue.object;

	 	if (targetValue is null)
	 	{
	 		return defaultValue;
	 	}
	 	else
	 	{
	 		return getValue!T(*targetValue, defaultValue);
	 	}
	}

	T getValue(T)(ref JSONValue value, T defaultValue = T.init)
	{
		static if (is(T : string))
		{
			expect(JSON_TYPE.STRING, value);
			mixin(returnDefault);
			return value.str;
		}
		else static if (is(T : int))
		{
			expect(JSON_TYPE.INTEGER, value);
			mixin(returnDefault);
			return cast(int)value.integer;
		}
		else static if (is(T : uint))
		{
			expect(JSON_TYPE.UINTEGER, value);
			mixin(returnDefault);
			return cast(uint)value.uinteger;
		}
		else static if(is(T : float))
		{
			expect(JSON_TYPE.FLOAT, value);
			mixin(returnDefault);
			return cast(float)value.floating;
		}
		else static if(is(T : jsonObject))
		{
			expect(JSON_TYPE.OBJECT, value);
			mixin(returnDefault);
			return value.object;
		}
		else static if(is(T : jsonArray))
		{
			expect(JSON_TYPE.ARRAY, value);
			mixin(returnDefault);
			return value.array;
		}
		else static if(is(T : bool))
		{
			if(value.type == JSON_TYPE.TRUE)
				return true;
			else if (value.type == JSON_TYPE.FALSE)
				return false;
			else if (value.type == JSON_TYPE.NULL)
				return defaultValue;
			else throw new SkinParserException("Wrong JSON type. " ~
			                                   jsonTypeNames[value.type] ~
			                                   " found while boolean expected");
		}
	}
}