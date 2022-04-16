clear all
close all

a = sqrt(2);
G = [1 0 0 1 0 0 1 0 0;
     0 1 0 0 1 0 0 1 0;
     0 0 1 0 0 1 0 0 1;
     1 1 1 0 0 0 0 0 0;
     0 0 0 1 1 1 0 0 0;
     0 0 0 0 0 0 1 1 1;
     a 0 0 0 a 0 0 0 a;
     0 0 0 0 0 0 0 0 a];
 
 [U,S,V] = svd(G);
 
 
 diag(S)
 rank(G)
 V0 = [V(:,8), V(:,9)]
 
 diag(S)
 
 Vp = V(1:7,:)
 R  = Vp*Vp';
 
 
 imagesc(R)
 colormap('bone')
 colorbar()