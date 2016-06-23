function[y]=segmcirc(x,L,M,Q)
%      y=segmcirc(X,L,M,Q)
%
%      Given the data samples X=(x_1,x_2,...,x_N),     
%      the program obtains Q overlapping (M<L) or 
%      non-overlapping (M>=L) segments, each of L samples 
%      in the form of a matrix "y" of L rows and Q columns. 
%      The data X_i is "wrapped" around in a circle, that is, 
%      define (for i>N) X_i=X_iN, where iN=i(mod N).  
%             _______________     
%       .....|_______L_______| .....
%       .....|____M____|_______L_______| .....
%       .....|___ M ___|___ M ___|______ L ______| .....       
%  
%      The procedure is used for the circular block bootstrap.
%        
%     Inputs:
%          X - input vector data 
%          L - number of elements in a segment
%          M - shift size (i.e. L-M is the size of overlap) 
%          Q - number of desired segments
%     Output:
%          y - the output matrix of the data

%  Created by A. M. Zoubir and  D. R. Iskander
%  May 1998
%
%  References:
% 
% Politis, N.P. and Romano, J.P. Bootstrap Confidence Bands for  Spectra
%           and Cross-Spectra. IEEE Transactions on  Signal  Processing,
%           Vol. 40, No. 5, 1992. 
%
% Zhang, Y. et. al. Bootstrapping Techniques in the Estimation of Higher
%           Order Cumulants from Short Data Records. (Proceedings of the
%           International Conference on  Acoustics,  Speech  and  Signal 
%           Processing, ICASSP-93, Vol. IV, pp. 200-203.
%
%  Zoubir, A.M. Bootstrap: Theory and Applications. Proceedings 
%               of the SPIE 1993 Conference on Advanced  Signal 
%               Processing Algorithms, Architectures and Imple-
%               mentations. pp. 216-235, San Diego, July  1993.
%
%  Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application
%               in Signal Processing. IEEE Signal Processing Magazine, 
%               Vol. 15, No. 1, pp. 55-76, 1998.
						      
x=x(:);
N=length(x);
y=zeros(L,Q); 
Ny=Q*M+L-1;
Y=zeros(Ny,1);  
r=0;

for ii=1:Ny,
  Y(ii)=x(ii-rem(N*r,ii));
  if ii/N==r+1,
     r=r+1;
  end;
end; 
for ii=1:Q,   
  y(:,ii)=Y((ii-1)*M+1:(ii-1)*M+L);
end;





