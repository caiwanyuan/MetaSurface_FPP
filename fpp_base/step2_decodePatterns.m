% 功能：解码相移条纹
close all;
clc; clear;
tic;

%% 01 参数设置
N = 12;
B_min = 10;
T1 = 28;
T2 = 26;
T3 = 24;

folder_ideal = "data/理想相位";
folder_actual = "data/实际相位";

%% 02 解相位
[pha123_actual, pha123_ideal, T123] = m_calc_phase_shift_patterns(folder_actual, folder_ideal, N, T1, T2, T3, B_min);

%% 03 查看相位
figure(); mesh(pha123_actual); colorbar(); title("实际相位图");
figure(); mesh(pha123_ideal); colorbar(); title("理想相位图");
%plot(pha123_ideal(1, 1440: 1480));
toc;