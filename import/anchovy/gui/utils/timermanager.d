/**
Copyright: Copyright (c) 2013-2014 Andrey Penechko.
License: a$(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors: Andrey Penechko.
*/

module anchovy.gui.utils.timermanager;

public import anchovy.gui.utils.timer;

import core.time;
import std.array;
import std.algorithm;
import std.math: isNaN;
import std.stdio;

import anchovy.core.types;

class TimerManager
{
	this(double delegate() currentTimeCallback)
	in
	{
		assert(currentTimeCallback);
	}
	body
	{
		freeTimers.reserve(128);
		queue.reserve(128);
		currentTime = currentTimeCallback;
	}

	void updateTimers(double currentTime)
	{
		while(!queue.empty)
		{
			foreach(i, t; queue)
			{
				if (currentTime < t.nextUpdateTime)
					return;
				t.tick(currentTime);
				if (t.nextUpdateTime <= 0 || isNaN(t.nextUpdateTime))
				{
					freeTimers ~= t;
					queue = queue[0..i] ~ queue[i + 1..$];
					break;
				}
				if (t.tickType == TimerTickType.PROCESS_ALL_ORDERED)
				{
					break;
				}
			}
			sortTimers();
		}
	}

	/// 	initialDelay can be used to specify first delay to be different from following, that are set with delay parameter.
	/// 				Must be not NaN and > 0 to be used as first delay.
	Timer addTimer(double _delay, TimerHandler _handler, double _initialDelay = double.nan, TimerTickType _tickType = TimerTickType.init)
	{
		Timer timer = popFreeTimer();

		double startTime = currentTime();

		if (!isNaN(_initialDelay) || _initialDelay < 0)
		{
			startTime += _initialDelay;
		}
		else
			startTime += _delay;

		timer.initialize(startTime, currentTime(), _delay, _handler, _tickType);
		addToQueue(timer);

		return timer;
	}

	/// Resets timer's delay to newDelay if > 0 or to timer.delay otherwise.
	/// 
	/// Timer.delay will not be changed. Timer.nextUpdate only chabges.
	/// If you wish change Timer.delay you can do this by returning new delay in timer callback or 
	/// by setting it directly trough the reference returned by addTimer.
	void resetTimer(Timer timer, double newDelay = double.nan)
	{
		double _delay = newDelay;
		if (!(_delay > 0)) _delay = timer.delay;
		timer.nextUpdateTime = currentTime() + _delay;

		sortTimers();
	}

	void stopTimer(Timer timer)
	{
		foreach(i, ref t; queue)
		{
			if (t == timer)
			{
				freeTimers ~= t;
				queue = queue[0..i] ~ queue[i + 1..$];
				return;
			}
		}

		assert("Tried to stop not running timer");
	}

protected:

	Timer popFreeTimer()
	{
		if (freeTimers.length > 0)
		{
			scope(exit) freeTimers.popBack;
			return freeTimers.back;
		}
		else
		{
			return new Timer();
		}
	}

	/// timer must be previously removed from freeTimers.
	void addToQueue(Timer timer)
	{
		queue ~= timer;
		sortTimers();
	}

	void sortTimers()
	{
		sort!(q{a.nextUpdateTime < b.nextUpdateTime})(queue);
	}

	Timer[]	freeTimers;
	Timer[] queue;

	double delegate()	currentTime;
}