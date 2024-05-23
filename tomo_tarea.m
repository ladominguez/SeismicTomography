clear all
close all

N = 9;   % N�mero de celdas
R = 20;  % N�mero de rayos 
Ni = 201; % N�mero de puntos de interpolaci�n   
Wa = N/8;   % Ancho de la espiga

noise  = 0.01;
alpha = 0.1;
W  = 1;   

G  = zeros(R,N*N);
Gv = zeros(N,N);
S  = zeros(N,N); 
m  = zeros(N);
t  = zeros(R,1);


x_max = W*N;
y_max = W*N;

S0 = (1/x_max);
dS = 0.5*S0;
dSdz = 0.001;


% Create checkboard
% Selecciona algeun modelo que te interese. Descomentandolo y comentando
% los modelos restantes. Est�s son las opciiones.

% 1. Checkboard. 
% 2. Gradiente vertical. 
% 3. Gradiente daigonal.
% 4. Spike

for i = 1:N
    for j = 1:N
        m(i,j) = mod(i+j,2)-(W/2);
        
        %% 1. Checkboard
        S(i,j) = S0 + (-1)^(fix(i/2)+fix(j/2))*dS;  % Checkboar (+/-)dV
        
        %% 2. Gradiente vertical.
        %S(i,j) = S0 + (dSdz)*(i*W);    % Gradient
       
        %% 3. Gradiente diagonal
        %S(i,j) = S0 + (dSdz)*(i*W + j*W); % Gradient diagonal
        
        %% 4. Spike
%         if i >= N/2-Wa && i<= N/2+Wa
%             if j >= N/2-Wa && j<=N/2+Wa
%                 S(i,j) = 1;%S0 - dS;
%             else
%                 S(i,j) = 0;%S0;
%             end
%         else
%             S(i,j) = 0;%S0;
%         end

% ------------------------------- end spike ------------------
    end 
end


% Vectores de coordenadas
x = 0:x_max-W;
y = 0:y_max-W;


%% Creaci�n de N rayos de forma aleatoria uniformente distribuidos

dir = rand(1,R) - 0.5;
xr = zeros(R,2);
yr = zeros(R,2);

for k = 1:R
    if dir(k) > 0
        xr(k,:) = [0, x_max];
        yr(k,:) = [y_max*rand(1) y_max*rand(1)];
    else
        xr(k,:) = [x_max*rand(1) x_max*rand(1)];
        yr(k,:) = [y_max, 0];
    end
end

slope = (yr(:,2) - yr(:,1))./(xr(:,2)-xr(:,1));
b     = yr(:,1) -slope.*xr(:,1);

index = zeros(Ni-1,2);

%% Tarea - Creaci�n de la matriz G
% es esta secci�n deber�s de escribir un c�digo que asigne valores a la
% matriz G. En el que cada elemento de la matrix debe de contener la
% longitud del rayo que lo atraviesa.
% Escriibe tu c�digo aqu�




 
%% FIN - secci�n de tarea


% Se argega ruido a los datos
t1 = t;
t  = t + + noise*mean(t)*randn(size(t));

%% Graficaci�n
figure(1)

set(gcf,'OuterPosition',[56   67  1374   802])
subplot(2,3,1)
imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',m)
title('Reticula y trazado de rayos', 'fontsize', 14)
hold on


for k =1:R
    plot([xr(k,1) xr(k,2)], [yr(k,1) yr(k,2)],'r','LineWidth',2)
end
axis tight

subplot(2,3,2)
imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',1- Gv'./max(max(Gv)))
colormap(gray)
axis tight
title('Matriz G', 'fontsize', 14)


subplot(2,3,4)
imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',S)
colormap(gray)
colorbar()
axis tight
title('Modelo de velocidades', 'fontsize', 14)

minv = pinv(G)*t;

subplot(2,3,5)
%imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',reshape(minv,N,N))
contourf(reshape(minv,N,N))
title('Inversi�n mediante la pseudo inversa', 'fontsize', 14)
colormap(gray)
colorbar()
axis tight

%% SVD Damped solution - Tikhonov regularizatiion
% Ver cap�tulo 4, secci�n 4.2. aster, Paramer estimation and inverse theory



Gdls  = [G; alpha*eye(size(G,2))];
d     = [t];

[U, S, V] = svd(G);
k         = min(size(G,1), size(G,2));
si        = diag(S);
m_alpha   = zeros(size(G,2), 1);

%% Factores de filtro
% Ver ecuaci�n 4.17, Aster, Paremeter Estimation and Inverse Theory 

for i=1:k
    fi(i)   = si(i)^2/(si(i)^2 + alpha^2);
    aux     = U(:,i)'*d*fi(i)/si(i);
    m_alpha = m_alpha+aux*V(:,i);
        
end

subplot(2,3,3)
plot(fi,'ko')
ylim([0,1])
title('Factores de Filtro')
xlabel('indice i')
ylabel('$f_i=\frac{s^2_i}{s^2_i+\alpha^2}$','Interpreter','Latex','FontSize',14)

subplot(2,3,6)
%imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',reshape(m_alpha,N,N))
contourf(reshape(m_alpha,N,N));
colormap(gray)
colorbar()
title('Regularizaci�n')
axis tight

figure(2)
[ts ind] = sortrows(t1);
plot(ts,'k','Linewidth',2)
hold on
plot(t(ind),'k+')
grid
xlabel('N�mero de observaci�n')
ylabel('Tiempo')

legend('Sin ruido', 'Con ruido')
title('Datos')
set(gcf,'Color','w')

set(gca,'FontSize',14,'FontName','Helvica')
xlabel(get(get(gca,'xlabel'),'String'),'FontSize',14,'FontWeight','normal','FontAngle','normal','FontName','Helvica') 
ylabel(get(get(gca,'ylabel'),'String'),'FontSize',14,'FontWeight','normal','FontAngle','normal','FontName','Helvica') 
return


