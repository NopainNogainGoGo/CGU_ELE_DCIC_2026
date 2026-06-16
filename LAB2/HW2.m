clear; clc; close all;

% 0 for PAM-2, 1 for 16-QAM
MTyp = 0;
numBits = 1e6;
b = randi([0 1], 1, numBits);

if MTyp == 0
    SNR_dB_range = 0:14;
    g = 1;
    disp('Running PAM-2');
else
    SNR_dB_range = 0:24;
    g = 1/sqrt(10); 
    disp('Running 16-QAM');
end

ber_results = zeros(size(SNR_dB_range));

for k = 1:length(SNR_dB_range)
    SNR_dB = SNR_dB_range(k);
    sigma_v = sqrt(10^(-SNR_dB/10));

    %% MAPPER
    if MTyp == 0 % PAM-2
        xn = 2*b - 1;
    else % 16-QAM
        bits_reshaped = reshape(b, 4, [])';
        N_symb = size(bits_reshaped, 1);
        xn = zeros(1, N_symb) / sqrt(10);

        for n = 1:N_symb
            b0b1 = bits_reshaped(n, 1:2);
            b2b3 = bits_reshaped(n, 3:4);

            % Map Real Part (b0, b1)
            if     isequal(b0b1, [0 0]), real_part = -3;
            elseif isequal(b0b1, [0 1]), real_part = -1;
            elseif isequal(b0b1, [1 1]), real_part =  1;
            elseif isequal(b0b1, [1 0]), real_part =  3;
            end

            % Map Imaginary Part (b2, b3)
            if     isequal(b2b3, [0 0]), imag_part = -3;
            elseif isequal(b2b3, [0 1]), imag_part = -1;
            elseif isequal(b2b3, [1 1]), imag_part =  1;
            elseif isequal(b2b3, [1 0]), imag_part =  3;
            end

            xn(n) = real_part + 1i * imag_part;
        end
    end

    %% AWGN 
    if MTyp == 0
        yn = g * xn + sigma_v * randn(size(xn));
    else
        yn = g * xn + sigma_v * (randn(size(xn)) + 1i*randn(size(xn))) / sqrt(2);
    end

    dn = yn / g; 

    %% SLICER
    if MTyp == 0
        x_hat = ones(size(dn));
        x_hat(dn < 0) = -1;
    else
        f_slice = @(v) (3*(v >= 2) + 1*(v >= 0 & v < 2) + ...
                       -1*(v >= -2 & v < 0) + -3*(v < -2));
        x_hat = f_slice(real(dn)) + 1i*f_slice(imag(dn));
    end


    %% DEMAPPER
    if MTyp == 0 % PAM-2      
         b_hat = (x_hat + 1) / 2;
    else % 16-QAM
        N_symb = length(x_hat);
        bits_out = zeros(N_symb, 4);
        
        re = real(x_hat);
        im = imag(x_hat);
        
        % Real part mapping
        bits_out(re == -3, 1:2) = repmat([0 0], sum(re == -3), 1);
        bits_out(re == -1, 1:2) = repmat([0 1], sum(re == -1), 1);
        bits_out(re ==  1, 1:2) = repmat([1 1], sum(re ==  1), 1);
        bits_out(re ==  3, 1:2) = repmat([1 0], sum(re ==  3), 1);
        
        % Imaginary part mapping
        bits_out(im == -3, 3:4) = repmat([0 0], sum(im == -3), 1);
        bits_out(im == -1, 3:4) = repmat([0 1], sum(im == -1), 1);
        bits_out(im ==  1, 3:4) = repmat([1 1], sum(im ==  1), 1);
        bits_out(im ==  3, 3:4) = repmat([1 0], sum(im ==  3), 1);
        
        b_hat = reshape(bits_out', 1, []);
    end

    % BER
    ber_results(k) = sum(b ~= b_hat) / numBits;

end  


semilogy(SNR_dB_range, ber_results, 'b-o', 'LineWidth', 1.5);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');

if MTyp == 0
    title(sprintf('PAM-2 : BER vs SNR'));
else
    title(sprintf('16-QAM : BER vs SNR'));
end