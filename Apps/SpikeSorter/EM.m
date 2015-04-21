function [Mu, Sigma,Priors] = EM(Data, Mu0, Sigma0,Priors0,loglik_threshold)
[D, N] = size(Data);
K = size(Sigma0,3);
loglik_old = -realmax;

Mu = Mu0;
Sigma = Sigma0;
Priors = Priors0;

GammaZnk = zeros(N,K);
while 1
    % E Step
    for k=1:K
        GammaZnk(:,k) = Priors(k) * fnGaussPDF(Data, Mu(:,k), Sigma(:,:,k));
    end
    % Stop
    F = sum(GammaZnk,2);
    F(F<realmin) = realmin;
    loglik = mean(log(F));
    if abs((loglik/loglik_old)-1) < loglik_threshold
        break;
    end
    loglik_old = loglik;
    
    GammaZnk = GammaZnk ./ (realmin+repmat(sum(GammaZnk,2),1,K));
    Nk = sum(GammaZnk);
    % M Step
    Priors = Nk / N;
    for k=1:K
        Mu(:,k) = Data*GammaZnk(:,k) / Nk(k);
        DataShifted =  Data - repmat(Mu(:,k), 1,N);
        Sigma(:,:,k) = 1/Nk(k) *  sum(DataShifted .* DataShifted .* GammaZnk(:,k)') + 1E-5.*diag(ones(D,1));
%         Data_tmp1 = Data - repmat(Mu(:,k),1,N);
%         Data_tmp2a = repmat(reshape(Data_tmp1,[D 1 N]), [1 D 1]);
%         Data_tmp2b = repmat(reshape(Data_tmp1,[1 D N]), [D 1 1]);
%         Data_tmp2c = repmat(reshape(GammaZnk(:,k),[1 1 N]), [D D 1]);
%         Sigma(:,:,k) = sum(Data_tmp2a.*Data_tmp2b.*Data_tmp2c, 3) / Nk(k) + 1E-5.*diag(ones(D,1));
    end
end
