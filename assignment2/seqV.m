function [v, best, details] = seqV(D, P, psi, k, nClasses, RNG)
rng(RNG)
fold_indxs = crossvalind('Kfold', size(D, 1), k);

v = 0;
best = 1;
n = length(psi);
details = zeros(n, 1);

for i = 1:n
    v_current = 0;
    
    for j = 1:k
        test = (fold_indxs == j);
        train = ~test;
        rng(i * j + RNG);
        model = psi{i}(D(train, :), P(train));
        pred = predict(model, D(test, :));
        
        if iscell(pred)
            pred = cell2mat(pred) - '0';
        end
        
        if isnumeric(pred) == 0
            error('predict() does not return a numeric vector or cell array of strings with classifier(%d)', i)
        end
        
        M = ComputeConfusionMatrix(P(test), pred, nClasses);
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
    
    v_current = v_current / k;
    details(i) = v_current;
    
    if v_current > v
        v = v_current;
        best = i;
    end
end

end