clear; clc;
symbol = [
     1+1i
     1-1i
    -1+1i
    -1-1i
];

y = [
     0.0222 - 1i*0.0169
     1.4509 - 1i*0.7471
    -1.6027 - 1i*1.9480
     1.6105 - 1i*2.2362
    -1.1898 + 1i*0.1263
    -0.6067 + 1i*0.8870
     0.0579 - 1i*0.1223
     0.6309 - 1i*0.4483
    -0.0330 + 1i*0.2217
     1.5283 - 1i*1.6817
     0.4960 + 1i*1.1453
     2.3859 + 1i*0.7010
];

state_1 = [0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 3];   % x(k-1)
state_2 = [0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3];   % x(k-2)


%% Viterbi
pathMetric = inf(16, 13);    % pathMetric(idx, time+1)
fromState  = zeros(16, 12);  % fromState(newIdx, time)
usedSym    = zeros(16, 12);  % usedSym(newIdx, time)

% 初始狀態  x(-1) = x(-2) = 0
pathMetric(1, 1) = 0;

for time = 1:12
    if time <= 10
        tryInputs = 0:3;
    else
        tryInputs = 0;       % x(10) = x(11) = 0
    end

    for idx = 1:16
        a = state_1(idx);     % x(k-1)
        b = state_2(idx);     % x(k-2)
        current = pathMetric(idx, time);

        for input = tryInputs 
            expectedY = symbol(input+1) + 0.3 * symbol(a+1) + 0.7 * symbol(b+1);
            dist = abs(y(time) - expectedY)^2;
            newMetric = current + dist;

            % (a,b) ---> (input,a)
            newIdx = input*4 + a + 1;
            if newMetric < pathMetric(newIdx, time+1)
                pathMetric(newIdx, time+1) = newMetric;
                fromState(newIdx, time) = idx;
                usedSym(newIdx, time) = input;
            end
        end
    end
end


% Traceback
% 已知最後回到 state (0,0)，所以 idx = 1
idx = 1;
symbolIndex = zeros(1, 12);

for time = 12:-1:1
    % 第 time 步使用的 symbol
    symbolIndex(time) = usedSym(idx, time);
    % 回到上一個 state
    idx = fromState(idx, time);
end


fprintf('估計出的 x0 ~ x9:\n');
for time = 1:10
    sIdx = symbolIndex(time);
    s = symbol(sIdx+1);
    bits = dec2bin(sIdx, 2);
    fprintf('x_%d = %+.0f %+.0fj, bits = %s\n',time-1, real(s), imag(s), bits);
end
fprintf('\n最小誤差 = %.8f\n', pathMetric(1, 13));


%% Brute-force 驗證 Viterbi 輸出
best = inf;
best_seq = [];

for x0 = 0:3
for x1 = 0:3
for x2 = 0:3
for x3 = 0:3
for x4 = 0:3
for x5 = 0:3
for x6 = 0:3
for x7 = 0:3
for x8 = 0:3
for x9 = 0:3
    x = [x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 0 0];

    total = 0;

    for k = 1:12
        if k-1 >= 1
            a = x(k-1);
        else
            a = 0;
        end

        if k-2 >= 1
            b = x(k-2);
        else
            b = 0;
        end
        expectedY = symbol(x(k)+1) + 0.3 * symbol(a+1) + 0.7 * symbol(b+1);
        total = total + abs(y(k) - expectedY)^2;
    end
    if total < best
        best = total;
        best_seq = [x0 x1 x2 x3 x4 x5 x6 x7 x8 x9];
    end
end
end
end
end
end
end
end
end
end
end
fprintf('\nbrute-force 最小誤差 = %.8f\n', best);
fprintf('brute-force 序列 = %s\n', mat2str(best_seq));