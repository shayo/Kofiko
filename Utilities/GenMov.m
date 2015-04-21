A=fnReadImageList('D:\Data\Doris\Stimuli\Sinha_v2_FOB\Sinha_v2_FOB.txt');
P=randperm(length(A));
A=A(P);

aviobj = avifile('D:\Sin.avi');
[a2fX,a2fY] = meshgrid(1:400,1:400);

warning off
for k=1:length(A)
    try
    fprintf('%d\n',k);
    I=imread(A{k});
    iSizeOnScreen = 400;
    aiTextureSize = size(I);
    
    fScaleX = iSizeOnScreen / aiTextureSize(2);
    fScaleY = iSizeOnScreen / aiTextureSize(1);
    pt2fStimulusPos = [200 200];
    if fScaleX < fScaleY
        iStartX = max(1,pt2fStimulusPos(1) - floor(aiTextureSize(1) * fScaleX / 2));
        iEndX = max(1,pt2fStimulusPos(1) + floor(aiTextureSize(1) * fScaleX / 2));
        iStartY = max(1,pt2fStimulusPos(2) - floor(aiTextureSize(2) * fScaleX / 2));
        iEndY = max(1,pt2fStimulusPos(2) + floor(aiTextureSize(2) * fScaleX / 2));
    else
        iStartX = max(1,pt2fStimulusPos(1) - floor(aiTextureSize(1) * fScaleY / 2));
        iEndX = max(1,pt2fStimulusPos(1) + floor(aiTextureSize(1) * fScaleY / 2));
        iStartY = max(1,pt2fStimulusPos(2) - floor(aiTextureSize(2) * fScaleY / 2));
        iEndY = max(1,pt2fStimulusPos(2) + floor(aiTextureSize(2) * fScaleY / 2));
    end
    if iEndX-iStartX+1 > iEndY-iStartY+1
        J=imresize(I, [400,iEndY-iStartY+1]);
    else
        J=imresize(I, [iEndX-iStartX+1,400]);
    end
    
    Q = zeros(400,400,3,'uint8');
    if size(J,1) == 400
        C = round((400-size(J,2))/2);
        if C == 0
            Q = J;
        else
            Q(:,C:C+size(J,2)-1,:)=J;
        end
    else 
        C = round((400-size(J,1))/2);
        Q(C:C+size(J,1)-1,:,:)=J;
    end
    
    Q( (a2fX-200).^2+(a2fY-200).^2 <= 10) = 255;
    
     
    F.cdata(:,:,1) = Q;
    F.cdata(:,:,2) = Q;
    F.cdata(:,:,3) = Q;
    F.colormap = [];
    aviobj = addframe(aviobj,F);
    Q(:) = 128;
      
    Q( (a2fX-200).^2+(a2fY-200).^2 <= 10) = 255;
    F.cdata(:,:,1) = Q;
    F.cdata(:,:,2) = Q;
    F.cdata(:,:,3) = Q;
    F.colormap = [];
    aviobj = addframe(aviobj,F);
 
    catch
        fprintf('crashed on %d\n',k);
    end
end
aviobj = close(aviobj);    
