% Base folder and save path configuration
baseFolder = 'D:\Miro Hernandez\Documents\DSIGPRO\microsoft AEC-Challenge main datasets-synthetic'; 
saveBasePath = 'D:\Miro Hernandez\Documents\DSIGPRO\near_end_signals_proj';  
metaFilePath = 'D:\Miro Hernandez\Documents\DSIGPRO\microsoft AEC-Challenge main datasets-synthetic/meta.csv';
visFlag = true;  % Set visFlag to true

% Specify the file number to process (e.g., process file number 1898)
fileNum = 0;  % Replace with the desired file number

% Generate the filename based on the file number
saveName = sprintf('nearend_mic_fileid_%d', fileNum);

% Generate the full save path
savePath = fullfile(saveBasePath, saveName);

% Open the log file for writing skipped files (if needed)
logFile = fopen('skipped_files_log.txt', 'a');

try
    % Call the create_synthetic_db function with fileNum and savePath
    create_synthetic_db(metaFilePath, baseFolder, fileNum, visFlag, saveBasePath, saveName);
    
    % Log progress
    fprintf('Processed fileNum %d: Saved to %s\n', fileNum, saveName);
catch ME
    % If error occurs, log the skipped file
    fprintf(logFile, 'Skipped fileNum %d: %s\n', fileNum, ME.message);
    fprintf('Skipped fileNum %d: %s\n', fileNum, ME.message);
end

% Close the log file
fclose(logFile);
