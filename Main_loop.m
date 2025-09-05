% Base folder and save path configuration
baseFolder = 'D:\Miro Hernandez\Documents\DSIGPRO\microsoft AEC-Challenge main datasets-synthetic'; 
saveBasePath = 'D:\Miro Hernandez\Documents\DSIGPRO\near_end_signals_proj';  
metaFilePath = 'D:\Miro Hernandez\Documents\DSIGPRO\microsoft AEC-Challenge main datasets-synthetic/meta.csv';
visFlag = false;

% Get list of all WAV files in the base folder
wavFiles = dir(fullfile(baseFolder, 'nearend_mic_signal', '*.wav'));

% Open the log file for writing skipped files
logFile = fopen('skipped_files_log.txt', 'a');

% Loop through each file and extract the number from its filename
for i = 1:length(wavFiles)
    % Extract file number from the filename (assuming format like 'nearend_mic_fileid_1898.wav')
    [~, fileName, ~] = fileparts(wavFiles(i).name);
    fileNum = sscanf(fileName, 'nearend_mic_fileid_%d');  % Extract the numeric part
    
    % Generate save name dynamically
    saveName = sprintf('nearend_mic_fileid_%d', fileNum);
    
    % Generate the full save path
    savePath = fullfile(saveBasePath, saveName);
    
    try
        % Call the create_synthetic_db function with fileNum and savePath
        create_synthetic_db(metaFilePath, baseFolder, fileNum, visFlag, saveBasePath, saveName);
        
        % Log progress
        fprintf('Processed fileNum %d: Saved to %s\n', fileNum, saveName);
    catch ME
        % If error occurs, log the skipped file and continue to the next
        fprintf(logFile, 'Skipped fileNum %d: %s\n', fileNum, ME.message);
        fprintf('Skipped fileNum %d: %s\n', fileNum, ME.message);
    end
end

% Close the log file
fclose(logFile);
