/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.templates.templateparser;

import sdlang;

import anchovy.gui.templates.widgettemplate;

import anchovy.gui;

//version = TemplateParser_debug;

struct TemplateParserResult
{
	WidgetTemplate[] parsedTemplates;
	string[] filesToParse;
}

final class TemplateParser
{
	TemplateParserResult parse(string source, string filename = "")
	{
		WidgetTemplate[] templates;

		Tag root;
	
		try
		{
			root = parseSource(source, filename);
		}
		catch(SDLangParseException e)
		{
			stderr.writeln(e.msg);
			return TemplateParserResult();
		}

		string[] filesToParse;

		foreach(templateImport; root.tags)
		{
			if (templateImport.name == "import")
			{
				if (templateImport.values.length == 0)
				{
					stderr.writefln("Invalid import statement at %s", templateImport.location);
					continue;
				}

				auto value = templateImport.values[0];
				if (value.type != typeid(string))
				{
					stderr.writefln("Invalid filename %s of import statement at %s", value, templateImport.location);
					continue;
				}

				filesToParse ~= templateImport.values[0].get!string ~ ".sdl";
			}
		}

		foreach(templ; root.maybe.namespaces["template"].tags)
		{
			templates ~= parseTemplate(templ);
		}

		return TemplateParserResult(templates, filesToParse);
	}

	WidgetTemplate parseTemplate(Tag templateTag)
	{
		WidgetTemplate templ = new WidgetTemplate;
		Tag forwardedPropertiesTag;
		Tag treeTag;
		templ.name = templateTag.name;

		foreach(section; templateTag.tags)
		{
			switch(section.name)
			{
				case "properties":
					forwardedPropertiesTag = section;
					break;
				case "tree":
					treeTag = section;
					break;
				default:
					stderr.writeln("template:", templ.name, " Error: unknown section found: ", section.name);
			}
		}

		templ.baseType = "widget"; // default super is widget or widget factory with the same type.

		templ.tree = parseTreeSection(treeTag, templ);
		templ.tree.properties["type"] = templateTag.name;

		//----------------------- Parse template properties ------------------------
		string childrenContainer;

		foreach(prop; templateTag.attributes)
		{
			switch(prop.name)
			{
				case "extends":
					templ.baseType = prop.value.coerce!string;
					break;
				case "container":
					if (auto container = prop.value.coerce!string in templ.subwidgetsmap)
					{
						if (childrenContainer !is null)
						{
							stderr.writefln("template:%s Error: Multiple children containers not allowed. Overriding with last", templ.name);
						}
						childrenContainer = prop.value.coerce!string;
					}
					else
					{
						stderr.writeln("template:", templ.name, " Error: In template children container widget '", prop.name, "' not found");
					}
					break;
				default:
					stderr.writeln("template:", templ.name, " Error: In template unknown property found: ", prop.name);
			}
		}

		if (childrenContainer)
		{
			templ.container = childrenContainer;
		}

		if (forwardedPropertiesTag)
		{
			parseForwardedProperties(forwardedPropertiesTag, templ);
		}

		return templ;
	}

	SubwidgetTemplate parseTreeSection(Tag section, WidgetTemplate templ)
	{
		auto subwidget = new SubwidgetTemplate;

		// Adding subwidgets.
		foreach(sub; section.tags)
		{
			auto subsub = parseTreeSection(sub, templ);

			subwidget.subwidgets ~= subsub;

			if (auto nameProperty = "name" in subsub.properties)
			{
				templ.subwidgetsmap[nameProperty.coerce!string] = subsub;
			}
		}

		// Adding widget properties.
		foreach(prop; section.attributes)
		{
			if (prop.value.type !is typeid(DateTimeFracUnknownZone))
				subwidget.properties[prop.name] = *cast(Variant*)&prop.value;
		}

		// Adding widget flags.
		foreach(value; section.values)
		{
			subwidget.properties[value.coerce!string] = Variant(true);
		}

		subwidget.properties["type"] = section.name;

		return subwidget;
	}

	void parseForwardedProperties(Tag section, WidgetTemplate templ)
	{
		// key target subtemplate. Key target property name, root property name.
		ForwardedProperty[][string] properties;
		
		// fetch all forwarded properties for template templ
		foreach(prop; section.tags)
		{
			ForwardedProperty property = ForwardedProperty(prop.name, prop.name);
			string subwidgetName;

			foreach(attrib; prop.attributes)
			{
				switch(attrib.name)
				{
					case "subwidget":
						subwidgetName = attrib.value.get!string;
						break;
					case "property":
						property.targetPropertyName = attrib.value.get!string;
						break;
					default:
						stderr.writeln("template:", templ.name, " Error: unknown attribute '",
							attrib.name , "' for forwarded property '", prop.name, "' found");
				}
			}

			if (subwidgetName == "")
			{
				stderr.writeln("template:", templ.name, " Error: no target widget for forwarded property: '",
					property.propertyName, "' specified, skipping property");
				continue; // Skip property.
			}
			else if (subwidgetName !in templ.subwidgetsmap)
			{
				stderr.writeln("template:", templ.name, " Error: target widget '",subwidgetName,
					"' for forwarded property '", property.propertyName, "' not found, skipping property");
				continue; // Skip property.
			}

			if (auto forwardedProperties = subwidgetName in properties)
			{
				import std.algorithm;
				if (canFind(*forwardedProperties, property))
				{
					stderr.writeln("template:", templ.name, " Error: duplicate for forwarded property '",
						property.targetPropertyName, ":", property.propertyName, "' found, skipping duplicate");
					continue; // Skip property.
				}
			}

			properties[subwidgetName] ~= property;
			version(TemplateParser_debug)writefln("Found forwarding %s.%s to %s.%s",
				templ.name, property.propertyName, subwidgetName, property.targetPropertyName);

			SubwidgetTemplate target = templ.subwidgetsmap[subwidgetName];
			// Add info about forwarded property to target subtemplate, so at instantiation time we can lookup it
			target.forwardedProperties ~= property;
		}
	}
}