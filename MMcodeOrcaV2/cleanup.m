fwrite(afg, ':output1 off;'); 
fwrite(afg, ':output2 off;'); 
reset(mmc);
clear mmc;
fclose(sExtLens);
delete(sExtLens);
clear sExtLens;
fclose(sDetLens);
delete(sDetLens);
clear sDetLens;
fclose(afg);
delete(afg);
clear afg;
fclose(sFWDet);
delete(sFWDet);
clear sFWDet;
release(s);
clear s;
clear sFWExt;
if (avilableLasers(1))
    DisconectObis(s488nm); 
    clear s488nm;    
end
if (avilableLasers(2))
    DisconectObis(s561nm); 
    clear s589nm;    
end
if (avilableLasers(3))
    DisconectObis(s640nm); 
    clear s640nm;
end
controlParameters.MMC.setCircularBufferMemoryFootprint(1024*.01);