%% PART 4(a) - All 3-Port S-Parameters (Graphs + Table)
clc; clear; close all;

% Dosyalar
files = {
    "File_8.csv", "S11";
    "File_4.csv", "S21";
    "File_5.csv", "S31";
    "File_7.csv", "S12";
    "File_6.csv", "S32";
};

f_list = [2.3; 2.4; 2.5];   % GHz

Results = table(f_list, ...
    'VariableNames', {'Frequency_GHz'});

for i = 1:size(files,1)
    fname = files{i,1};
    label = files{i,2};

    [f, SdB] = readN9912A_2col(fname);

    % ---- Grafik ----
    figure('Color','w','Position',[200 200 900 450]);
    plot(f, SdB, 'LineWidth', 2); grid on;
    xlabel('Frequency (GHz)');
    ylabel([label ' (dB)']);
    title(['PART 4 - ' label ' vs Frequency']);
    xlim([1 3]);

    saveas(gcf, sprintf('Part4_%s.png', label));


    % Markerlar
    Svals = interp1(f, SdB, f_list, 'linear');
    hold on;
    plot(f_list, Svals, 'ks','MarkerSize',8,'LineWidth',2);
    for k=1:3
        text(f_list(k)+0.02, Svals(k), ...
            sprintf('%.1f GHz: %.2f dB', f_list(k), Svals(k)));
    end

    saveas(gcf, sprintf('Part4_%s.png', label));


    % ---- Tabloya ekle ----
    Results.(label) = Svals;
end

disp(Results);
writetable(Results, "Part4_All_Sparameters_dB.csv");

%% --- Yardımcı Fonksiyon ---
function [fGHz, y] = readN9912A_2col(filename)
    fid = fopen(filename,'r');
    dataStart = false; f=[]; y=[];
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if strcmpi(line,"BEGIN"), dataStart=true; continue; end
        if dataStart
            if strcmpi(line,"END"), break; end
            v = split(line,",");
            if numel(v)>=2
                f(end+1)=str2double(v{1});
                y(end+1)=str2double(v{2});
            end
        end
    end
    fclose(fid);
    fGHz = f'/1e9;
    y = y';
end
