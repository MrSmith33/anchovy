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

module anchovy.graphics.renderers.ogl3renderer;

import std.conv;
import std.stdio;
import std.string;

import derelict.freeimage.freeimage;
import derelict.freetype.ft;

import anchovy.utils.string;

public import anchovy.core.types;

//import anchovy.graphics.all;
import anchovy.graphics.shaderprogram;
import anchovy.graphics.texture;

import anchovy.graphics.interfaces.irenderer;
import anchovy.core.interfaces.iwindow;


class Vbo
{
	this(uint bufferUsage, uint target = GL_ARRAY_BUFFER)
	{
		this.bufferUsage = bufferUsage;
		this.target = target;
		glGenBuffers(1, &handle);
	}

	void close()
	{
		glDeleteBuffers(1, &handle);
	}

	ref const(void[]) data(void[] newData) @property
	{
		_data = newData;
		glBindBuffer(target, handle);
		glBufferData(target, _data.length, _data.ptr, bufferUsage);
		glBindBuffer(target, 0);
		return _data;
	}

	ref const(void[]) data() @property
	{
		return _data;
	}

	void bind()
	{
		glBindBuffer(target, handle);
	}

	void unbind()
	{
		glBindBuffer(target, 0);
	}

	uint handle;
	uint bufferUsage;
	uint target;
	void[] _data;
}

class Vao
{
	this()
	{
		glGenVertexArrays(1, &handle);
	}
	void close()
	{
		glDeleteVertexArrays(1, &handle);
	}
	void bind()
	{
		glBindVertexArray(handle);
	}

	static void unbind()
	{
		glBindVertexArray(0);
	}
	uint handle;
}

string primVertTex2d = `#version 330
layout (location = 0) in vec2 position;
layout (location = 1) in vec2 texCoord;
uniform sampler2D gSampler;
uniform vec2 gHalfTarget;
uniform vec2 gPosition;
out vec2 texCoord0;

void main()
{
	gl_Position = vec4((position.x + gPosition.x) / gHalfTarget.x - 1,
					   1 - ((position.y + gPosition.y) / gHalfTarget.y),
					   0.0, 1.0);
	ivec2 texSize = textureSize(gSampler, 0);
	texCoord0 = vec2(texCoord.x/texSize.x, texCoord.y/texSize.y);
}
`;

string primFragTex2d=`#version 330
in vec2 texCoord0;
out vec4 FragColor;

uniform sampler2D gSampler;
uniform vec4 gColor = vec4(1, 1, 1, 1);

void main()
{
	FragColor = texture2D(gSampler, texCoord0)*gColor;
}`;

string primVertFill2d = `#version 330
in vec2 position;

uniform vec2 gHalfTarget;
uniform vec4 gColor;

smooth out vec4 theColor;

void main()
{
	gl_Position = vec4(((position.x+0.5)/gHalfTarget.x)-1, 1-((position.y+0.5)/gHalfTarget.y), 0.0, 1.0);
	theColor = gColor;
}
`;
//in smooth vec4 theColor DOESN'T works use smooth in unstead
string primFragFill2d=`#version 330
smooth in vec4 theColor;
out vec4 fragColor;

void main()
{
	fragColor = theColor;
}
`;

class Ogl3Renderer : IRenderer
{
	this(IWindow window)
	{
		this.window = window;

		FreeImage_SetOutputMessage(&FreeImageErrorHandler);
		shaders = new IdArray!(ShaderProgram);

		primShader = new ShaderProgram(primVertFill2d, primFragFill2d);
		if (!primShader.compile)
			throw new Exception(primShader.errorLog);
		registerShaderProgram(primShader);

		primTexShader = new ShaderProgram(primVertTex2d, primFragTex2d);
		if (!primTexShader.compile)
			throw new Exception("textured primitive shader failed compilation\n"~primTexShader.errorLog);
		registerShaderProgram(primTexShader);

		rectVao = new Vao;
		texRectVao = new Vao;
		rectVbo = new Vbo(GL_STREAM_DRAW);
		texRectVbo = new Vbo(GL_STREAM_DRAW);

		rectVao.bind;
			rectVbo.bind;
				glEnableVertexAttribArray(0);
				glVertexAttribPointer(0, 2, GL_SHORT, GL_FALSE, 2*short.sizeof, null);
			rectVbo.unbind;
		rectVao.unbind;
		texRectVao.bind;
			texRectVbo.bind;
				glEnableVertexAttribArray(0);
				glEnableVertexAttribArray(1);
				glVertexAttribPointer(0, 2, GL_SHORT, GL_FALSE, 4*short.sizeof, null);
				glVertexAttribPointer(1, 2, GL_SHORT, GL_FALSE, 4*short.sizeof, cast(void*)(2*short.sizeof));
			texRectVbo.unbind;
		texRectVao.unbind;
	}

	override void close()
	{
		foreach(k; shaders.array.byKey)
		{
			shaders[k].close;
			shaders.remove(k);
		}
	}

	void drawText(string text, uint x, uint y, uint font)
	{

	}

	override uint createShaderProgram(string vertexSource, string fragmentSource)
	{
		ShaderProgram newProgram = new ShaderProgram(vertexSource, fragmentSource);
		if (!newProgram.compile)
			writeln(newProgram.errorLog);
		return shaders.add(newProgram);
	}

	override uint registerShaderProgram(ShaderProgram program)
	{
		return shaders.add(program);
	}

	override Texture createTexture(string filename)
	in
	{
		assert(textures !is null);
	}
	body
	{
		Texture tex = new Texture(filename, TextureTarget.target2d, TextureFormat.rgba);
		return tex;
	}

	override void bindTexture(Texture texture, uint textureUnit = 0)
	in
	{
		assert(texture !is null);
	}
	body
	{
		texture.validateBind(textureUnit);
	}

	override void bindShaderProgram(uint programName)
	{
		ShaderProgram program = shaders[programName];
		assert(program !is null);
		bindShaderProgram(program);
	}

	override void bindShaderProgram(ref ShaderProgram program)
	{
		//if (currentShaderProgram == program) return;
		program.bind;
		_currentShaderProgram = program;
	}

	void setProgram(in uint program)
	{

	}

	override void setClearColor(in Color color)
	{
		with(color)
		{
			glClearColor(cast(float)r/255, cast(float)g/255, cast(float)b/255, cast(float)a/255);
		}
	}

	override void setColor(in Color newColor)
	{
		Color4f c4f = Color4f(newColor);
		if (c4f != curColor)
		{
			curColor = c4f;
		}
	}

	override void setColor(in Color4f newColor)
	{
		curColor = newColor;
	}

	override void enableAlphaBlending()
	{
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

	override void disableAlphaBlending()
	{
		glDisable(GL_BLEND);
	}

	override void drawRect(Rect rect)
	{
		bindShaderProgram(primShader);
		primShader.setUniform2!float("gHalfTarget", window.size.x/2, window.size.y/2);
		primShader.setUniform4!float("gColor", curColor.r, curColor.g, curColor.b, curColor.a);
		rectVao.bind;
		rectVbo.data = cast(short[])[rect.x, rect.y + rect.height, rect.x, rect.y,
					rect.x + rect.width, rect.y, rect.x + rect.width, rect.y + rect.height];
		glDrawArrays(GL_LINE_LOOP, 0, 4);
		rectVao.unbind;
	}

	override void fillRect(Rect rect)
	{
		bindShaderProgram(primShader);
		primShader.setUniform2!float("gHalfTarget", window.size.x/2, window.size.y/2);
		primShader.setUniform4!float("gColor", curColor.r, curColor.g, curColor.b, curColor.a);
		rectVao.bind;
		rectVbo.data = cast(short[])[rect.x, rect.y + rect.height, rect.x, rect.y,
					rect.x + rect.width, rect.y, rect.x, rect.y + rect.height,
					rect.x + rect.width, rect.y, rect.x + rect.width, rect.y + rect.height];
		glDrawArrays(GL_TRIANGLES, 0, 6);
		rectVao.unbind;
	}

	/+++++
	 + Draws textured rectangle to the current target
	 + target - position and size on the screen.
	 + source - position and size of rectangle in texture
	 +++++/
	override void drawTexRect(Rect target, Rect source, Texture texture)
	in
	{
		assert(texture !is null);
	}
	body
	{
		if (texture.size == uvec2(0, 0)) return;

		bindShaderProgram(primTexShader);
		primTexShader.setUniform2!float("gHalfTarget", window.size.x/2, window.size.y/2);
		primTexShader.setUniform2!float("gPosition", target.x, target.y);
		primTexShader.setUniform4!float("gColor", curColor.r, curColor.g, curColor.b, curColor.a);

		texture.validateBind();
		texRectVao.bind;
		int ty2 = source.y + source.height;
		int tx2 = source.x + source.width;
		int y2 = target.y + target.height;
		int x2 = target.x + target.width;
		texRectVbo.data = cast(short[])[0, target.height, source.x, ty2,
		                             0, 0, source.x, source.y,
		                             target.width, 0, tx2, source.y,
		                             0, target.height, source.x, ty2,
		                             target.width, 0, tx2, source.y,
									 target.width, target.height, tx2, ty2];
		glDrawArrays(GL_TRIANGLES, 0, 6);
		texRectVao.unbind;
		texture.unbind;
	}

	override void drawTexRectArray(TexRectArray array, ivec2 position, Texture texture, ShaderProgram customProgram = null)
	in
	{
		assert(texture !is null);
	}
	body
	{
		ShaderProgram program = customProgram;
		if (customProgram is null) program = primTexShader;
		drawTexRectArrayImpl(array, position, texture, program);
	}

	private void drawTexRectArrayImpl(TexRectArray array, ivec2 position, Texture texture, ShaderProgram program)
	in
	{
		assert(texture !is null);
	}
	body
	{
		bindShaderProgram(program);
		program.setUniform2!float("gHalfTarget", cast(float)window.size.x / 2, cast(float)window.size.y / 2);
		program.setUniform2!float("gPosition", position.x, position.y);
		program.setUniform4!float("gColor", curColor.r, curColor.g, curColor.b, curColor.a);

		texture.validateBind();
		array.bind;
		glDrawArrays(GL_TRIANGLES, 0, cast(uint)array.vertieces.length);
		array.unbind;
		texture.unbind;
	}

	override uvec2 windowSize()
	{
		return window.size();
	}

	override void flush()
	{
		window.swapBuffers;
	}

private:

	ShaderProgram _currentShaderProgram;
	ShaderProgram primShader;
	ShaderProgram primTexShader;

	IdArray!(ShaderProgram) shaders;

	IWindow	window;

	Vbo rectVbo;
	Vbo texRectVbo;
	Vao rectVao;
	Vao texRectVao;

	Color4f curColor;
	uint primColorLoc, primTargetSizeLoc;
}

extern(C)
{
	nothrow void FreeImageErrorHandler(FREE_IMAGE_FORMAT fif, const( char)*message)
	{
		try
		{
			writeln("\n*** ");
			if(fif != FIF_UNKNOWN) {
				writefln("%s Format\n", FreeImage_GetFormatFromFIF(fif));
			}
			writeln(ZToString(message));
			writeln(" ***\n");
		}
		catch(Exception e)
		{
			//writeln(e.msg);
		}
	}
}

