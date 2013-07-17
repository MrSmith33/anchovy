module build;

//version = showBuildString;

import std.file;
import std.process;
import std.stdio;

alias packageSettings pack;
struct packageSettings
{
	string name;
	string sourcePath;
	string[] importPaths;
	string[] libFiles;
	string outputFile;
	string flags;
}

void buildPackage(ref packageSettings settings, string flags)
{
	string buildString = "dmd.exe "~flags~" ";
	foreach(string filename; dirEntries(settings.sourcePath, "*.d", SpanMode.depth))
	{
		buildString ~= '"'~filename~"\" ";
	}
	
	foreach(path; settings.importPaths)
	{
		buildString ~= "\"-I"~path~"\" ";
	}
	
	foreach(lib; settings.libFiles)
	{
		buildString ~= "\""~lib~"\" ";
	}
	
	buildString ~= settings.flags~" \"-of"~settings.outputFile~"\" ";
	
	version(showBuildString) writeln(buildString);
	
	auto result = executeShell(buildString);
	if (result.status != 0)
	{
		writeln("Compilation failed:\n"~result.output);
	}
}

void main()
{
	auto imports = ["import", "deps\\dlib-master", "deps\\derelict-master\\import"];
	auto packages = [pack("core", "import\\anchovy\\core", imports, [], "lib\\debug\\core.lib", "-lib"), 
	pack("graphics", "import\\anchovy\\graphics", imports,[], "lib\\debug\\graphics.lib", "-lib"), 
	pack("gui", "import\\anchovy\\gui", imports,[], "lib\\debug\\gui.lib", "-lib"), 
	pack("utils", "import\\anchovy\\utils", imports,[], "lib\\debug\\utils.lib", "-lib"), 
	pack("examples", "examples", imports,["lib\\debug\\core.lib", "lib\\debug\\graphics.lib", "lib\\debug\\gui.lib", "lib\\debug\\utils.lib","deps\\derelict-master\\lib\\dmd\\DerelictUtil.lib", "deps\\derelict-master\\lib\\dmd\\DerelictGLFW3.lib", "deps\\derelict-master\\lib\\dmd\\DerelictGL3.lib", "deps\\derelict-master\\lib\\dmd\\DerelictFT.lib", "deps\\derelict-master\\lib\\dmd\\DerelictFI.lib","deps\\dlib-master\\dlib.lib"], "bin\\guidemo.exe", "")];
	
	foreach(ref pack; packages)
		buildPackage(pack, "-debug -gc");
}