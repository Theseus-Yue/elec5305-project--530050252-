clear; close all; clc;

audioFile = 'Household.WAV';
nFFT = 2048;  % FFT length
hop = 512;    % STFT hop size

%% 1. Read audio
[x, Fs] = audioread(audioFile);
if size(x,2) > 1
    x = mean(x,2);  % Convert to mono if stereo
end
T = length(x)/Fs;
fprintf('Loaded %s: %.2f s, Fs=%d\n', audioFile, T, Fs);

%% 2. Visualize waveform of original audio
figure;
subplot(2,1,1);
plot((0:length(x)-1)/Fs, x, 'b');
xlabel('Time [s]');
ylabel('Amplitude');
title('Waveform of Original Audio');
grid on;

%% 3. Compute STFT magnitude spectrum
[STFT, f, t_spec] = stft(x, Fs, ...
    'Window', hann(nFFT,'periodic'), ...
    'OverlapLength', nFFT-hop, ...
    'FFTLength', nFFT);

S_mag = abs(STFT);
S_db = 20*log10(max(S_mag,1e-10));  % Convert to dB

%% 4. Visualize spectrogram
subplot(2,1,2);
imagesc(t_spec, f, S_db);
axis xy;  % Frequency increases from bottom to top
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogram of Original Audio');
colorbar;
