clear; clc;

%'b.dat' is in the same directory
b = load('b.dat');
b = b(:)'; 

% 0 for PAM-2, 1 for 16-QAM
MTyp = 1;

if MTyp == 0
    %% PAM-2
    disp('Running PAM-2 Transceiver...');
    
    % --- MAPPER ---
    % Mapping rule: +1 for 1, -1 for 0
    PAM2_Symb = zeros(1, 100);
    for n = 1:100
        if b(n) == 1
            PAM2_Symb(n) = 1;
        else
            PAM2_Symb(n) = -1;
        end
    end
    
    % Ideal channel
    rx_PAM2_Symb = PAM2_Symb;
    
    % --- DE-MAPPER ---
    PAM2_Bit = zeros(1, 100);
    for n = 1:100
        if rx_PAM2_Symb(n) > 0
            PAM2_Bit(n) = 1;
        else
            PAM2_Bit(n) = 0;
        end
    end
    
    errors = sum(b ~= PAM2_Bit);
    fprintf('PAM-2 Bit Errors: %d\n', errors);

elseif MTyp == 1
    %% 16-QAM
    disp('Running 16-QAM Transceiver...');
    
    % --- MAPPER ---
    QAM16_Symb = zeros(1, 25);
    for n = 1:25
        % Extract 4 bits at a time
        idx = (n-1)*4 + 1;
        bits = b(idx:idx+3);
        
        b0b1 = bits(1:2);
        b2b3 = bits(3:4);
        
        % Map Real Part (b0, b1) 
        if     isequal(b0b1, [0 0]), real_part = -3;
        elseif isequal(b0b1, [0 1]), real_part = -1;
        elseif isequal(b0b1, [1 1]), real_part = 1;
        elseif isequal(b0b1, [1 0]), real_part = 3;
        end
        
        % Map Imaginary Part (b2, b3)
        if     isequal(b2b3, [0 0]), imag_part = -3;
        elseif isequal(b2b3, [0 1]), imag_part = -1;
        elseif isequal(b2b3, [1 1]), imag_part = 1;
        elseif isequal(b2b3, [1 0]), imag_part = 3;
        end
        
        QAM16_Symb(n) = real_part + 1i * imag_part;
    end
    
    % Ideal channel
    rx_QAM16_Symb = QAM16_Symb;
    
    % --- DE-MAPPER ---
    QAM16_Bit = zeros(1, 100);
    for n = 1:25
        symb = rx_QAM16_Symb(n);
        r_part = real(symb);
        i_part = imag(symb);
        
        idx = (n-1)*4 + 1;
        
        % De-map Real Part back to b0, b1
        if     r_part == -3, QAM16_Bit(idx:idx+1) = [0 0];
        elseif r_part == -1, QAM16_Bit(idx:idx+1) = [0 1];
        elseif r_part ==  1, QAM16_Bit(idx:idx+1) = [1 1];
        elseif r_part ==  3, QAM16_Bit(idx:idx+1) = [1 0];
        end
        
        % De-map Imaginary Part back to b2, b3
        if     i_part == -3, QAM16_Bit(idx+2:idx+3) = [0 0];
        elseif i_part == -1, QAM16_Bit(idx+2:idx+3) = [0 1];
        elseif i_part ==  1, QAM16_Bit(idx+2:idx+3) = [1 1];
        elseif i_part ==  3, QAM16_Bit(idx+2:idx+3) = [1 0];
        end
    end
    
    errors = sum(b ~= QAM16_Bit);
    fprintf('16-QAM Bit Errors: %d\n', errors);

end