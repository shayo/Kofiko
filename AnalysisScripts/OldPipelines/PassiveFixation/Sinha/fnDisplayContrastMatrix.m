function fnDisplayContrastMatrix(a3fContrast,afRange)
if exist('afRange','var')
    for k=1:55
        subplot(7,8,k);
        imagesc(a3fContrast(:,:,k),afRange);
        set(gca,'xtick',[],'ytick',[]);
%         title(num2str(k));
    end
    
    
else
    
    for k=1:55
        subplot(7,8,k);
        imagesc(a3fContrast(:,:,k) );
        set(gca,'xtick',[],'ytick',[]);
    end
    
end