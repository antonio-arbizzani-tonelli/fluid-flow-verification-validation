function [frequency, amplitude] = fft_one_sided(signal, samplingFrequency)
%FFT_ONE_SIDED Compute the one-sided amplitude spectrum of a real signal.

arguments
    signal double {mustBeVector, mustBeReal}
    samplingFrequency (1,1) double {mustBePositive}
end

signal = signal(:);
if numel(signal) < 2
    error('fft_one_sided:InsufficientData', ...
        'At least two samples are required to compute a spectrum.');
end
if any(isnan(signal))
    error('fft_one_sided:MissingData', ...
        'Interpolate or remove missing samples before the FFT.');
end

sampleCount = numel(signal);
signal = signal - mean(signal);
coefficients = fft(signal) / sampleCount;
positiveCount = floor(sampleCount / 2) + 1;

amplitude = abs(coefficients(1:positiveCount));
if sampleCount > 2
    if rem(sampleCount, 2) == 0
        amplitude(2:end-1) = 2 * amplitude(2:end-1);
    else
        amplitude(2:end) = 2 * amplitude(2:end);
    end
end
frequency = (0:positiveCount-1).' * samplingFrequency / sampleCount;

end
