function AUC = ComputeMultiClassAUC(confusionMatrix)
k = size(confusionMatrix, 2);
TP = 0;
for i = 1:(k - 1)
    TP = TP + confusionMatrix(i, i);
    FN = 0;
    FP = 0;
    TN = 0;
    for j = 1:(k - 1)
        if i ~= j
            FN = FN + confusionMatrix(i, j);
            FP = FP + confusionMatrix(j, i);
            TN = TN + confusionMatrix(j, j);
        end
    end
end
AUC = ComputeTwoClassAUC(TP, FN, FP, TN);
end