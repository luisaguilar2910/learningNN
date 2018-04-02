ploterror = fopen('ploterror.txt','w+');
pesos = fopen('pesos.txt','w');
propa = fopen('propagacion.txt','w');

%SE LE PIDE AL USUARIO LOS DATOS A UTILIZAR

%definir arquitectura
arq = input('Ingrese la arquitectura de la red neuronal\n');
fun = input('Ingrese el conjunto de funciones de activacion\n1.-pureline(n)\n2.-logsig(n)\n3.-tansig(n)\n');

lay = size(arq);
nlay = lay(2);

%definir archivo de pruebas
[filename, pathname] =uigetfile({'*.txt'},'Abrir Data');
A = load(strcat(pathname,filename));
%[filename, pathname] =uigetfile({'*.txt'},'Abrir target');
%target = load(strcat(pathname,filename));
%[filename, pathname] =uigetfile({'*.txt'},'Abrir Documento');
%A = load(strcat(pathname,filename));
tam = size(A);



x = tam(1);%Cantidad de datos
y = tam(2);%Numero de entradas y targets

%NORMALIZAMOS DATOS

entradas = arq(1,1);
salidas = arq(1,nlay);

minA = min(A(1:end,entradas+1:y));
maxA = max(A(1:end,entradas+1:y));
normFact = max(maxA,abs(minA));

for i=1:x
    A(i,entradas+1:y)=A(i,entradas+1:y)/normFact;
end

eitmin = input('Ingrese el valor de error minimo\n'); 
itmax = input('Ingrese el numero de iteraciones maximas\n');
pval = input('Ingrese el valor de pval\n');
maxval = input('Ingrese el valor de valmax\n');
facapre =  input('Ingrese el valor del factor del aprendizaje\n');

%SE INICIALIZAN PESOS Y BIAS

W = cell(1,nlay-1);
b = cell(1,nlay-1);

fprintf(pesos,'\n*************** Iniciales **********\n');
for(i=1:nlay-1)
    W{1,i} = rand(arq(1,i+1),arq(1,i));
    b{1,i} = rand(arq(1,i+1),1);
    fprintf(pesos,'%f\t',W{i});
    fprintf(pesos,'\n');
end


tam = size(A);
x=tam(1);
R2 = ones(x,1);

%SE GENERAN LOS SUBCONJUNTOS DE VALIDACION Y PRUEBA

opc = input('¿Como desea dividir el conjunto de aprendizaje?\n1.- 70% aprendizaje 15% validacion 15% prueba\n2.- 80% aprendizaje 10% validacion 10% prueba\n');

switch(opc)
    case 1
        val = .15;
    case 2
        val = .10;
end;

[suba,subval,subpru]=getSubMatrices(val,A);

%SE INICIA APRENDIZAJE



motivo='Numero de iteracciones maximas alcanzadas';

cont = 0;
valviejo=0;
valnuevo=0;

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
            a = Propagation(W,b,pi,nlay,fun);
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
            a = Propagation(W,b,pi,nlay,fun);
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
            S = Sensitivities(nlay, t, a, W,arq,fun);
            
            %ACTUALIZAMOS PESOS Y BIAS
            fprintf(pesos,'\n*************** Aprendizaje it=%d dato=%d**********\n',k,j);
            M = nlay-1;
            
            for m=1:M
                W{nlay-m} = W{nlay-m} - (facapre * S{nlay-m} * a{nlay-m}');
                b{nlay-m} = b{nlay-m} - (facapre * S{nlay-m});
                fprintf(pesos,'%f\t',W{nlay-m});
                fprintf(pesos,'\n');
                fprintf(pesos,'bias:\t');
                fprintf(pesos,'%f\t',b{nlay-m});
                fprintf(pesos,'\n');
            end;
            
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

for(j=1:x)
        %    fprintf('********NUEVO DATO*******\n');
        %    fprintf('DATO: %f\n',pi');
            pi = suba(j,1:y-salidas)';
            t = suba(j,entradas+1:y);
        %    fprintf('Target: %f\n',t);
            %SE PROPAGA EL DATO HACIA ADELANTE
            a = Propagation(W,b,pi,nlay,fun);
            fprintf(propa,'dato=[%d] val=[%f] res=[%f] esp=[%f]',j,pi,a{nlay},t);
            fprintf(propa,'\n');
        
end


for(i=1:x)
    
    pi = subpru(i,1:y-salidas)';
    t = subpru(i,entradas+1:y);
    
    %SE PROPAGA EL DATO HACIA ADELANTE
    a = Propagation(W,b,pi,nlay,fun);
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


frewind(ploterror);

subplot(2,1,1)
[E,conte] = fscanf(ploterror,'%f');
plot(E,'o-r')
xlabel('Iteraccion')
ylabel('Error')
title('Grafica del error por iteraccion')
legend('Error')
grid on

subplot(2,1,2)
plot(A(1:end,1),A(1:end,2)*normFact,'-.b')
xlabel('X')
ylabel('Y')
title('Grafica de la funcion')
grid on
hold on

tam = size(A);
x=tam(1);
R = ones(x,1);

resp = fopen('ResultadosFinales.txt','w');
for(i=1:x)
    a = Propagation(W,b,A(i,1:y-salidas)',nlay,fun);
    R(i,1) = a{nlay};
    fprintf(resp,'%f\t',A(i,1:y-salidas));
    fprintf(resp,'%f\t',a{nlay}*normFact);
    fprintf(resp,'\n');
end
fclose(resp);

plot(A(1:end,1),R*normFact,'o r');

legend('F(x)','Aprox');

%for(i=1:nlay-1)
%        W{1,i}
%        b{1,i}
%end