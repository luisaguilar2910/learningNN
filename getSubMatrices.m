function [ subapre subval subpru ] = getSubMatrices( fac, A )
    tam = size(A);
    ndat = tam(1);
    y = tam(2);
    ndatVal = ceil(ndat*fac);
    turn = 0;
    step = floor(ndat/(ndatVal*2));
    sobra = mod(ndat,ndatVal*2)-1;
    n=0;
    if(sobra>=0)
        n=1;
    end
    
    j=1;
    k=1;
    l=1;
    
    subval = ones(ndatVal,y);
    subpru = ones(ndatVal,y);
    subapre = ones(ndat-(ndatVal*2),y);
    
    for(i=1:ndat)
        if(mod(i,step+n)==0&&(j<=ndatVal||k<=ndatVal))
            if(turn==0&&j<=ndatVal)
                subpru(j,1:end) = A(i,1:end);
                turn=1;
                j=j+1;
                fprintf('P');
                sobra=sobra-1;
                if(sobra>=0)
                    n=1;
                else
                    n=0;
                end
            else
                if(k<=ndatVal)
                    subval(k,1:end) = A(i,1:end);
                    turn=0;
                    k=k+1;
                    fprintf('V');
                    sobra=sobra-1;
                    if(sobra>=0)
                        n=1;
                    else
                        n=0;
                    end

                end
            end
        else
            subapre(l,1:end) = A(i,1:end);
            l=l+1;
            fprintf('A');
            
        end
    end
    fprintf('\n');
end

