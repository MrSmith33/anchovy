#Anchovy

Set of multimedia libraries for games and gui applications.
Currently in active development, so usage in big projects is not recomended.
API can change with every version.

##Structure:
* anchovy.core - basic interfaces.
* anchovy.utils - additional helpers.
* anchovy.graphics - windowing and rendering. 
* anchovy.gui - skinnable graphical interface. The only usable package right now.

####planned packages:
* anchovy.audio - OpenAL sound manager.
* anchovy.network - client-server framework.
* anchovy.locale - translation management.

##Dependencies:
* dlib
* Derelict3:
* |-util
* |-opengl3
* |-glfw3
* |-sdl2 // currently optional.
* |-freeimage
* |-freetype

##Contributing:
Any improvements, bug reports, feature-requests are appreciated.

##Building (Now builds and works in linux too)
###Windows and linux
Go to deps folder.
Execute there:

	dub install --local derelict
	dub install --local dlib

Compile __Derelict3__ using its __build/build.d__ script 

and __dlib__ using

	dub build --arch=x86
x86_64 is not tested and probably won't work.

Build __build.d__ file located in root folder and run it. All .lib files will be located in __/lib__ folder. Gui demo will be located in __bin__ folder.

In order to run compiled example you will need to download resourses from [latest release](https://github.com/MrSmith33/anchovy/releases).

###Linux
You will need to install __glfw3__ library.
