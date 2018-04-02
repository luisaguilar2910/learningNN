function [a] = Propagation(W,b,pi,nlay,fun)
    a = cell(1,nlay);
    a{1} = pi;
    for i=2:nlay
        switch fun(i-1)
            case 1
                a{i} = purelin(W{i-1}*a{i-1} + b{i-1});
            case 2
                a{i} = logsig(W{i-1}*a{i-1} + b{i-1});
            case 3
                a{i} = tansig(W{i-1}*a{i-1} + b{i-1});
        end
    end
end
