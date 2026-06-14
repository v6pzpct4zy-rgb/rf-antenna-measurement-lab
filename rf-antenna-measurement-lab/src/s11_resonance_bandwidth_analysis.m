%% PART 2(a) - S11 Magnitude & Phase plots + Critical frequency table
% Keysight N9912A CSV (USB export) uyumlu
clc; clear; close all;

% === 1) Dosya adlarını gir ===

fileA = "File_01.csv";
fileB = "File_011.csv";

% === 2) İki dosyayı oku ve hangisi dB hangisi Degrees otomatik ayır ===
D1 = readN9912A_S11(fileA);
D2 = readN9912A_S11(fileB);

% Hangisi magnitude / hangisi phase?
if strcmpi(D1.unit, "dB") && strcmpi(D2.unit, "Degrees")
    Mag = D1; Ph = D2;
elseif strcmpi(D2.unit, "dB") && strcmpi(D1.unit, "Degrees")
    Mag = D2; Ph = D1;
else
    error("Dosyaların unit bilgisi net değil. Birinde '! DATA UNIT dB', diğerinde '! DATA UNIT Degrees' olmalı.");
end

% Frekansları GHz'e çevir
fMag = Mag.f_Hz/1e9;
S11dB = Mag.S11;
fPh  = Ph.f_Hz/1e9;
phi  = Ph.S11;  % degree

% === 3) FIGURE 1: S11 Magnitude vs Frequency ===
figure('Name','S11 Magnitude');
plot(fMag, S11dB, 'LineWidth', 1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('S_{11} Magnitude (dB)');
title('S_{11} Magnitude vs Frequency');

% -10 dB çizgisi (raporda güzel durur)
yline(-10,'--','-10 dB');

% === 4) Kritik frekanslar: f0 (min S11), f1-f2 (S11=-10 dB) ===
% f0 = minimum S11 (en negatif değer)
[S11min, idxMin] = min(S11dB);
f0 = fMag(idxMin);

% -10 dB kesişimlerini bul (lineer interpolasyon)
target = -10;
crossIdx = find( (S11dB(1:end-1)-target).*(S11dB(2:end)-target) <= 0 );

fCross = [];
for k = 1:numel(crossIdx)
    i = crossIdx(k);
    f1i = fMag(i);  f2i = fMag(i+1);
    y1i = S11dB(i); y2i = S11dB(i+1);
    if y2i == y1i
        fc = f1i;
    else
        fc = f1i + (target - y1i)*(f2i - f1i)/(y2i - y1i);
    end
    fCross(end+1) = fc; %#ok<AGROW>
end

fCross = sort(fCross);
if numel(fCross) < 2
    warning("S11=-10 dB kesişimi 2 tane bulunamadı. Grafiğe zoom yapıp kontrol edebilirsin.");
    f1 = NaN; f2 = NaN;
else
    f1 = fCross(1);
    f2 = fCross(end);
end

% İstersen senin ölçtüklerin sabitse (2.39 ve 2.43), zorla da atayabilirsin:
% f1 = 2.39; f2 = 2.43;

% Bant genişliği
BW10 = f2 - f1;        % GHz
BW10_MHz = BW10*1000;  % MHz

% Figure 1 üzerine işaretleme
hold on;
plot(f0, S11min, 'o', 'LineWidth', 2);
text(f0, S11min, sprintf('  f0=%.3f GHz, S11=%.2f dB', f0, S11min));

if ~isnan(f1) && ~isnan(f2)
    plot([f1 f2], [target target], 'ks', 'LineWidth', 2);
    text(f1, target, sprintf('  f1=%.3f', f1));
    text(f2, target, sprintf('  f2=%.3f', f2));
end

% === 5) FIGURE 2: S11 Phase vs Frequency ===
figure('Name','S11 Phase');
plot(fPh, phi, 'LineWidth', 1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('S_{11} Phase (deg)');
title('S_{11} Phase vs Frequency');

% === 6) Kritik frekanslarda phase değerlerini al (interpolasyon) ===
phi0 = interp1(fPh, phi, f0, 'linear', 'extrap');

if ~isnan(f1) && ~isnan(f2)
    phi1 = interp1(fPh, phi, f1, 'linear', 'extrap');
    phi2 = interp1(fPh, phi, f2, 'linear', 'extrap');
else
    phi1 = NaN; phi2 = NaN;
end

% Kritik frekanslarda S11(dB) değerleri:
% f0 için zaten min var, f1/f2 için -10 hedefi var; istersen gerçek S11'i de interpolasyonla yaz:
S11_f1 = interp1(fMag, S11dB, f1, 'linear', 'extrap');
S11_f2 = interp1(fMag, S11dB, f2, 'linear', 'extrap');

% === 7) Tablo oluştur 
Point = ["f0 (min S11)"; "f1 (S11=-10 dB)"; "f2 (S11=-10 dB)"];
Frequency_GHz = [f0; f1; f2];
S11_dB = [S11min; S11_f1; S11_f2];       % veya istersen tam -10 yaz: [-10;-10]
Phase_deg = [phi0; phi1; phi2];

CritTable = table(Point, Frequency_GHz, S11_dB, Phase_deg);
disp(CritTable);

fprintf("\n-10 dB Bandwidth: BW = %.3f GHz (%.1f MHz)\n", BW10, BW10_MHz);

% === 8) İstersen çıktı dosyası olarak kaydet ===
saveas(findobj('Name','S11 Magnitude'), "Fig_S11_Magnitude.png");
saveas(findobj('Name','S11 Phase'),     "Fig_S11_Phase.png");
writetable(CritTable, "CriticalFrequencies_Table.csv");

%% --------- Yerel Fonksiyon: N9912A CSV okuyucu ---------
function D = readN9912A_S11(filename)
    % N9912A CSV: header '!' satırları + '! DATA Freq,S11' + 'BEGIN' sonrası sayısal data
    fid = fopen(filename,'r');
    if fid<0, error("Dosya açılamadı: %s", filename); end

    unit = "";
    dataStart = false;
    freq = [];
    s11 = [];

    while ~feof(fid)
        line = strtrim(fgetl(fid));

        % unit bilgisini yakala
        if startsWith(line, "! DATA UNIT", 'IgnoreCase', true)
            % Örn: "! DATA UNIT Degrees" veya "! DATA UNIT dB"
            parts = split(line);
            unit = string(parts(end));
        end

        % BEGIN görünce data başlıyor
        if strcmpi(line, "BEGIN")
            dataStart = true;
            continue;
        end

        if dataStart
            % "freq,s11" formatında iki sayı bekliyoruz
            vals = split(line, ",");
            if numel(vals) >= 2
                fval = str2double(vals(1));
                yval = str2double(vals(2));
                if ~isnan(fval) && ~isnan(yval)
                    freq(end+1,1) = fval; %#ok<AGROW>
                    s11(end+1,1)  = yval; %#ok<AGROW>
                end
            end
        end
    end

    fclose(fid);

    if unit == ""
        warning("Unit bilgisi bulunamadı. Dosyanın header kısmını kontrol et: %s", filename);
        unit = "Unknown";
    end

    D.f_Hz = freq;
    D.S11  = s11;
    D.unit = unit;
end
