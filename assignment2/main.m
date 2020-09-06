clear all; close all; clc;

% Load dataset and set it up
X = readtable("data.csv", 'TreatAsEmpty',{'NA'});
global score
score = table2array(X(:, X.Properties.VariableNames('score_change')));
X = table2array(removevars(X, {'score_change'}));
reps = 50;

% Binary classes experiment
classifiers_binary = {@(X, Y) fitctree(X, Y) % CART
    @(X, Y) fitcknn(X, Y, 'NumNeighbors', 3) % KNN
    @(X, Y) fitcnb(X, Y) % Naive Bayes
    @(X, Y) fitcdiscr(X, Y) % Linear Discriminant Analysis
    @(X, Y) fitcensemble(X, Y, 'Method', 'Subspace') % Random subspace method
    @(X, Y) fitclinear(knnimpute(X), Y, 'Learner', 'logistic') % Logistic regression
    @(X, Y) TreeBagger(100, X, Y) % Random Forest 100 trees
 };
AUCs_binary = zeros(reps, length(classifiers_binary));
for i = 1:reps
    disp(i);
    clust_alg = @(X) randPart(X, 2, 30, i); % unused, nparts, minsize, RNG
    [~, ~, temp] = vic(X, classifiers_binary, clust_alg, 10, 4500, 2);
    AUCs_binary(i, :) = temp;
end
AUCs_binary = array2table(AUCs_binary);
AUCs_binary.Properties.VariableNames = {'CART', 'KNN', 'NB', 'LDA', 'RSM', 'LR', 'RF'};
writetable(AUCs_binary, "AUCs_binary.csv");

% 3 classes experiment
classifiers_three = {@(X, Y) fitctree(X, Y) % CART
    @(X, Y) fitcknn(X, Y, 'NumNeighbors', 3) % KNN
    @(X, Y) fitcnb(X, Y) % Naive Bayes
    @(X, Y) fitcdiscr(X, Y) % Linear Discriminant Analysis
    @(X, Y) fitcensemble(X, Y, 'Method', 'Subspace') % Suspace boosting
    @(X, Y) fitcensemble(X, Y, 'Method', 'AdaboostM2') % Adaboost
    @(X, Y) TreeBagger(100, X, Y) % Random Forest 100 trees
 };
AUCs_three = zeros(reps, length(classifiers_three));
for i = 1:reps
    disp(i);
    clust_alg = @(X) randPart(X, 3, 30, i); % unused, nparts, minsize, RNG
    [~, ~, temp] = vic(X, classifiers_three, clust_alg, 10, 4500, 2);
    AUCs_three(i, :) = temp;
end
AUCs_three = array2table(AUCs_three);
AUCs_three.Properties.VariableNames = {'CART', 'KNN', 'NB', 'LDA', 'RSM', 'ADA', 'RF'};
writetable(AUCs_three, "AUCs_three.csv");
