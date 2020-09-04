function [v, best, details] = parV(D, P, psi, k, nClasses, RNG, cores)
rng(RNG)
fold_indxs = crossvalind('Kfold', size(D, 1), k);
train_Xs = cell(k, 1);
test_Xs = cell(k, 1);
train_Ys = cell(k, 1);
test_Ys = cell(k, 1);
for fold = 1:k
    train_Xs{fold} = D((fold_indxs ~= fold), :);
    test_Xs{fold} = D((fold_indxs == fold), :);
    train_Ys{fold} = P(fold_indxs ~= fold);
    test_Ys{fold} = P(fold_indxs == fold);
end

v = 0;
best = 1;
n = length(psi);
details = zeros(n, 1);
for i = 1:n
    clsi = psi{i};
    v_current = 0;
    
    parfor (j = 1:k, cores)
        model = clsi(train_Xs{j}, train_Ys{j});
        rng(i * j + RNG);
        pred = predict(model, test_Xs{j});
        
        if iscell(pred)
            pred = cell2mat(pred) - '0';
        end
        
        if isnumeric(pred) == 0
            error('predict() does not return a numeric vector or cell array of strings with classifier(%d)', i)
        end
        
        M = ComputeConfusionMatrix(test_Ys{j}, pred, nClasses);
        if nClasses < 3
            TP = M(1, 1);
            TN = M(2, 2);
            FP = M(1, 2);
            FN = M(2, 1);
            AUC = ComputeTwoClassAUC(TP, FN, FP, TN);
        else
            AUC = ComputeMultiClassAUC(M, nClasses);
        end
        v_current = v_current + AUC;
    end
    
    % final AUC for current classifier is the average of all cross valids
    v_current = v_current / k;
    details(i) = v_current;
    
    % check if current classifier is the best seen so far
    if v_current > v % update best AUC seen and index of best classifier
        v = v_current;
        best = i;
    end
end
end