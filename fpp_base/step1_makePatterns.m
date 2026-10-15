% 功能：生成相移条纹
close all;
clc; clear;
tic;

%% 01 配置参数
W = 1920; % T1, T2, T3
H = 1080;
N = 12;
A = 130;
B = 90;

T1 = 28;
T2 = 26;
T3 = 24;

show = true;
save_folder = "data/理想相位"; mkdir(save_folder);

%% 02 生成条纹
[Is_T1, Is_T1_img] = m_make_phase_shift_patterns(A, B, T1, N, W, H);
[Is_T2, Is_T2_img] = m_make_phase_shift_patterns(A, B, T2, N, W, H);
[Is_T3, Is_T3_img] = m_make_phase_shift_patterns(A, B, T3, N, W, H);


%% 03 保存、查看条纹
idx = 0;
for imgs = {Is_T1_img, Is_T2_img, Is_T3_img}
    imgs_t = imgs{1, 1};
    for i = 1: N
        idx = idx + 1;
        I_img = imgs_t{i, 1};
        save_file = strcat(save_folder, "/", int2str(idx), ".bmp");
        imwrite(I_img, save_file);
        if show
            imshow(I_img);
        end
    end
end
toc;