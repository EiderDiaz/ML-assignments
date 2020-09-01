% Define the function that makes the partitioning
function part = randPart(~, nparts, minSize, RNG)
global score
n = length(score);
part = zeros(n, 1);
next = 1;
while nparts > 0
    nparts = nparts - 1;
    lowerlim = next + minSize - 1;
    upperlim = n - (minSize * nparts);
    if upperlim < lowerlim
        upperlim = lowerlim;
    end
    rng((nparts + 1) * RNG,'twister');
    i = randi([lowerlim upperlim], 1, 1);
    part(next:i) = nparts;
    next = i + 1;
end
part = part + 1;
end