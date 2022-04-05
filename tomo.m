clear all
close all

N = 8;  % Numero de celdas
R = 1; % Número de rayos 

m = zeros(N);

for i = 1:N
    for j = 1:N
        m(i,j) = mod(i+j,2)-0.5;
    end 
end


x = 0:N-1;
y = 0:N-1;


imagesc('XData',x+0.5,'YData',y+0.5,'CData',m)
hold on
%plot([0 8],[0 8],'k-','LineWidth',2,'MarkerSize',14)


dir = rand(1,R) - 0.5;

xr = zeros(R,2);
yr = zeros(R,2);

for k = 1:R
    if dir(k) > 0
        xr(k,:) = [0, 8];
        yr(k,:) = [8*rand(1) 8*rand(1)];
    else
        xr(k,:) = [8*rand(1) 8*rand(1)];
        yr(k,:) = [8, 0];
    end
    
    plot([xr(k,1) xr(k,2)], [yr(k,1) yr(k,2)],'r','LineWidth',4)
end

slope = (yr(:,2) - yr(:,1))./(xr(:,2)-xr(:,1))
b     = yr(:,1) -slope.*xr(:,1)