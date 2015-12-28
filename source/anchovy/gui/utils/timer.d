/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.utils.timer;

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
