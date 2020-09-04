function [v, best, details] = vic(D, psi, omega, k, RNG, cores)
P = omega(D);

if isnumeric(P) == 0
    error('clustering algorithm does not return a numeric vector')
end

if sum(P > 0) ~= length(P)
    error('clustering algorithm does not return only positive integers as classes')
end

classes = unique(sort(P));
if classes(1) ~= 1
    error('clustering algorithm does not start indexing classes at 1')
end

nClasses = length(classes);
if nClasses < 2
    error('clustering algorithm produced a partition with less than 2 classes')
end

if cores > 1
    [v, best, details] = parV(D, P, psi, k, nClasses, RNG, cores);
else
    [v, best, details] = seqV(D, P, psi, k, nClasses, RNG);
end

end