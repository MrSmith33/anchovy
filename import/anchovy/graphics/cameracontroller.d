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

module anchovy.graphics.cameracontroller;

import anchovy.graphics.all;
import dlib.math.vector;

abstract class CameraController
{
	this(){};
	this(Camera cam){ _camera = cam; }
	
	
	@property{	
		Vector3f 	position();
		void	position(Vector3f);
		
		Vector3f	target();
		void	target(Vector3f);
		
		Vector3f	up();
		void	up(Vector3f);
		
		/++
		 + Returns current controller sensivity.
		 + 
		 + Returns: Current controller sensivity.
		 + 
		 + Examples:
		 + --------------------
		 + float CurrentSensivity = camControl.sensivity;
		 + --------------------
		 +/
		float sensivity(){ return _sensivity; }
		
		/++
		 + Sets new rotation sensivity.
		 + Must be greater then zero.
		 + 
		 + Examples:
		 + --------------------
		 + camControl.sensivity( 100500.0f );
		 + --------------------
		 +/
		void sensivity(float newSensivity){
			if(newSensivity>0){
				_sensivity = newSensivity;	
			}
		}
		
		Camera camera(){ return _camera; }
	}
	
protected
		Camera _camera;
		float _sensivity = 1.0f;
	
}
