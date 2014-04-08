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

module anchovy.gui.timer;

import core.time;
import std.math: isNaN, trunc;

import anchovy.gui;

/// Handler must number > 0 if custom repeat needed.
/// Timer will be added to queue again with nextTime set to number.
/// If number = 0 then nextTime will be set to Timer.delay.
/// If number < 0 or is nan, timer will be removed from queue.
alias double delegate(double dt) TimerHandler;

enum TimerTickType
{
	PROCESS_ALL_UNORDERED,
	PROCESS_ALL_ORDERED,
	PROCESS_LAST,
}

/// Provides basic timer functionality.
/// Designed to be used with TimerManager.
class Timer
{
	/// Used for initializing timer.
	/// Params:
	/// 	delay specifies the delay after which handler will be called.
	/// 	handler specifies handler to be called when delay exceeds.

	/// 	tickType sets processing method to be used with this timer.
	void initialize(double _firstTime, double _currentTime, double _delay, TimerHandler _handler, TimerTickType _tickType = TimerTickType.init)
	in
	{
		assert(_handler);
		assert(_delay > 0);
		assert(_firstTime > 0);
		assert(_currentTime > 0);
	}
	body
	{
		delay = _delay;
		lastUpdateTime = _currentTime;
		handler = _handler;
		tickType = _tickType;
		nextUpdateTime = _firstTime;
	}

	/// The whole delta time will be provided if currentTime > nextTime even when dt % thisDelay > 1.
	/// Timer will automaticaly decide to process only one period, or all. It can also process only the last update if needed.
	/// This method will be called only when currentTime > nextTime.
	void tick(double currentTime)
	{
		void updateNextTime(double newNextTime)
		{
			lastUpdateTime = nextUpdateTime;

			if (newNextTime == 0)
				nextUpdateTime += delay;
			else if (newNextTime > 0)
				nextUpdateTime += newNextTime;
			else
				nextUpdateTime = double.nan;
		}

		double newNextTime;
		
		with(TimerTickType)
		final switch(tickType)
		{
			case PROCESS_ALL_ORDERED:
			{
				newNextTime = handler(nextUpdateTime - lastUpdateTime);
				updateNextTime(newNextTime);
				break;
			}
			case PROCESS_ALL_UNORDERED:
			{
				while(currentTime > nextUpdateTime)
				{
					newNextTime = handler(nextUpdateTime - lastUpdateTime);
					updateNextTime(newNextTime);
				}
				break;
			}
			case PROCESS_LAST:
			{
				uint timesUpdated = cast(uint)trunc((currentTime - nextUpdateTime) / delay) + 1;
				nextUpdateTime += timesUpdated * delay;

				newNextTime = handler(timesUpdated);
				updateNextTime(newNextTime);
				break;
			}
		}
	}
	
	TimerHandler handler;

	TimerTickType tickType;

	double lastUpdateTime;
	double nextUpdateTime;
	double delay;
}