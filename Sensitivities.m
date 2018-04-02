function [S] = Sensitivities(nlay, t, a, W,arq,fun)
    
    M = nlay -1;
    S = cell(1,M);
    F = cell(1,M);
    
    for i=1:M%Se calcula la matriz de derivadas de todas las capas
        nneu = arq(i+1);
        mF = ones(1,nneu);
        for j= 1:nneu
            switch fun(i)
                case 1
                    mF(j) = 1;
                case 2
                    tempa = a{i+1};
                    mF(j) = tempa(j)*(1 - tempa(j));
                case 3
                    tempa = a{i+1};
                    mF(j) = 1 - (tempa(j)^2);
            end
        end
        F{i} = diag(mF);%Se crea la matriz de esta capa
    end
    
    
    S{M} = -2 * F{M} * (t - a{nlay});
    
    for m=1:M-1
        S{M-m} = F{M-m} * W{M-m+1}' * S{M-m+1}; 
    end
    
end