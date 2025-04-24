% Task 2: LED Temperature Monitoring Device
% This task controls LEDs based on temperature readings.

% Pin assignments for the LEDs
y = 'D4'; % Yellow LED on pin D4
g = 'D11'; % Green LED on pin D11
r = 'D13'; % Red LED on pin D13

% Initialize Arduino connection
a = arduino("COM3", "Uno");

% Duration for temperature recording (600 seconds = 10 minutes)
duration = 600; 
time = zeros(1, duration);  % Initialize time array
temp = zeros(1, duration);  % Initialize temperature array

% Set up live temperature monitoring plot
figure;
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
