function X=my_pca(X, initial_dims)
% Normalize input data
X = X - min(X(:));
X = X / max(X(:));
X = bsxfun(@minus, X, mean(X, 1));

% Perform preprocessing using PCA
disp('Preprocessing data using PCA...');
if size(X, 2) < size(X, 1)
    C = X' * X;
else
    C = (1 / size(X, 1)) * (X * X');
end
[M, lambda] = eig(C);
[lambda, ind] = sort(diag(lambda), 'descend');
M = M(:,ind(1:initial_dims));
lambda = lambda(1:initial_dims);
if ~(size(X, 2) < size(X, 1))
    M = bsxfun(@times, X' * M, (1 ./ sqrt(size(X, 1) .* lambda))');
end
X = bsxfun(@minus, X, mean(X, 1)) * M;

