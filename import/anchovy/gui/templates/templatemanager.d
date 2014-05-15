/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.templates.templatemanager;

import std.file : read;

import anchovy.gui;

import anchovy.gui.templates.widgettemplate;
import anchovy.gui.templates.templateparser;

class TemplateManager
{
	WidgetTemplate[string] templates;
	private TemplateParser parser;

	this(TemplateParser parser)
	{
		assert(parser);
		this.parser = parser;
	}

	void parseFile(string filename)
	{
		string file = cast(string)read(filename);
		parseString(file, filename);
	}

	void parseString(string str, string filename = null)
	{
		auto parsedTemplates = parser.parse(str, filename);
		
		foreach(templ; parsedTemplates)
		{
			templates[templ.tree.properties["type"].get!string] = templ;
		}
	}

	/// Returns true if given type name exists.
	bool typeExists(string type)
	{
		return !!(type in templates);
	}

	/// Returns null if not found.
	WidgetTemplate getTemplate(string type)
	{
		return templates.get(type, null);
	}
}