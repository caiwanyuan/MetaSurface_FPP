% 函数：生成相移条纹
function [Is, Is_img] = m_make_phase_shift_patterns(A, B, T, N, W, H)
    Is = cell(N, 1);
    Is_img = cell(N, 1);
    xs = 1: W;
    f_2pi = 1. / double(T) * 2. * pi;
    for k = 0: N - 1
        Is{k + 1} = A + B * cos(f_2pi * xs + 2 * k / N * pi);
        Is_img{k + 1} =  repmat(Is{k + 1} / 255., H, 1);
    end
end
