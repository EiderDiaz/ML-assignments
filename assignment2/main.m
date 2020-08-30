% Load dataset and set it up
X = readtable("data.csv", 'TreatAsEmpty',{'NA'});
global score
score = table2array(X(:, X.Properties.VariableNames('score_change')));
X = table2array(removevars(X, {'score_change'}));

% Prepare the parameters to pass to the VIC
clust_alg = @(X) randPart(X, 3, 30, 123); % ignored, nparts, minSize, RNG
classifiers = {@(X, Y) fitctree(X, Y) % CART
    @(X, Y) fitcknn(X, Y, 'NumNeighbors', 3)}; % KNN

% Run VIC
[AUC, winner] = vic(X, classifiers, clust_alg, 5, 4500);
disp(AUC);
disp(classifiers{winner})