% 10-Band Equalizer

% Frequency Bands
freq = [0, 44, 88, 177, 355, 710, 1420, 2840, 5680, 11360, 22000];

% Freq Bands for the "ideal filter"
freqIdeal = [0, 44, 45, 88, 89, 177, 178, 355, 356, 710, 711, 1420, 1421, 2840, 2841, 5680, 5681, 11360, 11361, 22000];

% array for dB levels of each band
% v = [9 9 9 9 9 0 0 0 -9 -9 -9];     % Setting 1
% v = [-9 -9 -9 -9 -9 0 0 0 9 9 9];    % Setting 2
% v = [-6 -6 -3 0 3 6 6 3 0 -3 -6];    % Setting 3
% v = [9 9 6 0 -3 -6 -6 -3 0 6 9];    % Setting 4

% Uncomment the lines below to get Decibel Level of each band from the user
v(1)=(input('Gain for band 1 in dB = '));
v(2)=(input('Gain for band 2 in dB = '));
v(3)=(input('Gain for band 3 in dB = '));
v(4)=(input('Gain for band 4 in dB = '));
v(5)=(input('Gain for band 5 in dB = '));
v(6)=(input('Gain for band 6 in dB = '));
v(7)=(input('Gain for band 7 in dB = '));
v(8)=(input('Gain for band 8 in dB = '));
v(9)=(input('Gain for band 9 in dB = '));
v(10)=(input('Gain for band 10 in dB = '));

% Get dB values for the "ideal" filter frequency response computation 
counter = 1;
for c = 2:11
    vIdeal(counter) = v(c);
    vIdeal(counter+1) = v(c);
    counter = counter + 2;
end

% Get the audio file input
[y, Fs] = audioread('loveStory.wav');

% Play the audio input
% sound(y, Fs);

% Get Audio Input Time Domain graph
t = linspace(0,length(y)/Fs, length(y));
figure;
plot(t,y);
title('Audio Input Time Domain Graph');
xlabel('Time');
ylabel('Amplitude');
pause;

% Get Audio Input Frequency Domain Graph
nfft = 32768;
f = linspace(0, Fs, nfft);
Y = abs(fft(y));
figure;
plot(f(1:nfft/2), Y(1:nfft/2));
title('Audio Input Frequency Domain Graph');
xlabel('Frequency');
ylabel('Amplitude');
pause;

% Filter order (512-tap)
n = 512;

% Using fir2 filter
h = fir2(512, freq * 2/(freq(11)*2), 10.^(v/20));


hIdeal = fir2(512, freqIdeal * 2/(freqIdeal(20) * 2), 10.^(vIdeal/20));

% Apply filter to the signal
y = filter(h, 1, y);

% Get Audio Output Frequency Domain Graph
Y = abs(fft(y));
figure;
plot(f(1:nfft/2), Y(1:nfft/2));
title('Audio Output Frequency Domain Graph');
xlabel('Frequency');
ylabel('Amplitude');
pause;

% Normalize the filtered signal
Y = Y*2/Fs;

% Get Audio Output Time Domain graph
t = linspace(0,length(y)/Fs, length(y));
figure;
plot(t,y);
title('Audio Output Time Domain Graph');
xlabel('Time');
ylabel('Amplitude');
pause;


% Plot filter impulse response
figure;
impz(h,1);
pause;

% Plot filter frequency response
w = 0:pi/255:pi;
figure;
freqz(h,1,w);
pause; 

% Plot "ideal" vs "actual" filter frequency response
figure;
h = freqz(h,1,w);
hIdeal = freqz(hIdeal, 1 ,w);
g = 20*log10(abs(h));
gIdeal = 20*log10(abs(hIdeal));

plot(w/pi, g);
hold on
plot(w/pi, gIdeal);
hold off
title('Gain Response');
xlabel('\omega / \pi');
ylabel('Gain (dB)');
pause;

% Play the audio output
% sound(y, Fs);

