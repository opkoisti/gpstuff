% DEMO_LOGITGP  Demonstration of Logistic-Gaussian Process density estimate
%               for 1D and 2D data 
%
%    Description 
%
%    Logistic-Gaussian Process (LOGITGP) is a model for density estimation.
%    For the samples from continuous distribution, the space is discretized
%    into n intervals with equal lengths covering the interesting region. The
%    following model is used in estimation
%    
%        p(y_i|f_i) ~ exp(f_i) / Sum_j^n exp(f_j),
%
%    where a zero mean Gaussian process prior is placed for f =
%    [f_1, f_2,...,f_n] ~ N(0, K). K is the covariance matrix, whose
%    elements are given as K_ij = k(x_i, x_j | th). The function
%    k(x_i, x_j| th) is covariance function and th its parameters,
%    hyperparameters. We place a hyperprior for hyperparameters, p(th).
%
%    The inference is conducted via Laplace and the last example compares
%    the results of Laplace approximation to MCMC. 
%
%    See also  DEMO_LGCP

% Copyright (c) 2011 Jaakko Riihimäki and Aki Vehtari

% This software is distributed under the GNU General Public 
% License (version 3 or later); please refer to the file 
% License.txt, included with the software, for details.

stream = RandStream('mrg32k3a');
RandStream.setDefaultStream(stream);

% =====================================
% 1) 1D-examples
% =====================================

figure(1)
subplot(2,2,1)
% t_4
stream.Substream = 1;
x=[trnd(4,1,100)]';
xt=linspace(-7,7,400)';
logitgp(x,xt);
axis tight
title('t_4')
% true density
p0=t_pdf(xt,4,0,1);
line(xt,p0,'color','k')
%sum(p0.*log(p))

subplot(2,2,2)
% Mixture of two t_4
stream.Substream = 1;
n1=sum(rand(100,1)<3/4);
n2=100-n1;
x=[trnd(4,n1,1); 3+trnd(4,n2,1)/4];
xt=linspace(-6,6,400)';
logitgp(x,xt);
axis tight
title('Mixture of two t_4')
% true density
p0=t_pdf(xt,4,0,1)*2/3+t_pdf(xt,4,3,1/4)*1/3;
line(xt,p0,'color','k')

subplot(2,2,3)
% Galaxy data
x=load('demos/galaxy.txt');
xt=linspace(0,40000,200)';
logitgp(x,xt);
axis tight
title('Galaxy data')
% true density is unknown

subplot(2,2,4)
% Gamma(1,1)
stream.Substream = 1;
x=gamrnd(1,1,100,1);
xt=linspace(0,5,400)';
logitgp(x,xt);
axis tight
title('Gamma(1,1)')
p0=gam_pdf(xt,1,1);
line(xt,p0,'color','k')

% =====================================
% 1) 2D-examples
% =====================================

figure(2)
clf
subplot(2,2,1)
% t_4
n=100;
Sigma = [1 .7; .7 1];R = chol(Sigma);
stream.Substream = 1;
x=trnd(8,n,2)*R;
logitgp(x);
line(x(:,1),x(:,2),'LineStyle','none','Marker','.')
axis([-4 4 -4 4])
title('Student t_4')

subplot(2,2,2)
% Old faithful
x=load('demos/faithful.txt');
logitgp(x);
line(x(:,1),x(:,2),'LineStyle','none','Marker','.')
title('Old faithful')

subplot(2,2,3)
% Banana-shaped
n=100;
stream.Substream = 1;
b=0.02;x=randn(n,2);x(:,1)=x(:,1)*10;x(:,2)=x(:,2)+b*x(:,1).^2-10*b;
logitgp(x,'range',[-30 30 -5 20],'gridn',26);
line(x(:,1),x(:,2),'LineStyle','none','Marker','.')
axis([-25 25 -5 10])
title('Banana')

subplot(2,2,4)
% Ring
n=100;
stream.Substream = 1;
phi=(rand(n,1)-0.5)*2*pi;
x=[1.5*cos(phi)+randn(n,1)*0.2 1.5*sin(phi)+randn(n,1)*0.2];
logitgp(x,'gridn',30);
line(x(:,1),x(:,2),'LineStyle','none','Marker','.')
axis([-2.5 2.5 -2.5 2.5])
title('Ring')


% =====================================
% 1) 1D-example MCMC vs Laplace
% =====================================
figure(3)
subplot(2,1,1)
hold on
% t_4
stream.Substream = 1;
x=[trnd(4,1,100)]';
xt=linspace(-7,7,50)';
[p,pq]=logitgp(x,xt);
pla=p;
line(xt,p,'color','r','marker','none','linewidth',2)
line(xt,pq,'color','r','marker','none','linewidth',1,'linestyle','--')
xlim([-7 7])
title('t_4 (Laplace)')
% true density
p0=t_pdf(xt,4,0,1);
line(xt,p0,'color','k')

subplot(2,1,2)
[p,pq]=logitgp(x,xt,'latent_method','MCMC');
pmc=p;
line(xt,p,'color','r','marker','none','linewidth',2)
line(xt,pq,'color','r','marker','none','linewidth',1,'linestyle','--')
%xlim([-7 7])
title('t_4 (MCMC)')
line(xt,p0,'color','k')

[pks] = ksdensity(x,xt);

disp(['Laplace: ' num2str(sum(p0.*log(pla)))])
disp(['MCMC: ' num2str(sum(p0.*log(pmc)))])
disp(['ksdensity: ' num2str(sum(p0.*log(pks)))])

