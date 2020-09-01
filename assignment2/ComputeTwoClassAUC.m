function AUC = ComputeTwoClassAUC(TP, FN, FP, TN)
positives = TP + FN;
negatives = TN + FP;
if positives > 0
    tprate = TP / positives;
else
    tprate = 1;
end
if negatives > 0
    fprate = TN / negatives;
else
    fprate = 1;
end
AUC = (tprate + fprate) / 2;
end