% Validity Index using supervised Classifiers
% This version uses an averaged AUC computed with perfcurve()
function [v, best] = vic_alt(D, psi, omega, k, RNG)
% Execute the clustering algorithm on the dataset
P = omega(D);

% Find cross-validation indices
rng(RNG)
fold_indxs = crossvalind('Kfold', size(D, 1), k);

% initialize best AUC seen for all classifiers
v = 0;
best = 1;

% for each classifier
for i = 1:length(psi)
    % initialize cross validation average AUC and best classifier seen
    v_current = 0;
    
    % for each fold of cross validation
    for j = 1:k
        test = (fold_indxs == j); % test set indices
        train = ~test; % training set indices
        model = psi{i}(D(train, :), P(train)); % train classifier
        [~, probs] = predict(model, D(test, :)); % get prediction scores
        classes = unique(P(test));
        nclasses = length(classes);
        
        if nclasses > 2 % multiclass problem
            AUC = 0; % variable to sum the AUC for all classes
            % for each class
            for c = 1:length(classes)
                [~, ~ , ~, tmp] = perfcurve(P(test), probs(:, c), c); % AUC
                AUC = AUC + tmp;
            end
            v_current = v_current + (AUC / nclasses); % multiclass AUC mean
        else % binary problem
            [~, ~ , ~, AUC] = perfcurve(P(test), probs(:, 1), 1); % AUC
            v_current = v_current + AUC;
        end    
    end
    
    % final AUC for current classifier is the average of all cross valids
    v_current = v_current / k;
    
    % check if current classifier is the best seen so far
    if v_current > v % update best AUC seen and index of best classifier
        v = v_current;
        best = i;
    end
end

end