module build;

version = showBuildString;

import std.file : dirEntries, SpanMode;
import std.process : executeShell;
import std.stdio : writeln;

import std.algorithm : findSplitBefore;
import std.range : retro, chain;
import std.array : array;
import std.conv : to;

enum 
{
	executable,
	staticLib,
	sharedLib,
}

alias pack = packageSettings;
struct packageSettings
{
	string name;
	string sourcePath;
	string[] importPaths;
	string[] libFiles;
	string outputName;
	uint targetType;
	string linkerFlags;
}

version(Windows)
{
	enum exeSuffix = ".exe";
	enum exePrefix = "";
	enum staticLibSuffix = ".lib";
	enum staticLibPrefix = "";
	enum sharedLibSuffix = ".dll";
	enum sharedLibPrefix = "";
}
version(linux)
{
	enum exeSuffix = "";
	enum exePrefix = "";
	enum staticLibSuffix = ".a";
	enum staticLibPrefix = "lib";
	enum sharedLibSuffix = ".so";
	enum sharedLibPrefix = "lib";
}

string withSuffixPrefix(string filePath, string prefix, string suffix)
{
	auto splitted = filePath.retro.findSplitBefore("/");

    return chain(splitted[1].retro,
		prefix,
		splitted[0].array.retro,
		suffix).array.to!string;
}

void buildPackage(ref packageSettings settings, string flags)
{
	string buildString = "dmd"~exeSuffix~" "~flags~" ";
	if (settings.targetType == staticLib) buildString ~= "-lib ";
	
	foreach(string filename; dirEntries(settings.sourcePath, "*.d", SpanMode.depth))
	{
		buildString ~= '"'~filename~"\" ";
	}

	foreach(path; settings.importPaths)
	{
		buildString ~= "-I\""~path~"\" ";
	}
	
	foreach(lib; settings.libFiles)
	{
		buildString ~= "\""~withSuffixPrefix(lib, staticLibPrefix, staticLibSuffix)~"\" ";
	}

	buildString ~= settings.linkerFlags;

	buildString ~= " -of\"";

	switch(settings.targetType)
	{
		case executable: buildString ~= withSuffixPrefix(settings.outputName, exePrefix, exeSuffix) ~ "\""; break;
		case staticLib: buildString ~= withSuffixPrefix(settings.outputName, staticLibPrefix, staticLibSuffix) ~ "\""; break;
		case sharedLib: buildString ~= withSuffixPrefix(settings.outputName, sharedLibPrefix, sharedLibSuffix) ~ "\""; break;
		default: assert(false);
	}
	
	version(showBuildString) writeln(buildString);
	
	auto result = executeShell(buildString);
	if (result.status != 0)
	{
		writeln("Compilation failed:\n"~result.output);
	}
}

void main()
{
	auto imports = ["import", "deps/dlib", "deps/derelict-fi-master/source", "deps/derelict-sdl2-master/source", "deps/derelict-ft-master/source", "deps/derelict-gl3-master/source", "deps/derelict-glfw3-master/source", "deps/derelict-util-1.0.0/source", "deps/sdlang-d-0.8.4/src"];
	auto packages = [
	pack("core", "import/anchovy/core", imports, [], "lib/debug/core", staticLib), 
	pack("graphics", "import/anchovy/graphics", imports,[], "lib/debug/graphics", staticLib), 
	pack("gui", "import/anchovy/gui", imports,[], "lib/debug/gui", staticLib), 
	pack("utils", "import/anchovy/utils", imports,[], "lib/debug/utils", staticLib), 
	pack("examples", "examples", imports,
		["deps/derelict-util-1.0.0/lib/DerelictUtil","deps/derelict-glfw3-master/lib/DerelictGLFW3", "deps/derelict-gl3-master/lib/DerelictGL3", "deps/derelict-ft-master/lib/DerelictFT", "deps/derelict-fi-master/lib/DerelictFI", "deps/dlib/dlib","lib/debug/utils", "lib/debug/core", "lib/debug/graphics", "deps/sdlang-d-0.8.4/sdlang-d", "lib/debug/gui"].retro.array, "bin/guidemo", executable)];
	
	foreach(ref pack; packages)
		buildPackage(pack, "-debug -de -gc -w -m32");
}
