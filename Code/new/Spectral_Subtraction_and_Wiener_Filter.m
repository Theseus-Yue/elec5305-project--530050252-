% =====================================================================
% ELEC5305 — Baseline Denoising Algorithms
%
% This script implements two classical speech denoising methods:
%
%   • Spectral Subtraction
%        - Noise PSD estimated from first few frames
%        - Over-subtraction and spectral flooring
%        - Simple but prone to musical noise
%
%   • Wiener Filter
%        - Frequency-domain gain based on estimated SNR
%        - Smooth, low-complexity baseline widely used in DSP
%
% The script processes the noisy speech signal, outputs enhanced audio
% (y_spectral, y_wiener), compares waveforms, and computes SNR improvements.
%
% Purpose:
%   To provide baseline reference algorithms for evaluating the performance
%   of more advanced methods (Adaptive Spectral Subtraction, Hybrid-MMSE).
% =====================================================================


clear all;
close all;

%% Read audio signal
[x, Fs] = audioread('noisy_synthesized.wav');

% Convert to mono if stereo
if size(x,2) > 1
    x = mean(x, 2);
end

%% Signal parameters
frame_length = round(0.03 * Fs); % 30 ms frame
overlap = round(0.75 * frame_length); % 75% overlap
nfft = 2^nextpow2(frame_length); % FFT points

%% 1. Spectral Subtraction
function y_spectral = spectral_subtraction(x, frame_length, overlap, nfft)
    frames = buffer(x, frame_length, overlap);
    window = hann(frame_length);
    frames = frames .* window;

    % Assume first 5 frames are noise
    noise_frames = frames(:,1:5);
    noise_psd = mean(abs(fft(noise_frames, nfft)).^2, 2);

    Y = fft(frames, nfft);
    Y_mag = abs(Y);
    Y_phase = angle(Y);
    Y_psd = Y_mag.^2;

    alpha = 2; beta = 0.01;

    Y_clean = max(Y_psd - alpha*repmat(noise_psd,1,size(Y_psd,2)), beta*Y_psd) .* exp(1i*Y_phase);

    y_frames = real(ifft(Y_clean, nfft));
    y_spectral = overlap_add(y_frames(1:frame_length,:), frame_length, overlap);

    % Normalize to [-1, 1]
    y_spectral = y_spectral / max(abs(y_spectral));
end

%% 2. Wiener Filter
function y_wiener = wiener_filter(x, frame_length, overlap, nfft)
    frames = buffer(x, frame_length, overlap);
    window = hann(frame_length);
    frames = frames .* window;

    noise_frames = frames(:,1:5);
    noise_psd = mean(abs(fft(noise_frames, nfft)).^2, 2);

    Y = fft(frames, nfft);
    Y_psd = abs(Y).^2;

    snr_est = max(Y_psd ./ repmat(noise_psd,1,size(Y_psd,2)) - 1, 0);
    H = snr_est ./ (1 + snr_est);
    Y_clean = Y .* H;

    y_frames = real(ifft(Y_clean, nfft));
    y_wiener = overlap_add(y_frames(1:frame_length,:), frame_length, overlap);

    % Normalize to [-1, 1]
    y_wiener = y_wiener / max(abs(y_wiener));
end

%% Helper function: Overlap-add
function y = overlap_add(frames, frame_length, overlap)
    [~, num_frames] = size(frames);
    output_length = frame_length + (num_frames-1)*(frame_length-overlap);
    y = zeros(output_length,1);
    for i = 1:num_frames
        start_idx = (i-1)*(frame_length-overlap) + 1;
        end_idx = start_idx + frame_length - 1;
        y(start_idx:end_idx) = y(start_idx:end_idx) + frames(:,i);
    end
end

%% Apply denoising algorithms
y_spectral = spectral_subtraction(x, frame_length, overlap, nfft);
y_wiener = wiener_filter(x, frame_length, overlap, nfft);

%% Save processed audio
audiowrite('household_spectral.wav', y_spectral, Fs);
audiowrite('household_wiener.wav', y_wiener, Fs);

%% Plot waveforms
t_x = (0:length(x)-1)/Fs;
t_spec = (0:length(y_spectral)-1)/Fs;
t_wien = (0:length(y_wiener)-1)/Fs;

figure;
subplot(3,1,1); plot(t_x, x); title('Original Signal'); xlabel('Time (s)'); ylabel('Amplitude');
subplot(3,1,2); plot(t_spec, y_spectral); title('Spectral Subtraction'); xlabel('Time (s)'); ylabel('Amplitude');
subplot(3,1,3); plot(t_wien, y_wiener); title('Wiener Filter'); xlabel('Time (s)'); ylabel('Amplitude');

%% Compute SNR improvement
snr_original = snr(x);
snr_spectral = snr(y_spectral);
snr_wiener = snr(y_wiener);

fprintf('Original Signal SNR: %.2f dB\n', snr_original);
fprintf('Spectral Subtraction SNR: %.2f dB\n', snr_spectral);
fprintf('Wiener Filter SNR: %.2f dB\n', snr_wiener);
