%these values are the same for all filters according to the filter specs
ATT = -20*log10(0.01); 
TW = 100;
Fs = 44100;

%calculate Beta using function provided
if ATT < 21 
    Beta = 0;
elseif ATT >= 21 && ATT <= 50
    Beta = 0.5842*((ATT - 21)^0.4) + 0.07886*(ATT - 21);
else 
    Beta = 0.1102*(ATT - 8.7);
end

N = ceil(Fs*(ATT - 7.95)/(28.72*TW)); %calculate N using function
w = kaiser(2*N + 1, Beta)'; %find kaiser window vector and transpose it to match dimensions of impulse vectors
k = -N:1:N; %vector of inputs from -N to N

%impulse vectors for lowpass, bandpass, and highpass filters using functions
h_low = 2*100/Fs * sinc(2*100*k/Fs); %remove pi from formula in order to use sinc correctly
BW = 5000 - 100;
h_band = 2*BW/Fs * sinc(BW*k/Fs).*cos(2*pi*(100 + BW/2)*k/Fs);
h_high = 0 - 2*5000/Fs * sinc(2*5000*k/Fs);
h_high(N + 1) = 1 - 2*5000/Fs * sinc(2*5000*0/Fs); %highpass impulse value at k = 0

%multiply each impulse vector by the window vector
h_LP = h_low.*w;
h_BP = h_band.*w;
h_HP = h_high.*w;

x_white = randn(1, 44100*10); %white noise vector

%convolve each filter impulse with the inputs for a total of 3 outputs for each input
y_LP_white = conv(h_LP, x_white);
y_BP_white = conv(h_BP, x_white);
y_HP_white = conv(h_HP, x_white);

y_LP_music = conv(h_LP, x_music); %x_music MUST BE MANUALLY IMPORTED
y_BP_music = conv(h_BP, x_music);
y_HP_music = conv(h_HP, x_music);

%add up the 3 outputs for each input and change the gain of each one (10x --> 20dB gain)
y_LP_gain_white = 10*y_LP_white + y_BP_white + y_HP_white;
y_BP_gain_white = y_LP_white + 10*y_BP_white + y_HP_white;
y_HP_gain_white = y_LP_white + y_BP_white + 10*y_HP_white;

y_LP_gain_music = 10*y_LP_music + y_BP_music + y_HP_music;
y_BP_gain_music = y_LP_music + 10*y_BP_music + y_HP_music;
y_HP_gain_music = y_LP_music + y_BP_music + 10*y_HP_music;

%create time domain and frequency domain plots for each input and output
figure
plot(x_white);
title('Time Domain - White Noise Input Signal');
xlabel('Number of Samples');
ylabel('Time (s)');

figure
pwelch(x_white, 512, [], [], Fs);
title('Frequency Domain - White Noise Input Signal');

figure
plot(x_music);
title('Time Domain - Music Input Signal');
xlabel('Number of Samples');
ylabel('Time (s)');

figure
pwelch(x_music, 512, [], [], Fs);
title('Frequency Domain - Music Input Signal');

figure
plot(y_LP_gain_white);
title('Time Domain - White Noise Bass Gain');
xlabel('Number of Samples');
ylabel('Time (s)');

figure
pwelch(y_LP_gain_white, 512, [], [], Fs);
title('Frequency Domain - White Noise Bass Gain');

figure
plot(y_BP_gain_white);
title('Time Domain - White Noise Midrange Gain');
xlabel('Number of Samples');
ylabel('Time (s)');

figure
pwelch(y_BP_gain_white, 512, [], [], Fs);
title('Frequency Domain - White Noise Midrange Gain');

figure
plot(y_HP_gain_white);
title('Time Domain - White Noise Treble Gain');
xlabel('Number of Samples');
ylabel('Time (s)');

figure
pwelch(y_HP_gain_white, 512, [], [], Fs);
title('Frequency Domain - White Noise Treble Gain');

figure
plot(y_LP_gain_music);
title('Time Domain - Music Bass Gain');
xlabel('Number of Samples');
ylabel('Time (s)');

figure
pwelch(y_LP_gain_music, 512, [], [], Fs);
title('Frequency Domain - Music Bass Gain');

figure
plot(y_BP_gain_music);
title('Time Domain - Music Midrange Gain');
xlabel('Number of Samples');
ylabel('Time (s)');

figure
pwelch(y_BP_gain_music, 512, [], [], Fs);
title('Frequency Domain - Music Midrange Gain');

figure
plot(y_HP_gain_music);
title('Time Domain - Music Treble Gain');
xlabel('Number of Samples');
ylabel('Time (s)');

figure
pwelch(y_HP_gain_music, 512, [], [], Fs);
title('Frequency Domain - Music Treble Gain');

%generate wav files for each output
audiowrite('BassWN_Razouki.wav', y_LP_gain_white/max(abs(y_LP_gain_white)), Fs, 'BitsPerSample', 16);
audiowrite('MidWN_Razouki.wav', y_BP_gain_white/max(abs(y_BP_gain_white)), Fs, 'BitsPerSample', 16);
audiowrite('TrebleWN_Razouki.wav', y_HP_gain_white/max(abs(y_HP_gain_white)), Fs, 'BitsPerSample', 16);
audiowrite('BassMusic_Razouki.wav', y_LP_gain_music/max(abs(y_LP_gain_music)), Fs, 'BitsPerSample', 16);
audiowrite('MidMusic_Razouki.wav', y_BP_gain_music/max(abs(y_BP_gain_music)), Fs, 'BitsPerSample', 16);
audiowrite('TrebleMusic_Razouki.wav', y_HP_gain_music/max(abs(y_HP_gain_music)), Fs, 'BitsPerSample', 16);