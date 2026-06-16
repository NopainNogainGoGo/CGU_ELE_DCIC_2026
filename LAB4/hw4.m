clear; clc;

a_bin = [0,1,0,1, 0,0,0,0, 1,0,1,0, 0,1,0,1, 0,0,0,1, 1,0,1,0, ...
         0,1,0,1, 0,0,1,0, 1,0,1,0, 0,1,0,1, 0,0,1,1, 1,0,1,0];
N = length(a_bin);

reg_s = [1, 1, 1, 1, 1]; 
reg_d = [0, 0, 1, 0, 0]; 

s_data = zeros(N, 8); 
d_data = zeros(N, 7); 

for n = 1:N
    % --- Scrambler ---
    bn = xor(a_bin(n), xor(reg_s(3), reg_s(5)));
    s_data(n, :) = [n, a_bin(n), reg_s, bn]; % 填入 8 個數值
    reg_s = [bn, reg_s(1:4)]; 

    bn_hat = bn;
 
    % --- Descrambler ---
    an_hat = xor(bn, xor(reg_d(3), reg_d(5)));  
    d_data(n, :) = [n, reg_d, an_hat]; 
    reg_d = [bn_hat, reg_d(1:4)]; 
end

fid1 = fopen('Scrambler.txt', 'w');
fprintf(fid1, '%% Scrambler (f(x) = x^5 + x^3 + 1)\n');
fprintf(fid1, ' n | an | (1) (2) (3) (4) (5) | bn\n');
fprintf(fid1, '---|----|---------------------|----\n');
for n = 1:N
    fprintf(fid1, '%2d |  %d |  %d   %d   %d   %d   %d  |  %d\n', s_data(n, :));
end
fclose(fid1);

fid2 = fopen('Descrambler.txt', 'w');
fprintf(fid2, '%% Descrambler Process (Initial: 00100)\n');
fprintf(fid2, ' n | (1) (2) (3) (4) (5) | an_hat\n');
fprintf(fid2, '---|---------------------|--------\n');
for n = 1:N
    fprintf(fid2, '%2d |  %d   %d   %d   %d   %d  |   %d\n', d_data(n, :));
end
fclose(fid2);

fprintf('look Scrambler.txt and Descrambler.txt\n');

bin2hex_str = @(b) sprintf('%X', bin2dec(reshape(char(b + '0'), 4, []).'));
fprintf('原始輸入 : %s\n', bin2hex_str(a_bin));
fprintf('擾碼輸出 : %s\n', bin2hex_str(s_data(:, 8)')); 
fprintf('解擾輸出 : %s\n', bin2hex_str(d_data(:, 7)')); 