[sObis640nm] = InitObis640nm('COM15');
powerInMW = 10;
ChangePowerObis640nm(sObis640nm, powerInMW);
[outPutPowerInMW] = CheckPowerObis640nm(sObis640nm)
SwitchOnOffObis640nm(sObis640nm, 1);
[outPutPowerInMW] = CheckPowerObis640nm(sObis640nm)
SwitchOnOffObis640nm(sObis640nm, 0);
[outPutPowerInMW] = CheckPowerObis640nm(sObis640nm)
DisconectObis640nm(sObis640nm);