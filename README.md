#Anchovy

Set of multimedia libraries for games and gui applications.
Currently in active development, so usage in big projects is not recomended.
API can change with every version.

##Structure:
* anchovy.core - basic interfaces.
* anchovy.utils - additional helpers.
* anchovy.graphics - windowing and rendering. 
* anchovy.gui - skinnable graphical interface. The only usable package right now.
###planned packages:
* anchovy.audio - OpenAL sound manager.
* anchovy.network - client-server framework.
* anchovy.locale - translation management.

##Dependencies:
* dlib
* Derelict3:
* |-util
* |-opengl3
* |-glfw3
* |-sdl2 // currenntly optional.
* |-freeimage
* |-freetype

##Contributing:
Any improvements, bug reports, feature-requests are appreciated.

##TODO
todo list is located at [trello](https://trello.com/board/anchovy/51c5d5e99f73cd373e00105a)

##Building
###Important: build file is currently not finished!!!
###Windows
Go to deps folder.
Execute there:

	dub install --local derelict
	dub install --local dlib

Compile __Derelict3__ using its __build/build.d__ script and __dlib__ using

	dub build

Then copy all __.lib__ files to the deps/lib folder.

Build __build.d__ file located in root folder and run it. All .lib files will be located in __/lib__ folder. Gui demo will be located in __bin__ folder.

In order to run compiled example you will need to download resourses from [latest release](https://github.com/MrSmith33/anchovy/releases).

###Linux and MacOS

Building on these platforms was not tested but in theory will work.

You will need to receive or build glfw library.