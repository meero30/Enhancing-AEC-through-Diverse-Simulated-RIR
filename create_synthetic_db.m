%% Main
function create_synthetic_db(metaFilePath, baseFolder, fileNum, visFlag, savePath, saveName)
% Load metadata

metaTable = readtable(metaFilePath);

% Display metadata
%disp(metaTable);



% Load specific audio files based on fileid
fileid = fileNum; % Change this for other files
farendPath = fullfile(baseFolder, 'farend_speech', sprintf('farend_speech_fileid_%d.wav', fileid));
%echoPath = fullfile(baseFolder, 'echo_signal', sprintf('echo_fileid_%d.wav', fileid));
nearendPath = fullfile(baseFolder, 'nearend_speech', sprintf('nearend_speech_fileid_%d.wav', fileid));
%nearendMicPath = fullfile(baseFolder, 'nearend_mic_signal', sprintf('nearend_mic_fileid_%d.wav', fileid));

% Read audio files
[farendSignal, fs] = audioread(farendPath);
%[echoSignal, ~] = audioread(echoPath);
[nearendSignal, ~] = audioread(nearendPath);
%[nearendMicSignal, ~] = audioread(nearendMicPath);

%{
% Define room parameters
roomSize = [10, 7, 3]; % Example room dimensions in meters
sourcePosition = [2, 3, 1.5]; % Example source position
receiverPosition = [8, 4, 1.5]; % Example receiver position
RT60 = 0.5; % Reverberation time in seconds
fs = 44100;
N = 12;

%}

% Generate RIR
N = 12;
[RT60, roomSize, sourcePosition, receiverPosition] = generateRandomParams();
room_impulse_response = rir(fs, receiverPosition, N,  RT60, roomSize ,sourcePosition);



% Convolve far-end signal with RIR
echoedFarendSignal = conv(farendSignal, room_impulse_response);

% Trim or pad to match the original length
echoedFarendSignal = echoedFarendSignal(1:length(farendSignal));


%sound(farendSignal);


% Load SER from metadata
ser = metaTable.ser(fileid + 1); % Add 1 if fileid starts from 0
nearendScale = metaTable.nearend_scale(fileid + 1);

% Scale signals
scaledNearendSignal = nearendSignal * nearendScale;
scaledEchoedSignal = echoedFarendSignal / (10^(ser / 20)); % Adjust echo level based on SER

% Create microphone signal (nearend speech + echo)
micSignal = scaledNearendSignal + scaledEchoedSignal;

% Add noise if required
if metaTable.is_nearend_noisy(fileid + 1)
    noise = randn(size(micSignal)) * 0.01; % Adjust noise level
    micSignal = micSignal + noise;
end


saveAsWav(micSignal, fs, savePath, saveName);



%% Visualization

% Create the figure
figure;
hold on;
grid on;

% Plot the room size as a cuboid
% Define the corners of the room based on room size
roomCorners = [0 0 0; 
               roomSize(1) 0 0;
               roomSize(1) roomSize(2) 0;
               0 roomSize(2) 0;
               0 0 roomSize(3);
               roomSize(1) 0 roomSize(3);
               roomSize(1) roomSize(2) roomSize(3);
               0 roomSize(2) roomSize(3)];

% Plot the room as lines connecting the corners
for i = 1:4
    plot3([roomCorners(i,1) roomCorners(mod(i,4)+1,1)], ...
          [roomCorners(i,2) roomCorners(mod(i,4)+1,2)], ...
          [roomCorners(i,3) roomCorners(mod(i,4)+1,3)], 'k', 'LineWidth', 1);
    plot3([roomCorners(i+4,1) roomCorners(mod(i+3,4)+1,1)], ...
          [roomCorners(i+4,2) roomCorners(mod(i+3,4)+1,2)], ...
          [roomCorners(i+4,3) roomCorners(mod(i+3,4)+1,3)], 'k', 'LineWidth', 1);
end

% Plot the edges connecting the top and bottom of the room
for i = 1:4
    plot3([roomCorners(i,1) roomCorners(i+4,1)], ...
          [roomCorners(i,2) roomCorners(i+4,2)], ...
          [roomCorners(i,3) roomCorners(i+4,3)], 'k', 'LineWidth', 1);
end

% Plot the source position as a red dot
plot3(sourcePosition(1), sourcePosition(2), sourcePosition(3), 'ro', 'MarkerFaceColor', 'r');

% Plot the receiver position as a blue dot
plot3(receiverPosition(1), receiverPosition(2), receiverPosition(3), 'bo', 'MarkerFaceColor', 'b');

% Add labels for source and receiver
text(sourcePosition(1), sourcePosition(2), sourcePosition(3), ' Source', 'Color', 'r');
text(receiverPosition(1), receiverPosition(2), receiverPosition(3), ' Receiver', 'Color', 'b');

% Add RT60 annotation
text(roomSize(1)*0.5, roomSize(2)*0.5, roomSize(3)*0.95, ...
    sprintf('RT60 = %.2f s', RT60), 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');

% Set axis labels and title
xlabel('X (meters)');
ylabel('Y (meters)');
zlabel('Z (meters)');
title('Room Dimensions, Source, Receiver, and RT60');

% Set axis limits based on room size
axis([0 roomSize(1) 0 roomSize(2) 0 roomSize(3)]);
axis equal;
hold off;

% Visualize RIR
if visFlag
figure;
plot(room_impulse_response);
title('Room Impulse Response');
xlabel('Samples');
ylabel('Amplitude');

% original far end signal
figure;
plot(farendSignal);
title('Original Farend Signal');
xlabel('Samples');
ylabel('Amplitude');


% original near end signal
figure;
plot(nearendSignal);
title('Original Nearend Signal');
xlabel('Samples');
ylabel('Amplitude');


% echoed farend signal
figure;
plot(echoedFarendSignal);
title('Echoed Farend Signal');
xlabel('Samples');
ylabel('Amplitude');

% output signal
figure;
plot(micSignal);
title('Microphone Signal with Echo and Near-End Speech');
xlabel('Samples');
ylabel('Amplitude');

% Plot spectrograms
figure;
subplot(2,1,1);
spectrogram(farendSignal, 256, 128, 256, fs, 'yaxis');
title('Original Far-End Signal');

subplot(2,1,2);
spectrogram(micSignal, 256, 128, 256, fs, 'yaxis');
title('Microphone Signal with Echo and Near-End Speech');
end

%% functions
function [h]=rir(fs, mic, n, r, rm, src) 
%RIR   Room Impulse Response.
%   [h] = RIR(FS, MIC, N, R, RM, SRC) performs a room impulse
%         response calculation by means of the mirror image method.
%
%      FS  = sample rate.
%      MIC = row vector giving the x,y,z coordinates of
%            the microphone.  
%      N   = The program will account for (2*N+1)^3 virtual sources 
%      R   = reflection coefficient for the walls, in general -1<R<1.
%      RM  = row vector giving the dimensions of the room.  
%      SRC = row vector giving the x,y,z coordinates of 
%            the sound source.
%
%   EXAMPLE:
%
%      >>fs=44100;
%      >>mic=[19 18 1.6];
%      >>n=12;
%      >>r=0.3;
%      >>rm=[20 19 21];
%      >>src=[5 2 1];
%      >>h=rir(fs, mic, n, r, rm, src);
%
%   NOTES:
%
%   1) All distances are in meters.
%   2) The output is scaled such that the largest value of the 
%      absolute value of the output vector is equal to one.
%   3) To implement this filter, you will need to do a fast 
%      convolution.  The program FCONV.m will do this. It can be 
%      found on the Mathworks File Exchange at
%      www.mathworks.com/matlabcentral/fileexchange/.  It can also 
%      be found at http://www.sgm-audio.com/research/rir/fconv.m
%   4) A paper has been written on this model.  It is available at:
%      http://www.sgm-audio.com/research/rir/rir.html
%      
%
%Version 3.4.2
%Copyright © 2003 Stephen G. McGovern

%Some of the following comments are references to equations the my paper.

nn=-n:1:n;                            % Index for the sequence
rms=nn+0.5-0.5*(-1).^nn;              % Part of equations 2,3,& 4
srcs=(-1).^(nn);                      % part of equations 2,3,& 4
xi=srcs*src(1)+rms*rm(1)-mic(1);      % Equation 2 
yj=srcs*src(2)+rms*rm(2)-mic(2);      % Equation 3 
zk=srcs*src(3)+rms*rm(3)-mic(3);      % Equation 4 

[i,j,k]=meshgrid(xi,yj,zk);           % convert vectors to 3D matrices
d=sqrt(i.^2+j.^2+k.^2);               % Equation 5
time=round(fs*d/343)+1;               % Similar to Equation 6
              
[e,f,g]=meshgrid(nn, nn, nn);         % convert vectors to 3D matrices
c=r.^(abs(e)+abs(f)+abs(g));          % Equation 9
e=c./d;                               % Equivalent to Equation 10

h=full(sparse(time(:),1,e(:)));       % Equivalent to equation 11
h=h/max(abs(h));                      % Scale output

end


function [RT60, roomSize, sourcePosition, receiverPosition] = generateRandomParams()
    % Define RT60 range
    rt60Min = 0.11421;
    rt60Max = 8.77896;

    % Define room size range
    roomMin = [2, 2, 2.5];
    roomMax = [20, 30, 10];

    % Generate RT60 uniformly within the range
    RT60 = rt60Min + (rt60Max - rt60Min) * rand();

    % Generate room dimensions uniformly within the range
    roomSize = roomMin + (roomMax - roomMin) .* rand(1, 3);

    % Generate source coordinates within room bounds
    sourcePosition = roomSize .* rand(1, 3);

    % Generate receiver coordinates within room bounds
    receiverPosition = roomSize .* rand(1, 3);
end

function saveAsWav(signal, fs, savePath, saveName)
    % Combine path and name to create full file path
    fullPath = fullfile(savePath, [saveName, '.wav']);
    
    % Save the signal as a .wav file
    audiowrite(fullPath, signal, fs);
    
    fprintf('File saved successfully at: %s\n', fullPath);
end

end

 

