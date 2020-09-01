clear all; close all; clc;

% Load dataset and set it up
X = readtable("data.csv", 'TreatAsEmpty',{'NA'});
global score
score = table2array(X(:, X.Properties.VariableNames('score_change')));
X = table2array(removevars(X, {'score_change'}));

% Prepare the parameters to pass to the VIC
clust_alg = @(X) randPart(X, 3, 30, 123); % ignored, nparts, minSize, RNG
classifiers = {@(X, Y) fitctree(X, Y) % CART
    @(X, Y) fitcknn(X, Y, 'NumNeighbors', 3) % KNN
    @(X, Y) fitcnb(X, Y) % Naive Bayes
    @(X, Y) fitcdiscr(X, Y) % Linear Discriminant Analysis
    @(X, Y) fitcensemble(X, Y, 'Method', 'Subspace') % Suspace boosting
    @(X, Y) fitcensemble(X, Y, 'Method', 'AdaBoostM2') % Adaboost
    @(X, Y) TreeBagger(100, X, Y)}; % Random Forest 100 trees

% Run VIC
[AUC, winner] = vic(X, classifiers, clust_alg, 2, 4500);
disp(AUC);
disp(classifiers{winner});