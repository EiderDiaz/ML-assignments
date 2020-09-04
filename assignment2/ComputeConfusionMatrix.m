function confusionMatrix = ComputeConfusionMatrix(truelabel, predicted, k)
confusionMatrix = zeros(k, k);
for i = 1:length(truelabel)
    temp = confusionMatrix(truelabel(i), predicted(i));
    confusionMatrix(truelabel(i), predicted(i)) = temp + 1;
end
end
