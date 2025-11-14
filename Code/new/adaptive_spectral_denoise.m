% ==========================================================
% Purpose:
%   Perform adaptive speech denoising using an improved
%   spectral subtraction algorithm.
%
% Features:
%   1. Automatic noise estimation from silent segments
%   2. Adaptive over-subtraction for non-stationary noise
%   3. Temporal smoothing to reduce musical artifacts
%   4. SNR calculation and spectrogram visualization
%
% Input:  noisy_synthesized.wav  (noisy audio)
% Output: enhanced_household.wav
%
% Author: Yue (Theseus-Yue)
% ==========================================================

clear; close all; clc;

%% Parameters
audioFile = 'noisy_synthesized.wav';
nFFT = 1024;           % FFT size
hop = nFFT/2;          % hop size (50% overlap)
alpha_min = 1.5;       % minimum over-subtraction factor
alpha_max = 4.0;       % maximum over-subtraction factor
noise_est_frames = 5;  % initial noise estimation frames
beta = 0.002;          % spectral floor (to avoid negative energy)

%% Read audio
[x, Fs] = audioread(audioFile);
if size(x,2) > 1
    x = mean(x,2); % convert to mono
end
fprintf('Loaded audio: %.2f seconds, Fs = %d Hz\n', length(x)/Fs, Fs);

%% STFT
win = hann(nFFT, "periodic");
[S, f, t] = stft(x, Fs, "Window", win, "OverlapLength", nFFT - hop, "FFTLength", nFFT);
mag = abs(S);
phase = angle(S);

%% Initial noise power estimate
noise_psd = mean(mag(:, 1:noise_est_frames).^2, 2);

%% Adaptive Spectral Subtraction
mag_clean = zeros(size(mag));

for i = 1:size(mag, 2)
    % Frame-level SNR estimate
    snr_est = 10 * log10(sum(mag(:,i).^2) / sum(noise_psd + eps));

    % Adaptive over-subtraction factor
    alpha = alpha_max - (alpha_max - alpha_min) * (snr_est / 20);
    alpha = max(alpha_min, min(alpha, alpha_max));

    % Update noise estimate using minimum statistics
    noise_psd = 0.9 * noise_psd + 0.1 * min(noise_psd, mag(:,i).^2);

    % Spectral subtraction
    subtracted = mag(:,i).^2 - alpha * noise_psd;
    subtracted = max(subtracted, beta * noise_psd);

    mag_clean(:,i) = sqrt(subtracted);
end

%% Reconstruct enhanced signal using inverse STFT
S_clean = mag_clean .* exp(1j * phase);
y = istft(S_clean, Fs, "Window", win, "OverlapLength", nFFT - hop, "FFTLength", nFFT);

%% Ensure valid signal for writing
y = real(y); % ensure real-valued signal
y(~isfinite(y)) = 0; % replace NaN or Inf
if max(abs(y)) > 0
    y = y / max(abs(y)); % normalize
end

%% Save audio
outputFile = fullfile(pwd, 'enhanced_household.wav');
audiowrite(outputFile, y, Fs);
fprintf('Enhanced audio saved as %s\n', outputFile);

%% Compute and display SNR improvement
fprintf('---\nComputing SNR improvement...\n');
snr_input = snr(x);
snr_output = snr(y);
fprintf('Input  SNR : %.2f dB\n', snr_input);
fprintf('Output SNR : %.2f dB\n', snr_output);

%% Visualization
figure('Name','Speech Denoising Comparison','Position',[200 200 800 600]);

subplot(3,1,1);
plot((0:length(x)-1)/Fs, x);
title('Original Noisy Audio');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(3,1,2);
plot((0:length(y)-1)/Fs, y);
title('Enhanced Audio (Adaptive Spectral Subtraction)');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(3,1,3);
spectrogram(y, win, nFFT-hop, nFFT, Fs, 'yaxis');
title('Spectrogram of Enhanced Audio');
colormap turbo;

fprintf('\nDone! You can now listen to the enhanced audio using:\n');
fprintf('soundsc(y, Fs)\n');
