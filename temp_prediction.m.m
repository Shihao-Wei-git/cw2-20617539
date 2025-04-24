% Task 3: Temperature Prediction Algorithm
% This task predicts temperature trends and rates of change.

a = arduino("COM3", "Uno"); % Establish communication with Arduino
duration = 600; % Duration of data collection (600 seconds = 10 minutes)

% Initialize arrays to store the data
AV = zeros(1, duration); % Store voltage readings
Time = zeros(1, duration); % Store time for each reading

% Collect voltage data from the sensor over the specified duration
for x = 1:duration
    AV(x) = readVoltage(a, 'A0'); % Read voltage from temperature sensor
    Time(x) = x; % Time increments for each reading
    pause(1); % Pause for 1 second to match the sampling interval
end


[Temperature, RoC, Prediction] = temp_prediction(AV, duration, Time); % call the temperature prediction function

% Display the results in a readable format
for i = 1:duration
    % Display the current time, temperature, rate of change, and predicted temperature in 5 minutes
    fprintf('Time: %.2fs\nCurrent Temperature: %.2f°C\nRate of Change: %.2f°C/s\nPredicted Temp in 5 min: %.2f°C\n\n', ...
            Time(i), Temperature(i), RoC(i), Prediction(i));
end

clear a; % Clean up the Arduino object

