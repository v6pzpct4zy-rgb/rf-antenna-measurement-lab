%% PART 3(a) - Automatic S11 & S21 Analysis (Single Script)
clc; clear; close all;

% === DOSYA YOLLARI ===
fileS11 = "File_0112.csv"; % S11
fileS21 = "File_0213.csv"; % S21

% === VERİ OKU ===
[fS11, S11dB] = readN9912A(fileS11);
[fS21, S21dB] = readN9912A(fileS21);

% === FIGURE 1: S11 ===
figure('Color','w','Position',[200 200 900 450])
plot(fS11, S11dB,'LineWidth',2); grid on;
xlabel('Frequency (GHz)')
ylabel('S_{11} (dB)')
title('S_{11} Magnitude vs Frequency')
yline(-10,'--k','-10 dB');

saveas(gcf,'Fig_S11.png')

% === FIGURE 2: S21 ===
figure('Color','w','Position',[200 200 900 450])
plot(fS21, S21dB,'LineWidth',2); grid on; hold on;
xlabel('Frequency (GHz)')
ylabel('S_{21} (dB)')
title('S_{21} Magnitude vs Frequency')
yline(-3,'--k','-3 dB');

saveas(gcf,'Fig_S21.png')

% === KRİTİK FREKANSLAR ===
freqs = [2.3; 2.4; 2.5];

S11_vals = interp1(fS11, S11dB, freqs, 'linear');
S21_vals = interp1(fS21, S21dB, freqs, 'linear');

% === f_-3dB BUL ===
target = -3;
d = S21dB - target;
idx = find(d(1:end-1).*d(2:end) <= 0, 1);

f_3dB = fS21(idx) + (target - S21dB(idx)) * ...
       (fS21(idx+1)-fS21(idx)) / ...
       (S21dB(idx+1)-S21dB(idx));

% === f_-3dB DEĞERLERİ ===
S11_3dB = interp1(fS11, S11dB, f_3dB, 'linear');

% === TABLO ===
Frequency_GHz = [freqs; f_3dB];
S11_dB = [S11_vals; S11_3dB];
S21_dB = [S21_vals; -3];

ResultTable = table(Frequency_GHz, S11_dB, S21_dB);
disp(ResultTable)

writetable(ResultTable,'Part3a_CriticalFrequencies.csv');

fprintf('\nf_-3dB = %.4f GHz\n', f_3dB);

%% ===== YARDIMCI FONKSİYON =====
function [fGHz, y] = readN9912A(filename)
    fid = fopen(filename,'r');
    if fid < 0, error("Dosya açılamadı"); end

    dataStart = false;
    f = []; y = [];

    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if strcmpi(line,"BEGIN")
            dataStart = true;
            continue;
        end
        if dataStart
            if strcmpi(line,"END"), break; end
            vals = split(line,",");
            if numel(vals)>=2
                fv = str2double(vals(1));
                yv = str2double(vals(2));
                if ~isnan(fv) && ~isnan(yv)
                    f(end+1,1) = fv; %#ok<AGROW>
                    y(end+1,1) = yv; %#ok<AGROW>
                end
            end
        end
    end
    fclose(fid);
    fGHz = f/1e9;
end
