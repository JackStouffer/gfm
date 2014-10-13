module gfm.sdl2.framecounter;

import std.string;

import derelict.sdl2.sdl;

import gfm.core.queue,
       gfm.sdl2.sdl;

/// Utility class which gives time delta between frames, and 
/// logs some framerate statistics.
/// Useful for a variable timestep application.
deprecated("FrameCounter is deprecated, it always felt out of place here."
           " Use the tharsis-prof package or a stand-alone frame profiler instead.")
final class FrameCounter
{
    public
    {
        /// Creates a FrameCounter, SDL must be initialized.
        this(SDL2 sdl)
        {
            _sdl = sdl;
            _firstFrame = true;
            _elapsedTime = 0;
            _frameTimes = new RingBuffer!ulong(10);
        }

        /// Marks the beginning of a new frame.
        /// Returns: Current time difference since last frame, in milliseconds.
        ulong tickMs()
        {
            if (_firstFrame)
            {
                _lastTime = SDL_GetTicks();
                _firstFrame = false;
                _frameTimes.pushBack(0);
                return 0; // no advance for first frame
            }
            else
            {
                uint now = SDL_GetTicks();
                uint delta = now - _lastTime;
                _elapsedTime += delta;
                _lastTime = now;
                _frameTimes.pushBack(delta);
                return delta;
            }
        }

        /// Marks the beginning of a new frame.
        /// Returns: Current time difference since last frame, in seconds.
        deprecated alias tick = tickSecs;
        double tickSecs()
        {
            return tickMs() * 0.001;
        }

        /// Returns: Elapsed time since creation, in milliseconds.
        ulong elapsedTimeMs() const
        {
            return _elapsedTime;
        }

        /// Returns: Elapsed time since creation, in seconds.
        double elapsedTime() const
        {
            return _elapsedTime * 0.001;
        }

        /// Returns: Displayable framerate statistics.
        string getFPSString()
        {
            double sum = 0;
            double min = double.infinity;
            double max = -double.infinity;
            foreach(ulong frameTime; _frameTimes[])
            {
                if (frameTime < min)
                    min = frameTime;
                if (frameTime > max)
                    max = frameTime;
                sum += frameTime;
            }

            double avg = sum / cast(double)(_frameTimes[].length);
            int avgFPS = cast(int)(0.5 + ( avg != 0 ? 1000 / avg : 0 ) );
            int avgdt = cast(int)(0.5 + avg);

            return format("FPS: %s dt: avg %sms min %sms max %sms", avgFPS, avgdt, min, max);
        }
    }

    private
    {
        SDL2 _sdl;
        RingBuffer!ulong _frameTimes;
        bool _firstFrame;
        uint _lastTime;
        ulong _elapsedTime;
    }
}

