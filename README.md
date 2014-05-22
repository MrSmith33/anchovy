#Anchovy

Set of multimedia libraries for games and gui applications.
Currently in active development, so usage in big projects is not recomended.
API can change with every version.

![v0 6 0](https://cloud.githubusercontent.com/assets/1129910/3053639/9b3fac46-e1ac-11e3-8ba7-4ae4a67788d4.png)

##Structure:
* anchovy.core - basic interfaces.
* anchovy.utils - additional helpers.
* anchovy.graphics - windows and rendering.
* anchovy.gui - skinnable graphical interface. The only usable package right now.

####planned packages:
* anchovy.audio - OpenAL sound manager.
* anchovy.locale - translation management.

##Dependencies:
* dlib
* sdlang-d
* derelict-fi
* derelict-ft
* derelict-gl3
* derelict-glfw3
* derelict-sdl2
* derelict-util

##Contributing:
Any improvements, bug reports, feature-requests are highly appreciated.

##Building (Now builds and works in linux too)
###Windows and linux
You need to install all dependencies in deps folder. Actual packages can be found in build.d script.
Go to deps folder.

Execute there:

	dub install --local derelict- all-libs
	dub install --local dlib

Compile all __derelict-__ packages, __dlib__ and __sdlang-d__ packages using command:

	dub build --arch=x86

or --arch=x86_64 but it is not guaranteed to work.

If you face any issues with that feel free to post an issue.

Build __build.d__ file located in root folder and run it. All .lib/.a files must be located in __/lib__ folder (As used in build.d). Gui demo will be located in __bin__ folder.

In order to run compiled example you will need to download resourses from [latest release](https://github.com/MrSmith33/anchovy/releases) and install libraries if you are on linux. (glfw3, freetype, freeimage)
