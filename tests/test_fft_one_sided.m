function tests = test_fft_one_sided
%TEST_FFT_ONE_SIDED Unit tests for the spectral helper.

tests = functiontests(localfunctions);

end

function testSineAmplitude(testCase)
repoDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoDir, 'src', 'matlab', 'common'));

samplingFrequency = 100;
time = (0:199).' / samplingFrequency;
[frequency, amplitude] = fft_one_sided(sin(2 * pi * 5 * time), samplingFrequency);
[peakAmplitude, peakIndex] = max(amplitude(2:end));

verifyEqual(testCase, frequency(peakIndex + 1), 5, 'AbsTol', 1e-12);
verifyEqual(testCase, peakAmplitude, 1, 'AbsTol', 1e-12);
end
