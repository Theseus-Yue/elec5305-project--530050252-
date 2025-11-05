% ==========================================================
% File: evaluation_metrics.m
% Purpose: Compare denoising results (SNR improvement)
% ----------------------------------------------------------
% This script loads original, noisy, and enhanced signals
% and computes performance metrics (SNR improvement).
% ==========================================================

clear; close all; clc;

fprintf('--- Evaluating Speech Enhancement Performance ---\n');

% Load test audio files
x_noisy = audioread('household.WAV');
x_wiener = audioread('household_wiener.wav');
x_adaptive = audioread('enhanced_household.wav');

% If you have clean reference (optional)
if isfile('input_clean.wav')
    x_clean = audioread('input_clean.wav');
else
    warning('No clean reference available. Using estimated reference = denoised Wiener result.');
    x_clean = x_wiener; % fallback for comparison
end

% Ensure equal length
min_len = min([length(x_noisy), length(x_wiener), length(x_adaptive), length(x_clean)]);
x_noisy = x_noisy(1:min_len);
x_wiener = x_wiener(1:min_len);
x_adaptive = x_adaptive(1:min_len);
x_clean = x_clean(1:min_len);

% --- Compute SNR values ---
snr_noisy = snr(x_clean, x_noisy - x_clean);
snr_wiener = snr(x_clean, x_wiener - x_clean);
snr_adaptive = snr(x_clean, x_adaptive - x_clean);

fprintf('\nSNR (dB):\n');
fprintf('Noisy Input        : %.2f dB\n', snr_noisy);
fprintf('Wiener Filter      : %.2f dB\n', snr_wiener);
fprintf('Adaptive Subtraction: %.2f dB\n', snr_adaptive);
fprintf('----------------------------------------------\n');
fprintf('Wiener Improvement : +%.2f dB\n', snr_wiener - snr_noisy);
fprintf('Adaptive Improvement: +%.2f dB\n', snr_adaptive - snr_noisy);
fprintf('----------------------------------------------\n');

% --- Visualization ---
figure('Name','SNR Comparison');
bar([snr_noisy, snr_wiener, snr_adaptive]);
set(gca, 'XTickLabel', {'Noisy', 'Wiener', 'Adaptive'});
ylabel('SNR (dB)');
title('SNR Comparison Across Methods');
grid on;
