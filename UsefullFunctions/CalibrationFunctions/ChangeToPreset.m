function ChangeToPreset(controlParameters, autoParameters)

    %Find the position of the excitation stage
    [posExtLens] = GetPos(controlParameters.sExtLens);

    %Find the position of the detection stage
    [posDetLens] = GetPos(controlParameters.sDetLens);

    %Excitation lens
    deltaForExt = autoParameters.posExtLens - str2num(posExtLens);
    %Move excitation lens
    if (abs(deltaForExt) < 2)
        fprintf(controlParameters.sExtLens,['1PR',num2str(deltaForExt)]);
    end

    %Detection lens
    deltaForDet = autoParameters.posDetLens - str2num(posDetLens);
    %Move excitation lens
    if (abs(deltaForDet) < 0.25)
        fprintf(controlParameters.sDetLens,['1PR',num2str(deltaForDet)]);
    end   

end
