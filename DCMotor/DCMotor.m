%% initialize
dcMoterLabel = 'DCM1';
mmc.loadDevice(dcMoterLabel, 'SerialManager', 'COM19');
mmc.setProperty(dcMoterLabel, 'Handshaking', 'Software');
mmc.setProperty(dcMoterLabel, 'StopBits', '1');
mmc.setProperty(dcMoterLabel, 'BaudRate', '921600');
mmc.setProperty(dcMoterLabel, 'Parity', 'None');
%mmc.setProperty(dcMoterLabel, 'answerTimeout', '10');
%answerTimeout
mmc.initializeDevice(dcMoterLabel);
ShowAllProperties( mmc, dcMoterLabel);
% values = mmc.getAllowedPropertyValues(dcMoterLabel, 'Parity');
% for ii=0:(values.size()-1)
%     val = values.get(ii)
% end

%%
mmc.setSerialPortCommand(dcMoterLabel, '1AC?','\r\n');
val = mmc.getSerialPortAnswer(dcMoterLabel, '\r');

%%
mmc.unloadDevice(dcMoterLabel);
