/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.templates.templatemanager;

import std.algorithm : canFind;
import std.array : Appender;
import std.file : read, exists;

import anchovy.gui;

import anchovy.gui.templates.widgettemplate;
import anchovy.gui.templates.templateparser;

class TemplateManager
{
	WidgetTemplate[string] templates;
	Appender!string parsedFiles;
	private TemplateParser parser;

	this(TemplateParser parser)
	{
		assert(parser);
		this.parser = parser;
	}

	void parseFile(string filename)
	{
		Appender!(string[]) filesToParse;
		filesToParse ~= filename;

		string nextFilename;

		while (filesToParse.data.length > 0)
		{
			nextFilename = filesToParse.data[$-1];
			writefln("Parsing %s", nextFilename);
			filesToParse.shrinkTo(filesToParse.data.length - 1);

			if (!parsedFiles.data.canFind(nextFilename))
			{
				parsedFiles ~= nextFilename;

				if (!exists(nextFilename))
				{
					stderr.writefln("Template file %s not found", nextFilename);
					continue;
				}

				string file = cast(string)read(nextFilename);

				filesToParse ~= parseString(file, nextFilename);
			}
		}
	}

	string[] parseString(string str, string filename = null)
	{
		TemplateParserResult parserResult = parser.parse(str, filename);

		foreach(templ; parserResult.parsedTemplates)
		{
			templates[templ.tree.properties["type"].get!string] = templ;
		}

		return parserResult.filesToParse;
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
