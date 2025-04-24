% Name: Shihao Wei
% Email: ssysw17@nottingham.edu.cn
% Student ID: 20617539

%% Preliminary Task: Arduino and Git Setup
% This script collects temperature data, logs it, and generates a plot of the cabin temperature over time.

clear; clc; % Clear variables and the command window

% Initialize the connection to Arduino
a = arduino();

duration = 600; % Data collection duration: 600 seconds (10 minutes)

% Initialize arrays to store temperature and time data
temperature_data = zeros(1, duration); % Array to store temperature data
time_data = 1:duration; % Array to store time data (from 1 to 600 seconds)

% Temperature sensor's calibration constants
TC = 0.01; % Temperature coefficient in V/°C
V0 = 0.5;  % Zero-degree voltage in V

% Create a figure to display the temperature plot
figure;
hold on;
xlabel('Time (s)');  % X-axis: Time (seconds)
ylabel('Temperature (°C)');  % Y-axis: Temperature (Celsius)
title('Cabin Temperature Over Time');  % Title: Temperature over time in the cabin

% Initialize a tick variable for printing every minute's temperature data
tick = 59;

% Start the data collection loop
for t = 1:duration
    tick = tick + 1; % Increment tick value
    voltage = readVoltage(a, 'A0'); % Read voltage from the temperature sensor (connected to pin A0)
    temperature = (voltage - V0) / TC; % Convert the voltage to temperature

    % Store the temperature data
    temperature_data(t) = temperature;

    if tick == 60
        fprintf('Minute %d\nTemperature: %.2f°C\n\n', t, temperature);  % Print the temperature for the current minute
        tick = 0;  % Reset tick
    end

    plot(time_data(1:t), temperature_data(1:t), '-o', 'LineWidth', 1.5);  % Plot temperature vs. time
    drawnow;  % Update the plot
    pause(1);  % Wait for 1 second before the next reading
end

% Write the recorded temperature data to a log file
fileID = fopen('cabin_temperature.txt', 'w');  % Open a file for writing
fprintf(fileID, 'Data logging initiated - %s\n', datetime('now'));  % Log the start time of data collection
fprintf(fileID, 'Location - Nottingham\n');  % Log the location of data collection
for t = 1:duration
    fprintf(fileID, 'Minute %d\nTemperature: %.2f°C\n\n', t, temperature_data(t));  % Write each minute's data to the file
end
fprintf(fileID, 'Max temp: %.2f°C\n', max(temperature_data));  % Log the maximum temperature recorded
fprintf(fileID, 'Min temp: %.2f°C\n', min(temperature_data));  % Log the minimum temperature recorded
fprintf(fileID, 'Average temp: %.2f°C\n', mean(temperature_data));  % Log the average temperature
fprintf(fileID, 'Data logging terminated\n');  % Log the end of data collection
fclose(fileID);  % Close the log file

%% Task 1: Read Temperature Data, Plot, and Write to Log File
% This task collects temperature data, calculates statistical values, and logs them.

clear a;
a = arduino("COM3", "Uno"); % Connect to Arduino
duration = 600; % 10 minutes in seconds
timeInterval = 1; % Data acquisition every 1 second

% Create arrays to store time and temperature data
time = (0:timeInterval:duration);
voltageValues = zeros(size(time));
temperatureValues = zeros(size(time));

% Collect temperature data every second
for i = 1:length(time)
    voltage = readVoltage(a, 'A0'); % Read voltage from temperature sensor
    V_0 = 0.5; % Zero-degree voltage
    TC = 0.01; % Temperature coefficient
    
    % Convert voltage to temperature
    temperature = (voltage - V_0) / TC; 
    
    voltageValues(i) = voltage; % Store voltage
    temperatureValues(i) = temperature; % Store temperature data
    
    pause(timeInterval); % Pause for 1 second
end

% Calculate and display statistical values
minTemperature = min(temperatureValues);
maxTemperature = max(temperatureValues);
avgTemperature = mean(temperatureValues);

% Create a plot of temperature vs. time
figure;
plot(time, temperatureValues);
xlabel('Time (seconds)');
ylabel('Temperature (°C)');
title('Temperature vs Time');

% Display the recorded data
fprintf('Recorded Cabin Data:\n');
fprintf('---------------------\n');
fprintf('Date: %s\n', datetime('today', 'Format', 'dd-MM-yyyy HH:mm:ss'));
fprintf('Location: Cabin\n');
fprintf('---------------------\n');
for i = 1:length(time)
    fprintf('Minute %d:\tTemperature: %.2f°C\n', floor(i/60), temperatureValues(i));
end

% Write data to a text file
fileID = fopen('cabin_temperature.txt', 'w');
fprintf(fileID, 'Recorded Cabin Data:\n');
fprintf(fileID, '---------------------\n'); % a line for separation
fprintf(fileID, 'Date: %s\n', datetime('today', 'Format', 'dd-MM-yyyy HH:mm:ss'));
fprintf(fileID, 'Location: Cabin\n');
fprintf(fileID, '---------------------\n');
for i = 1:length(time)
    fprintf(fileID, 'Minute %d:\tTemperature: %.2f°C\n', floor(i/60), temperatureValues(i));
end
fclose(fileID); % Close the log file

clear a;

%% Task 2: LED Temperature Monitoring Device
% This task controls LEDs based on temperature readings.

y = 'D4'; % Yellow LED on pin D4
g = 'D11'; % Green LED on pin D11
r = 'D13'; % Red LED on pin D13

a = arduino("COM3", "Uno");
duration = 600; % Duration of temperature recording in seconds
time = zeros(1, duration);
temp = zeros(1, duration);

figure; % Live graph for temperature monitoring
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Live Temperature Monitoring');
grid on;

tic; % Start the timer for live graph
for i = 1:duration
    volt = readVoltage(a, 'A0'); % Read voltage from sensor
    temp(i) = (volt - 0.5) / 0.01; % Convert voltage to temperature
    time(i) = toc; % Record time

    % Live plotting of temperature
    plot(time(1:i), temp(1:i), 'b');
    xlim([0, time(i)]);
    ylim([0, max(temp)]);
    drawnow; % Update graph
    
    % LED control based on temperature
    if temp(i) >= 18 && temp(i) <= 24 % Green LED for comfortable temperature
        writeDigitalPin(a, g, 1);
        writeDigitalPin(a, y, 0);
        writeDigitalPin(a, r, 0);
    elseif temp(i) < 18 % Yellow LED for low temperature
        writeDigitalPin(a, g, 0);
        writeDigitalPin(a, r, 0);
        blink(a, y, 0.5); % Blink yellow LED
    else % Red LED for high temperature
        writeDigitalPin(a, g, 0);
        writeDigitalPin(a, y, 0);
        blink(a, r, 0.25); % Blink red LED
    end
end

% Turn off all LEDs after completion
writeDigitalPin(a, g, 0);
writeDigitalPin(a, y, 0);
writeDigitalPin(a, r, 0);

clear a;

%% Task 3: Temperature Prediction Algorithm
% This task predicts temperature trends and rates of change.

a = arduino("COM3", "Uno");
duration = 11; % Short duration for testing
AV = zeros(1, duration);
Time = zeros(1, duration);

% Collect voltage values and store them with time stamps
for x = 1:duration
    AV(x) = readVoltage(a, 'A0');
    Time(x) = x;
    pause(0.5);
end

% Call the prediction function to estimate temperature and rate of change
[Temperature, RoC, Prediction] = temp_prediction(AV, duration, Time);

% Display the results
for i = 1:duration
    fprintf('Time: %.2fs\nCurrent Temperature: %.2f°C\nPredicted Temperature in 5 minutes: %.2f°C\n', Time(i), Temperature(i), Prediction(i));
end

clear a;

%% Task 4: Reflective Statement
% Insert your reflective statement about the challenges, strengths, and improvements in the project.

% Example: 
% "This project was an excellent opportunity to apply theoretical knowledge in a practical setting. 
% The most challenging part was calibrating the sensor and ensuring accurate temperature readings. 
% The strengths of the project include the real-time monitoring and LED control system, 
% which demonstrated the ability to monitor cabin comfort effectively. In the future, I would suggest 
% adding more sensors and improving the prediction accuracy using more advanced algorithms."

