module build;

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
	
	writeln(buildString);
	
	auto result = executeShell(buildString);
	if (result.status != 0)
		writeln("Compilation failed:\n"~result.output);
}

void main()
{
	auto packages = 
	[pack("core", "import\\anchovy\\core", ["import", "deps\\dlib-master", "deps\\derelict-master\\import"], [], "lib\\debug\\core.lib", "-lib"), 
	pack("graphics", "import\\anchovy\\graphics", ["import", "deps\\dlib-master", "deps\\derelict-master\\import"],[], "lib\\debug\\graphics.lib", "-lib"), 
	pack("gui", "import\\anchovy\\gui", ["import", "deps\\dlib-master", "deps\\derelict-master\\import"],[], "lib\\debug\\gui.lib", "-lib"), 
	pack("utils", "import\\anchovy\\utils", ["import", "deps\\dlib-master", "deps\\derelict-master\\import"],[], "lib\\debug\\utils.lib", "-lib"), 
	pack("examples", "examples", ["import", "deps\\dlib-master", "deps\\derelict-master\\import"],["lib\\debug\\core.lib", "lib\\debug\\graphics.lib", "lib\\debug\\gui.lib", "lib\\debug\\utils.lib","deps\\derelict-master\\lib\\dmd\\DerelictUtil.lib", "deps\\derelict-master\\lib\\dmd\\DerelictGLFW3.lib", "deps\\derelict-master\\lib\\dmd\\DerelictGL3.lib", "deps\\derelict-master\\lib\\dmd\\DerelictFT.lib", "deps\\derelict-master\\lib\\dmd\\DerelictFI.lib","deps\\dlib-master\\dlib.lib"], "bin\\guidemo.exe", ""), 
	];
	//auto result = executeShell(`dmd.exe -debug -gc "import\anchovy\core\input.d" "import\anchovy\core\math.d" "import\anchovy\core\types.d" "-Ideps\dlib-master" "-Ideps\derelict-master\\import" "-Iimport\anchovy\utils" -lib "-oflib\debug\core.lib"`);
	//if (result.status != 0) writeln("Compilation failed:\n", result.output);
	foreach(ref pack; packages)
	{
		buildPackage(pack, "-debug -gc");
		//buildPackage(pack, "-release");
	}
}