% =====================================================================
%  ELEC5305 — Analyze_audio
%
%  This script analyzes the noisy speech signal (noisy_synthesized.wav)
%  using key speech-audio features. It provides insight into the
%  characteristics of the noise and speech mixture before denoising.
%
%  Methods included:
%    • Time-domain waveform inspection
%    • STFT and spectrogram visualization
%    • RMS energy and peak amplitude
%    • Zero-Crossing Rate (ZCR)
%    • Spectral centroid and bandwidth
%    • Dominant frequency detection
%    • Low/Mid/High frequency energy distribution
%    • Average magnitude spectrum
%    • Frame-wise energy analysis
%
%  Purpose:
%    These measurements help understand noise structure, identify
%    dominant frequency bands, and explain why advanced denoising
%    methods (Adaptive / MMSE) are necessary.
% =====================================================================

audioFile = 'noisy_synthesized.wav';
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

%% ============================================================
% 5. Detailed Audio Analysis (added)
% ============================================================

fprintf("\n===== Audio Detailed Analysis =====\n");

% (1) Basic info
fprintf("Duration: %.2f seconds\n", T);
fprintf("Sampling rate: %d Hz\n", Fs);
fprintf("Total samples: %d\n", length(x));

% (2) RMS energy
rms_val = rms(x);
fprintf("RMS Energy: %.6f\n", rms_val);

% (3) Peak amplitude
peak_val = max(abs(x));
fprintf("Peak Amplitude: %.6f\n", peak_val);

% (4) Zero-Crossing Rate
zcr = sum(abs(diff(x>0))) / length(x);
fprintf("Zero Crossing Rate: %.4f (per sample)\n");

% (5) Spectral Centroid (brightness)
centroid = sum(f .* sum(abs(STFT),2)) / sum(sum(abs(STFT)));
fprintf("Spectral Centroid: %.2f Hz\n", centroid);

% (6) Spectral Bandwidth
mean_freq_mag = sum(abs(STFT),2) / size(STFT,2);
bw = sqrt(sum(((f - centroid).^2).*mean_freq_mag) / sum(mean_freq_mag));
fprintf("Spectral Bandwidth: %.2f Hz\n", bw);

% (7) Frequency with highest energy
[~, idx] = max(mean_freq_mag);
dominant_freq = f(idx);
fprintf("Dominant Frequency: %.2f Hz\n", dominant_freq);

% (8) Energy distribution
low_energy  = sum(mean_freq_mag(f <= 500));
mid_energy  = sum(mean_freq_mag(f > 500 & f <= 4000));
high_energy = sum(mean_freq_mag(f > 4000));
fprintf("Energy Low (0-500 Hz): %.3f\n", low_energy);
fprintf("Energy Mid (500-4k Hz): %.3f\n", mid_energy);
fprintf("Energy High (4k+ Hz): %.3f\n", high_energy);

% (9) Plot magnitude spectrum (average)
figure;
plot(f, mean_freq_mag);
title("Average Frequency Magnitude");
xlabel("Frequency (Hz)");
ylabel("Magnitude");

% (10) Time-domain energy distribution
frame_len = 1024;
frame_energy = buffer(x.^2, frame_len, frame_len/2, 'nodelay');
frame_energy = mean(frame_energy,1);

figure;
plot(frame_energy);
title("Frame-wise Energy Over Time");
xlabel("Frame Index");
ylabel("Energy");
