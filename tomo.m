clear all
close all

N = 64;  % Numero de celdas
R = 90; % N�mero de rayos 
Ni = 201; % Numero de puntos de interpolaci�n 
lambda = .1;
W  = 1;
Wa = N/4;
G  = zeros(R,N*N);
Gv = zeros(N,N);
S  = zeros(N,N); 
m  = zeros(N);
t  = zeros(R,1);

x_max = W*N;
y_max = W*N;

S0 = (1/x_max);
dS = 0.05*S0;
dSdz = 0.001;


% Create checkboard
for i = 1:N
    for j = 1:N
        m(i,j) = mod(i+j,2)-(W/2);
        %S(i,j) = S0 + (-1)^(i+j)*dS;  % Checkboar (+/-)dV
        %S(i,j) = S0 + (dSdz)*(i*W);    % Gradient
        %S(i,j) = S0 + (dSdz)*(i*W + j*W); % Gradient diagonal
        
        if i >= N/2-Wa && i<= N/2+Wa
            if j >= N/2-Wa && j<=N/2+Wa
                S(i,j) = 1;%S0 - dS;
            else
                S(i,j) = 0;%S0;
            end
        else
            S(i,j) = 0;%S0;
        end
    end 
end



x = 0:x_max-W;
y = 0:y_max-W;



%plot([0 8],[0 8],'k-','LineWidth',2,'MarkerSize',14)


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
    
    %plot([xr(k,1) xr(k,2)], [yr(k,1) yr(k,2)],'r','LineWidth',4)
end

slope = (yr(:,2) - yr(:,1))./(xr(:,2)-xr(:,1));
b     = yr(:,1) -slope.*xr(:,1);

index = zeros(Ni-1,2);
for k = 1:R
    if abs(slope(k)) < 1.0
        xt = linspace(0,x_max,Ni);
        yt = slope(k).*xt + b(k);
        %plot(xt,yt,'wo','MarkerSize',14)

        
    else
        yt = linspace(0,y_max,Ni);
        xt = (yt-b(k))./slope(k);
        %plot(xt,yt,'wx','MarkerSize',14)
    end
    
    for j =1:Ni-1
            weight = sqrt((xt(j+1)-xt(j)).^2 + (yt(j+1)-yt(j)).^2 );
            x_mean = (xt(j+1)+xt(j))/2;
            y_mean = (yt(j+1)+yt(j))/2; 
            x_i    = floor(x_mean/W) + 1;
            y_i    = floor(y_mean/W) + 1;
            Gv(x_i, y_i)          = Gv(x_i, y_i) + weight;
            G(k, (y_i-1)*N + x_i) = G(k, (y_i-1)*N + x_i) + weight; 
            t(k)                  = t(k) + S(x_i, y_i)*weight; 
    end
    
    
end


figure(1)
setwin([56          67        1374         802])
subplot(2,3,1)
imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',m)
hold on

for k =1:R
    plot([xr(k,1) xr(k,2)], [yr(k,1) yr(k,2)],'r','LineWidth',2)
end
axis tight

subplot(2,3,2)
imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',1- Gv'./max(max(Gv)))
colormap(gray)
axis tight


subplot(2,3,4)
imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',S)
colormap(gray)
colorbar()
axis tight

minv = pinv(G)*t;

subplot(2,3,5)
imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',reshape(minv,N,N))
colormap(gray)
colorbar()
axis tight

%% 
alpha = 1;
Gdls  = [G; alpha*eye(size(G,2))];
d     = [t];

[U, S, V] = svd(G);
k         = min(size(G,1), size(G,2));
si        = diag(S);
m_alpha   = zeros(size(G,2), 1);

for i=1:k
    fi(i)   = si(i)^2/(si(i)^2 + alpha^2);
    aux     = U(:,i)'*d*fi(i)/si(i);
    m_alpha = m_alpha+aux*V(:,i);
        
end

subplot(2,3,3)
plot(fi,'ko')
ylim([0,1])

subplot(2,3,6)
imagesc('XData',x+(W/2),'YData',y+(W/2),'CData',reshape(m_alpha,N,N))
colormap(gray)
colorbar()
axis tight

return


% archive
m_inv = inv(G'*G)*G'*t;
m_inv = reshape(m_inv, N,N);

Gdlsq  = [G;lambda*eye(N*N)];

m_dslq = pinv(G)*t;
m_dslq = reshape(m_dslq, N,N);