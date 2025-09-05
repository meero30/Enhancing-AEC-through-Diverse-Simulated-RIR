% Script to calculate RT60, room sizes, and positions from the AIR database
clear; clc;

% Path to the AIR database directory
air_dir = 'D:\Miro Hernandez\Documents\DSIGPRO\air_database_release_1_4\AIR_1_4';
files = dir(fullfile(air_dir, '*.mat'));

% Initialize arrays for parameters
rt60_values = [];
room_sizes = [];
source_positions = [];
receiver_positions = [];

% Loop through files in the AIR database
for i = 1:length(files)
    file_path = fullfile(files(i).folder, files(i).name);
    try
        % Load the file
        load(file_path, 'h_air', 'air_info'); % Load impulse response and metadata
        
        % Debugging: Display file being processed
        fprintf('Processing file: %s\n', files(i).name);
        
        % Compute RT60 using Schroeder integration
        if exist('h_air', 'var') && ~isempty(h_air)
            rt60 = compute_rt60(h_air, air_info.fs);
            rt60_values = [rt60_values; rt60];
        else
            fprintf('Impulse response missing in file: %s\n', files(i).name);
        end

        % Extract or infer room dimensions
        if isfield(air_info, 'room')
            room_size = infer_room_dimensions(air_info.room);
            room_sizes = [room_sizes; room_size];
        end

        % Extract source position
        if isfield(air_info, 'erp_dist') && isfield(air_info, 'HHP_xyz')
            source_pos = air_info.HHP_xyz + [air_info.erp_dist, 0, 0];
            source_positions = [source_positions; source_pos];
        end

        % Extract receiver position
        if isfield(air_info, 'HHP_xyz')
            receiver_positions = [receiver_positions; air_info.HHP_xyz];
        end
    catch ME
        fprintf('Error processing file %s: %s\n', files(i).name, ME.message);
    end
end

% Calculate and display ranges
if ~isempty(rt60_values)
    fprintf('RT60 Range:\nMin: %.5f, Max: %.5f\n', min(rt60_values), max(rt60_values));
else
    fprintf('RT60 Range:\nMin: , Max: \n(No valid RT60 values calculated)\n');
end
fprintf('Room Sizes Range:\nMin: %s, Max: %s\n', mat2str(min(room_sizes, [], 1)), mat2str(max(room_sizes, [], 1)));
fprintf('Source Positions Range:\nMin: %s, Max: %s\n', mat2str(min(source_positions, [], 1)), mat2str(max(source_positions, [], 1)));
fprintf('Receiver Positions Range:\nMin: %s, Max: %s\n', mat2str(min(receiver_positions, [], 1)), mat2str(max(receiver_positions, [], 1)));

% Helper function to compute RT60 using Schroeder integration
function rt60 = compute_rt60(h_air, fs)
    h_air = h_air(:); % Ensure it's a column vector
    energy = h_air.^2; % Energy of the impulse response
    cumulative_energy = flipud(cumsum(flipud(energy))); % Schroeder integration
    cumulative_energy_db = 10 * log10(cumulative_energy / max(cumulative_energy));
    
    % Find the -5 dB and -35 dB points for a 30 dB decay window
    t = (0:length(h_air)-1) / fs; % Time vector
    idx_5dB = find(cumulative_energy_db <= -5, 1);
    idx_35dB = find(cumulative_energy_db <= -35, 1);
    
    if ~isempty(idx_5dB) && ~isempty(idx_35dB)
        rt60 = (t(idx_35dB) - t(idx_5dB)) * 2; % Extrapolate to 60 dB decay
    else
        rt60 = NaN; % Unable to calculate RT60
    end
end

% Helper function to infer room dimensions
function dimensions = infer_room_dimensions(room)
    switch room
        case {'booth'}
            dimensions = [2, 2, 2.5];
        case {'office'}
            dimensions = [5, 6, 3];
        case {'lecture'}
            dimensions = [10, 15, 4];
        case {'stairway'}
            dimensions = [2, 2, 6];
        case {'aula_carolina'}
            dimensions = [20, 30, 10];
        otherwise
            dimensions = [10, 10, 3]; % Default size
    end
end
