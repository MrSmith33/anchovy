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

module anchovy.gui.templatemanager;

import std.file : read;

import anchovy.gui.all;

import anchovy.gui.widgettemplate;
import anchovy.gui.templateparser;

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