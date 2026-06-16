clear; clc; close all;

numSymbols = 1000;        
N = 16;             
g = 1/sqrt(10);            
h_n = 0.5;              
SNR_dB = -25;          
mu = 0.05;                

V_ref = (4*sqrt(2) + 8*sqrt(10) + 4*sqrt(18))/16 * g; 

bits = randi([0 1], 1, numSymbols * 4);
bits_reshaped = reshape(bits, 4, [])';
xn = zeros(1, numSymbols);

for n = 1:numSymbols
    b_real = bits_reshaped(n, 1:2);
    b_imag = bits_reshaped(n, 3:4);
    
    % Real part 
    if     isequal(b_real, [0 0]), re = -3;
    elseif isequal(b_real, [0 1]), re = -1;
    elseif isequal(b_real, [1 1]), re =  1;
    else,                          re =  3; end
    
    % Imaginary part 
    if     isequal(b_imag, [0 0]), im = -3;
    elseif isequal(b_imag, [0 1]), im = -1;
    elseif isequal(b_imag, [1 1]), im =  1;
    else,                          im =  3; end
    
    xn(n) = (re + 1i*im); 
end
xn_scaled = xn * g; 

% Channel & Noise 
sigma_v = sqrt(10^(SNR_dB/10));
noise = sigma_v * (randn(1, numSymbols) + 1i*randn(1, numSymbols)) / sqrt(2);

rn = xn_scaled * h_n + noise; 

% AGC 
yn = zeros(1, numSymbols);
a = zeros(1, numSymbols);
a(1) = 1;

for n = 1:numSymbols-1
    yn(n) = a(n) * rn(n);
    
    % Moving Sum / N
    if n >= N
        curr_avg_amp = mean(abs(yn(n-N+1:n)));
    else
        curr_avg_amp = mean(abs(yn(1:n)));
    end
    
    a(n+1) = a(n) + mu * (V_ref - curr_avg_amp);
end
yn(numSymbols) = a(numSymbols) * rn(numSymbols); 

dn = yn / g; 

f_slice = @(v) (3*(v >= 2) + 1*(v >= 0 & v < 2) + ...
               -1*(v >= -2 & v < 0) + -3*(v < -2));
x_hat = f_slice(real(dn)) + 1i*f_slice(imag(dn));


figure;
plot(a, 'LineWidth', 1.5);
title('AGC 增益 (a) 收斂曲線 mu = 0.05');
xlabel('Symbol Index'); ylabel('Gain a');
grid on;


figure;
plot(real(dn(1:100)), imag(dn(1:100)), 'r.');
hold on;
plot([-3 -1 1 3], [1 1 1 1], 'k+', 'MarkerSize', 10);
plot([-3 -1 1 3], [3 3 3 3], 'k+', 'MarkerSize', 10);
plot([-3 -1 1 3], [-1 -1 -1 -1], 'k+', 'MarkerSize', 10);
plot([-3 -1 1 3], [-3 -3 -3 -3], 'k+', 'MarkerSize', 10);
title('收斂前星座圖 (前面 100 點)');
xlabel('In-phase'); ylabel('Quadrature');
axis([-5 5 -5 5]); grid on;


figure;
plot(real(dn(end-100:end)), imag(dn(end-100:end)), 'r.');
hold on;
plot([-3 -1 1 3], [1 1 1 1], 'k+', 'MarkerSize', 10);
plot([-3 -1 1 3], [3 3 3 3], 'k+', 'MarkerSize', 10);
plot([-3 -1 1 3], [-1 -1 -1 -1], 'k+', 'MarkerSize', 10);
plot([-3 -1 1 3], [-3 -3 -3 -3], 'k+', 'MarkerSize', 10);
title('收斂後星座圖 (最後 100 點)');
xlabel('In-phase'); ylabel('Quadrature');
axis([-5 5 -5 5]); grid on;