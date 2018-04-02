

for(k=1:itmax)
    %fprintf('*******************Iteracion %d*******************************\n',k);
    if(mod(k,pval)==0)
        %fprintf('Iteraccion de validacion\n');
        fprintf(propa,'\n***************************** Validacion it=%d ******************************\n',k);
        eval=0;
        tam = size(subval);
        x = tam(1);%cantidad de datos del conjunto de validacion
        %SE PROPAGAN TODOS LOS DATOS DEL CONJUNTO DE VALIDACION
        for(j=1:x)
            pi = subval(j,1:y-salidas)';
            t = subval(j,entradas+1:y);
            
            %SE PROPAGA EL DATO HACIA ADELANTE
            a = Propagation(pi,W,b,fun,nlay);
            fprintf(propa,'dato=[%d] val=[%f] res=[%f] esp=[%f]',j,pi,a{nlay},t);
            fprintf(propa,'\n');
            %SE CALCULA EL ERROR EN EL DATO
            e = (t-a{1,nlay});
            ed = e*e';
            
            %SE AGREGA AL ERROR DE VALIDACION
            eval = eval + ed;
        end
        
        eval = eval/x;
        if(valviejo<eval && valviejo~=0)
            cont = cont + 1;
        else
            cont = 0;
        end
        valviejo = eval;
        %Escribir en el archivo el comportamiento del error
        fprintf('errorVA= %f\n',eval);
        fprintf(ploterror,'%f\n',eval);
    else
        %fprintf('Iteraccion de entrenamiento\n');
        tam = size(suba);
        x = tam(1);%cantidad de datos del conjunto de aprendizaje
        eit=0;
        fprintf(pesos,'\n***************************** Aprendizaje it=%d ******************************\n',k);
        fprintf(propa,'\n***************************** Aprendizaje it=%d ******************************\n',k);
        %SE PROPAGAN TODOS LOS DATOS DEL CONJUNTO DE APRENDIZAJE
        for(j=1:x)
        %    fprintf('********NUEVO DATO*******\n');
        %    fprintf('DATO: %f\n',pi');
            pi = suba(j,1:y-salidas)';
            t = suba(j,entradas+1:y);
        %    fprintf('Target: %f\n',t);
            %SE PROPAGA EL DATO HACIA ADELANTE
            Want=W;
            a = Propagation(pi,W,b,fun,nlay);
            fprintf(propa,'dato=[%d] val=[%f] res=[%f] esp=[%f]',j,pi,a{nlay},t);
            fprintf(propa,'\n');
        %    fprintf('Resultado de propagacion %f\n',a{1,nlay});
            %SE CALCULA EL ERROR EN EL DATO
            e = (t-a{1,nlay});
            ed = e*e';
        %    fprintf('error de dato %f\n',ed);
            %fprintf('Error de dato de %f\n',ed);
            %SE AGREGA AL ERROR DE ITERACION
            eit = eit + ed;
            
            %CALCULAMOS SENSITIVIDADES
            S = Sensitivities(nlay, arq, fun, a, t, W);
            
            %ACTUALIZAMOS PESOS Y BIAS
            fprintf(pesos,'\n*************** Aprendizaje it=%d dato=%d**********\n',k,j);
                
            for(i=1:nlay-1)
                W{1,i} = W{1,i} - (facapre * S{1,nlay-i} * a{1,i}');
                b{1,i} = b{1,i} - (facapre * S{1,nlay-i});
                fprintf(pesos,'%f\t',W{i});
                fprintf(pesos,'\n');
                fprintf(pesos,'bias:\t');
                fprintf(pesos,'%f\t',b{i});
                fprintf(pesos,'\n');
            end
            
        end
        eit = eit/x;
        %Escribir en el archivo el comportamiento del error
        %fprintf('errorIT= %f\n',eit);
        fprintf(ploterror,'%f\n',eit);
    end;
    
    if(eit<=eitmin)
            motivo = 'El error de iteracion es menor al especificado';
            break;
    end
    if(cont==maxval)
            motivo = 'Numero maximo de incrementos alcanzados';
            break;
    end
end

%PROPAGACION DE TODOS LOS DATOS DEL CONJUNTO DE PRUEBA
tam = size(subpru);
x = tam(1);%cantidad de datos del conjunto de prueba
epru=0;

fprintf(pesos,'\n*************** Finales **********\n');
for(i=1:nlay-1)
    fprintf(pesos,'%f\t',W{i});
    fprintf(pesos,'\n');
    fprintf(pesos,'bias:\t');
    fprintf(pesos,'%f\t',b{i});
    fprintf(pesos,'\n');
end
fclose(pesos);
fprintf(propa,'\n***************************** Validacion ******************************\n');


for(i=1:x)
    
    pi = subpru(i,1:y-salidas)';
    t = subpru(i,entradas+1:y);
    
    %SE PROPAGA EL DATO HACIA ADELANTE
    a = Propagation(pi,W,b,fun,nlay);
    fprintf(propa,'dato=[%d] val=[%f] res=[%f] esp=[%f]',i,pi,a{nlay},t);
    fprintf(propa,'\n');
    
    %SE CALCULA EL ERROR EN EL DATO
    e = (t-a{nlay});
    ed = e*e';
    
    %SE AGREGA AL ERROR DE PRUEBA
    epru = epru + ed;
end
epru = epru/x;
fprintf(ploterror,'%f\n',epru);
fclose(propa);
fprintf('Error de prueba=%f\n',epru);
fprintf('Motivo=%s itFinal=%d\n',motivo,k);

