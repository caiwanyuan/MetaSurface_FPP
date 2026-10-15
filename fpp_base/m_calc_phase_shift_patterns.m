%% 计算绝对相位
function [pha123_actual, pha123_ideal, T123] = m_calc_phase_shift_patterns(folder_actual, folder_ideal, N, T1, T2, T3, B_min)
num = N * 3;
files_actual = m_glob(folder_actual, num); files_ideal = m_glob(folder_ideal, num);
% step1：计算包裹相位

pha1_ideal = m_calc_warppred_phase(files_ideal(1: 1 * N), N, B_min);
pha2_ideal = m_calc_warppred_phase(files_ideal(1 * N + 1: 2 * N), N, B_min);
pha3_ideal = m_calc_warppred_phase(files_ideal(2 * N + 1: 3 * N), N, B_min);

pha1_actual = m_calc_warppred_phase(files_actual(1: 1 * N), N, B_min);
pha2_actual = m_calc_warppred_phase(files_actual(1 * N + 1: 2 * N), N, B_min);
pha3_actual = m_calc_warppred_phase(files_actual(2 * N + 1: 3 * N), N, B_min);


save("outputs/pha1_actual.mat", "pha1_actual");
save("outputs/pha2_actual.mat", "pha2_actual");
save("outputs/pha3_actual.mat", "pha3_actual");
save("outputs/pha1_ideal.mat", "pha1_ideal");
save("outputs/pha2_ideal.mat", "pha2_ideal");
save("outputs/pha3_ideal.mat", "pha3_ideal");

% step2：多频外差计算绝对相位
% 理想相位用于多频外差展开
% 理想相位分辨率（投影仪）：720 x 1280（2184） （H x W）
% 实际相位分辨率（相机）：1024 x 1280 
% 实际合成的时候，我们只需要用到理想相位某一行的相位最大、最小值
[pha12_ideal, ~] = m_calc_multi_frequency_phase(pha1_ideal, pha2_ideal,  T1, T2);
[pha23_ideal, ~] = m_calc_multi_frequency_phase(pha2_ideal, pha3_ideal, T2, T3);

save("outputs/pha12_ideal.mat", "pha12_ideal");
save("outputs/pha23_ideal.mat", "pha23_ideal");


[pha12_actual, T12] = m_calc_multi_frequency_phase(pha1_actual, pha2_actual, T1, T2);
[pha23_actual, T23] = m_calc_multi_frequency_phase(pha2_actual, pha3_actual, T2, T3);
save("outputs/pha12_actual.mat", "pha12_actual");
save("outputs/pha23_actual.mat", "pha23_actual");




% 归一化，以用于再次多频外差合成相位
[pha12_actual, pha12_ideal] = m_to_std_phase(pha12_actual, pha12_ideal);
[pha23_actual, pha23_ideal] = m_to_std_phase(pha23_actual, pha23_ideal);

[pha123_actual, T123] = m_calc_multi_frequency_phase(pha12_actual, pha23_actual, T12, T23);
[pha123_ideal, ~] = m_calc_multi_frequency_phase(pha12_ideal, pha23_ideal, T12, T23);

% 再次归一化，并将相位从小到大排序
[pha123_actual, pha123_ideal] = m_to_std_phase(pha123_actual, pha123_ideal);
% pha123_ideal = 2 * pi - pha123_ideal;
% pha123_actual = 2 * pi - pha123_actual;

% 过滤异常值
right_mask1 = pha123_actual <= 2 * pi;
right_mask2 = pha123_actual >= 0;
pha123_actual = pha123_actual .* right_mask1 .* right_mask2;
end


%% 计算包裹相位
function [pha] = m_calc_warppred_phase(files, N, B_min)
sin_sum = 0;
cos_sum = 0;
for k = 0: N - 1
    Ik = m_imread(files{k + 1}); % 读取图片
    pk = 2 * k * pi / N;
    %Ik = m_filter2d(Ik);
    sin_sum = sin_sum + Ik * sin(pk);
    cos_sum = cos_sum + Ik * cos(pk);
end
% 根据计算相位、调制度
pha = -atan2(sin_sum, cos_sum);
B = sqrt(sin_sum .^ 2 + cos_sum .^ 2) * 2 / N;
% 简单的过滤掉调制度低的区域
% 对于孔洞等边缘的相位，需要根据梯度进行滤波来滤除，较为复杂，这里暂且不处理
B_mask = B > B_min;
pha = pha .* B_mask;
end


%% 读取图片
function [img] = m_imread(file)
img = imread(file);
img = double(((img(:, :, 1)))); % 转换灰度图
end

%% 高斯滤波
function [img] = m_filter2d(img)
w = 3.;
sigma = 1.;
kernel = fspecial("gaussian", [w, w], sigma);
img = imfilter(img, kernel, "replicate");
end

%% 取出所有文件
function [files] = m_glob(folder, num)
files = cell(num, 1);
for i = 1: num
    files{i} = strcat(folder, "/", int2str(i), ".bmp");
end
end

%% 多频外差公式
function [pha12, T12] = m_calc_multi_frequency_phase(pha1, pha2, T1, T2)
T12 = T1 * T2 / (T2 - T1);
mask1 = pha1 > pha2;
mask2 = pha1 <= pha2;
delta1 = mask1 .* (pha1 - pha2);
delta2 = mask2 .* (2 * pi - (pha2 - pha1)) ;
delta = delta1 + delta2;
m = round((delta * T2 / (T2 - T1) - pha1) / (2 * pi));
pha12 = pha1 + m * 2 * pi;
end

function [pha_actual, pha_ideal] = m_to_std_phase(pha_actual, pha_ideal)
% 注：如果不加e的话，由于0除的关系，数值计算不稳定
e = 0.2;
pha_min = min(pha_ideal(1, :)); pha_max = max(pha_ideal(1, :));
pha_actual = (pha_actual - pha_min) / (pha_max - pha_min + e) * 2 * pi;
pha_ideal = (pha_ideal - pha_min) / (pha_max - pha_min + e) * 2 * pi ;
end