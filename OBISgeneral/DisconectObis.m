function DisconectObis(serialHandle)

    fprintf(serialHandle,'SOUR:POW:LEV:IMM:AMPL 0.01');
    fprintf(serialHandle,'SOUR:AM:STAT OFF');

    fclose(serialHandle);
    clear serialHandle

end
