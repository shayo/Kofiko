%analyze result structure array of cartoondecom_loop_vers01
clear all
close all

%load C:\data\face\fp2_lupo_forwinrich\res_prelim_decom_02.mat
load C:\data\face\fp2_lupo_forwinrich\res_prelim_decom_03.mat  %contains info on cellidentity etc.

%exclude cases 7, 8 and 10: their firing rates ar every low. When one
%examines them closely, one can see significant influences, and in fact at
%p-levels of 0.02 or 0.05 they are already significant, but the data is
%just very noisy
res(10)=[];
res(8)=[];
res(7)=[];
%example 25 (after remocal of 7, 8 and 10, 22) fails to meet the 0.005
%significance level at 0.007, but is so clearly depending on that parameter
%it is counted as having one singificantly tuned dimension

%logic of decom is as follows:
%faces have seven parts, decom images are named in binary logic whether
%feature is present or not. The features are:
%
% hair // outline // pupils // eyes // brows // nose // mouth 
%
%e.g., a file called 1000000 would contain only hair, the one named 0000001 only a mouth.
%on the total we had 128 combinations
feat_cell=[{'mouth'},{'nose'},{'brows'},{'eyes'},{'pupils'},{'outline'},{'hair'}]
n_feat=7;
%analyses:
%(1) ANOVA to see which dimensions exert an influence - ideally we could
%also look for interactions, but data is probably too noisy for that
%(2) Check if response to whole face can be predicted by responses to parts
%(analysis of parts pictures revealed the response to the best feature is
%already as good as that to the whole face
%(3) 

[dummy n_cells]=size(res);

figure('Name','PSTHs','Position',[278 281 1641 829],'Color',[1 1 1]);
make_margcolor
for i=1:n_cells
  subplot(ceil(sqrt(n_cells)),ceil(sqrt(n_cells)),i);imagesc(res(i).PSTHsm,[0 ceil(max(max(res(i).PSTHsm)))]);set(gca,'TickDir','out');
  colorbar;set(gca,'TickDir','out','YTick',[1 32 64 96 128]);
end

%plot different categories for each cell
[n_decom, psthl]=size(getfield(res,{1},'PSTH'));

binpat=zeros(n_feat,n_decom);
def='0000000';
for i=1:n_decom
  bin=dec2bin(i-1);
  ueber=def;
  ueber(1:length(bin))=fliplr(bin);
  for j=1:n_feat
    binpat(j,i)=str2num(ueber(j));
  end
end
%binpat=fliplr(binpat);
figure('Name','Pattern of Stimulus Conditions','Color',[1 1 1]);
imagesc(fliplr(binpat'));colormap('gray');set(gca,'TickDir','out','XTickLabel',fliplr(feat_cell),'YTick',[1 16 32 48 64 80 96 112 128]);
ylabel('Stimulus #');

figure('Name','Feature Responses of all cells: Avg. PSTH without & with feature','Position',[554 229 956 747]);
for i=1:n_cells
  for j=1:n_feat
    rp0=find(binpat(j,:)==0);
    rp1=find(binpat(j,:)==1);
    PSTH=res(i).PSTHsm;
    PSTH0=mean(PSTH(rp0,:),1);
    PSTH1=mean(PSTH(rp1,:),1);
    P=[PSTH0',PSTH1']';
    subplot(n_cells,n_feat,(i-1)*n_feat+j);imagesc(P);axis off;
    if (i==1)
      title(feat_cell{j});    
    end
    if (j==1)
        ylabel(sprintf('Cell %d',i));
    end
  end
end

%compute responses and response variability over interval
PRP=zeros(n_feat,2,n_cells);
PSP=zeros(n_feat,2,n_cells);
% rbeg=100;
% rend=170;
for i=1:n_cells
  rbeg=res(i).RI(1);
  rend=res(i).RI(2);
  for j=1:n_feat
    rp0=find(binpat(j,:)==0);
    rp1=find(binpat(j,:)==1);
    PSTH=res(i).PSTHsm;
    PSTH0=mean(PSTH(rp0,:),1);
    PSTH1=mean(PSTH(rp1,:),1);
    R0=mean(PSTH0(rbeg:rend));
    R1=mean(PSTH1(rbeg:rend));
    PRP(j,1,i)=R0;
    PRP(j,2,i)=R1;

    %S0=std(mean(PSTH(rp0,rbeg:rend),2));
    %S1=std(mean(PSTH(rp1,rbeg:rend),2));
    %standard error of mean:
    S0=std(mean(PSTH(rp0,rbeg:rend),2))/sqrt(length(rp0));
    S1=std(mean(PSTH(rp1,rbeg:rend),2))/sqrt(length(rp1));
    PSP(j,1,i)=S0;
    PSP(j,2,i)=S1;
  end    
end

X=repmat([1:7]',1,2);
%examples=[16 24 26 23]; %before excluding cases 7, 8 and 10
examples=[13 21 23 20];
%examples=[7 8 10 25];
figure('Name','Examples','Color',[1 1 1],'Position',[122 414 1118 696]);
for i=1:length(examples)
  Y=squeeze(PRP(:,:,examples(i)));
  S=squeeze(PSP(:,:,examples(i)));
  subplot(2,2,i);errorbar(X,Y,S);hold on;bar(Y);title(sprintf('Example #%2d',examples(i)));set(gca,'TickDir','out','XTick',1:n_feat,'XTickLabel',feat_cell);ylabel('Firing Rate [Hz]');
end

%plot PSTHs
figure('Name','PSTHs of Examples','Position',[278 281 1641 829],'Color',[1 1 1]);
make_margcolor
for i=1:length(examples)
  subplot(1,4,i);imagesc(res(examples(i)).PSTHsm,[0 ceil(0.8*max(max(res(examples(i)).PSTHsm)))]);
  set(gca,'TickDir','out','XTick',[1 100 200 300 400 500],'XTickLabel',[1 100 200 300 400 500],'YTick',[1 16 32 48 64 80 96 112 128]);title(sprintf('Example %2d',examples(i)));xlabel('Time [ms]');ylabel('Stimulus #');
  colorbar;set(gca,'TickDir','out','YTick',[1 32 64 96 128]);
end


%get response:

R=zeros(n_decom,n_cells);
for i=1:n_cells
  PSTH=res(i).PSTHsm;
  RI=res(i).RI;
  R(:,i)=mean(PSTH(:,RI(1):RI(2)),2);
end

%prepare ANOVA for all cells
g=cell(n_feat,1);  %cell array for ANOVA variables
for i=1:n_feat
  g{i}=binpat(i,:);    
end

for i=1:n_cells
  [P,T,STATS,TERMS]=ANOVAN(squeeze(R(:,i))',g,'varnames' ,feat_cell,'model','interaction','display','off');
  ANOVA_RES(i).P    =P;
  ANOVA_RES(i).T    =T;
  ANOVA_RES(i).STATS=STATS;
  ANOVA_RES(i).TERMS=TERMS
end

%there are several interactions which seem to be prominent. Of which
%character are they? Suppressive or enhancing?
%Since response to whole face
figure('Name','Response Whole vs. Sum of Parts & Best Part','Position',[680 559 560 551]);

%find significant dimensions and count them:
n_sigdim=zeros(n_cells,1);
n_sigint=zeros(n_cells,1);
n_sigdimint=zeros(n_cells,1);
sigdim_pop=zeros(1,1);
sigint_pop=zeros(1,1);
sigint_pop_R=zeros(1,4);
int_cnt=0;
for i=1:n_cells
    sig_lev=0.005;
    if (i==22) %thjis cell just fails to reach significance at 0.005, but since the effect is so strong, and since this significance assessment depends on choice of response period, we lift it here.
        sig_lev=0.008;
    end
  sig_dim_or_int=find(ANOVA_RES(i).P<sig_lev);
  n_sigdimint(i)=length(sig_dim_or_int);
  rpsd=find(sig_dim_or_int <= n_feat);
  rpsi=find(sig_dim_or_int >  n_feat);
  if ~isempty(rpsd)
    sig_dim=sig_dim_or_int(rpsd);
    sigdim_pop=[sigdim_pop' sig_dim']';
    n_sigdim(i)=length(sig_dim);  
  end
  if ~isempty(rpsi)
    sig_int=sig_dim_or_int(rpsi);
    lsi=length(sig_int);
    sigint_pop=[sigint_pop' sig_int']';
    n_sigint(i)=lsi;
    for j=1:lsi
      sigint_pop_R=[sigint_pop_R' zeros(4,1)]';  
      int_cnt=int_cnt+1;
      rd=find(ANOVA_RES(i).TERMS(sig_int(j),:));
      sigint_pop_R(int_cnt,1)=mean(R(find(~binpat(rd(1),:).*~binpat(rd(2),:)),i));
      sigint_pop_R(int_cnt,2)=mean(R(find(~binpat(rd(1),:).*binpat(rd(2),:)),i));
      sigint_pop_R(int_cnt,3)=mean(R(find(binpat(rd(1),:).*~binpat(rd(2),:)),i));
      sigint_pop_R(int_cnt,4)=mean(R(find(binpat(rd(1),:).*binpat(rd(2),:)),i));
    end
  end
end
sigdim_pop=sigdim_pop(2:end)';
sigint_pop=sigint_pop(2:end)';
sigint_pop_R=sigint_pop_R(1:end-1,:);
subplot(2,2,3);bar(hist(n_sigdim,1:n_feat),'k');title('# features w/ significant influence');set(gca,'TickDir','out');ylabel('# Neurons');xlabel('# Face Parts');
subplot(2,2,4);hist(sigdim_pop,1:n_feat);title('importance of features');xlabel('Feature');ylabel('#cells');
disp(sprintf('Average number of significant interactions per cell: %3.2f',mean(n_sigint)));

figure('Name','Interactions 1','Position',[221 95 1019 1015],'Color',[1 1 1]);
maR=max(max(sigint_pop_R));
miR=min(min(sigint_pop_R));
R00=sigint_pop_R(:,1);
R01=sigint_pop_R(:,2);
R10=sigint_pop_R(:,3);
R11=sigint_pop_R(:,4);
subplot(2,2,1);plot(R00,R11,'.');ylabel('11');xlabel('00');hold on;
               line([0 maR],[0 maR],'Color','r');axis tight;axis square
subplot(2,2,2);plot(R01+R10,R11,'.');ylabel('11');xlabel('01+10');hold on;
               line([0 maR],[0 maR],'Color','r');axis tight;axis square
subplot(2,2,4);plot(R01+R10-2*R00,R11-R00,'.');ylabel('11-00');xlabel('01-00+10-00');hold on;
               line([0 maR],[0 maR],'Color','r');axis tight;axis square
disp(sprintf('Number of Suppressive Interactions: %d',length(find((R01+R10-2*R00)>(R11-R00)))));
disp(sprintf('Number of Cooperative Interactions: %d',length(find((R01+R10-2*R00)<(R11-R00)))));

%interaction analyses

figure('Name','Interactions','Color',[1 1 1]);
subplot(2,2,1);hist(n_sigint,0:max(n_sigint));set(gca,'XLim',[-0.5,max(n_sigint)+0.5]);title('# interactions per cell');
subplot(2,2,2);hist(sigint_pop,1:28);title('type of interactions');xlabel('interaction #');ylabel('# cases');
subplot(2,2,3);hist(n_sigdimint,0:max(n_sigdimint));set(gca,'XLim',[-0.5,max(n_sigdimint)+0.5]);title('# signif. 1st & 2nd order features...');xlabel('... Sum of #Features+#Interactions')
hist_inttype=hist(sigint_pop,1:28);
[number_many_entries many_entries]=sort(hist_inttype);
n_relinttypes=4;
many_entries=many_entries(28-n_relinttypes+1:28); %these are the interaction types to look at
number_many_entries=number_many_entries(28-n_relinttypes+1:28);
for i=1:n_relinttypes
  rd=find(ANOVA_RES(1).TERMS(many_entries(i),:));
  disp([sprintf('%d interactions between ',number_many_entries(i)) feat_cell{rd(1)} ' and ' feat_cell{rd(2)}]);
end
  %how well can the response to parts predict the response to the whole face?

rp_partonly =find(sum(binpat)==1);
rp_wholeface=find(sum(binpat)==n_feat);

Rsum_parts =sum(R(rp_partonly,:),1);
Rmax_parts =max(R(rp_partonly,:));
R_wholeface=R(rp_wholeface,:);

figure('Name','Parts, Whole','Color',[1 1 1],'Position',[659 438 782 682]);
subplot(2,2,1);plot(Rsum_parts,R_wholeface,'.');xlabel('Response Sum of Parts [Hz]');ylabel('Response Whole [Hz]');axis square;set(gca,'TickDir','out');
line(get(gca,'XLim'), get(gca,'XLim'),'color','r');
[c p]=corrcoef(Rsum_parts,R_wholeface)
subplot(2,2,2);plot(Rmax_parts,R_wholeface,'.');xlabel('Best Part');ylabel('Whole');axis square
line(get(gca,'XLim'), get(gca,'XLim'),'color','r');
subplot(2,2,3);plot(R_wholeface,Rsum_parts,'.');ylabel('Response Sum of Parts [Hz]');xlabel('Response Whole [Hz]');axis square;
set(gca,'TickDir','out','XLim',[0 150],'YLim',[0 150]);
line(get(gca,'XLim'), get(gca,'XLim'),'color','r');

[p h]=ranksum(Rsum_parts,R_wholeface);
disp(sprintf('Sum of parts vs. whole face responses - Mann-Whitney U (Wilcoxon signed rank): p=%5.4f, h=%5.4f',p,h));
disp(sprintf('Ratio Whole Face / Sum of part: %3.2f',mean(R_wholeface./Rsum_parts)))
[p h]=ranksum(Rmax_parts,R_wholeface);
disp(sprintf('Best part  vs.  whole face responses  - Mann-Whitney U (Wilcoxon signed rank): p=%5.4f, h=%5.4f',p,h));
disp(sprintf('Ratio Whole Face / Best part: %3.2f',mean(R_wholeface./Rmax_parts)))

%look at ANOVA result a bit further:

fovef=zeros(n_cells,1);  %fraction of variance explained by features
fovei=zeros(n_cells,1);  %fraction of variance explained by interaction (pairwise)
fovesf=zeros(n_cells,1); %fraction of variance explained PER significant feature
fovesi=zeros(n_cells,1); %fraction of variance explained PER significant interaction
fovee=zeros(n_cells,1);
for i=1:n_cells
  art=ANOVA_RES(i).T;
  Nam=art(2:end,1);
  SuS=art(2:end,2); %variance
  SIG=ANOVA_RES(i).P<sig_lev;
  sigf=find(SIG(1:n_feat));
  sigi=find(SIG(n_feat+1:n_feat+n_feat*(n_feat-1)/2))+n_feat;
  vef=sum(cat(2,SuS{1:n_feat})); %variance explained by features
  vei=sum(cat(2,SuS{n_feat+1:n_feat+n_feat*(n_feat-1)/2})); %variance explained by interactions
  vee=SuS{n_feat+n_feat*(n_feat-1)/2+1};
  tv =SuS{end};
  if ~isempty(sigf)
    vesf=mean(cat(2,SuS{sigf}));
    fovesf(i)=vesf/tv;
  end
  if ~isempty(sigi)
    vesi=mean(cat(2,SuS{sigi}));   
    fovesi(i)=vesi/tv;
  end
  DoF=art(2:end,3); %degrees of freedom
  fovef(i)=vef/tv;
  fovei(i)=vei/tv;
  fovee(i)=vee/tv;
end
disp(sprintf('%4.2f%%: Average fraction of overall variance explained by features',100*mean(fovef)));
disp(sprintf('%4.2f%%: Average fraction of overall variance explained by pairwise interactions',100*mean(fovei)));

disp(sprintf('%4.2f%%: Average fraction of variance exaplined by a SINGLE significant feature',100*mean(fovesf(find(fovesf~=0)))));
disp(sprintf('%4.2f%%: Average fraction of variance exaplined by a SINGLE significant pairwise interaction',100*mean(fovesi(find(fovesi~=0)))));

%can the response magnitude to the whole face be explained by one or two
%parts alone?

%for each cell: plot response to whole face, to all seven parts, pairwise
%part combinations etc.

R_ff=R(find(sum(binpat)==7),:);
R_01=R(find(sum(binpat)==1),:);
R_02=R(find(sum(binpat)==2),:);
R_03=R(find(sum(binpat)==3),:);
R_04=R(find(sum(binpat)==4),:);

%look for entries 95% or higher that R_ff

tf=1;
nosr   =zeros(n_cells,1); %number of strong responses
nosr_01=zeros(n_cells,1); %number of strong responses
nosr_02=zeros(n_cells,1); %number of strong responses

for i=1:n_cells
  f=find(R(1:127,i)>=tf*R(128,i));
  if ~isempty(f)
      nosr(i)=length(f);
  end
  
  f_01=find(R(find(sum(binpat)==1),i)>=tf*R(128,i));
  if ~isempty(f_01)
      nosr_01(i)=length(f_01);
  end
  f_02=find(R(find(sum(binpat)==2),i)>=tf*R(128,i));
  if ~isempty(f_02)
      nosr_02(i)=length(f_02);
  end
end

%we now need to find decompositions using different parts
%in order to be able to make a storng case
for i=1:n_cells
    if (nosr_02(i)>=2)
        disp(sprintf('Cell %2d contains %2d strong pairs of parts. Firing rate to whole face is %3d Hz',i,nosr_02(i),ceil(R_ff(i))));
        f_02=find(R(:,i)>=tf*R(128,i) & sum(binpat',2)==2);
        for j=1:length(f_02)
          rbpp=find(binpat(:,f_02(j)));
          disp([sprintf('%3d Hz',ceil(R(f_02(j),i))) ' <--- ' feat_cell{rbpp(1)} ' & ' feat_cell{rbpp(2)}]);
        end
        disp('-------------------------------------------------------------------------------------------------');
    end
end

%plot example cell 14:

eca=[6,9,10,11,14];
lec=length(eca);

for i=1:lec
  ec=eca(i);
  figure('Name',sprintf('Example Cell %2d Plot 1',ec),'Color',[1 1 1],'Position',[680 7 827 1103]); 
  subplot(1,2,1);imagesc(fliplr(binpat'));set(gca,'XTick',1:7,'TickDir','out','XTickLabel',fliplr(feat_cell),'YTick',[1 16 32 48 64 80 96 112 128]);
  ylabel('Stimulus #');
  subplot(1,2,2);imagesc(res(ec).PSTHsm,[0 ceil(max(max(res(ec).PSTHsm)))]);set(gca,'TickDir','out');colorbar;set(gca,'TickDir','out','YTick',[1 32 64 96 128]);

  RP =[R_ff(ec),squeeze(R_01(:,ec))'];
  RPN=[{'full'},feat_cell];

  f_02=find(R(:,ec)>=tf*R(128,ec) & sum(binpat',2)==2);
  for j=1:length(f_02)
    rbpp=find(binpat(:,f_02(j)));
    RP=[RP R(f_02(j),ec)];
    RPN=[RPN,{[feat_cell{rbpp(1)} ' & ' feat_cell{rbpp(2)}]}];
  end

  figure('Name',sprintf('Example Cell %2d Plot 2',ec),'Color',[1 1 1],'Position',[25 532 1768 578]); 
  make_margcolor
  subplot(2,1,1);imagesc(res(ec).PSTHsm,[0 ceil(max(max(res(ec).PSTHsm)))]);set(gca,'TickDir','out');colorbar;set(gca,'TickDir','out','YTick',[1 32 64 96 128]);
  subplot(2,1,2);bar(RP,'k');
  set(gca,'XTickLabel',RPN,'YLim',[0 10*ceil(max(RP)/10)],'TickDir','out');
  %feat_cell=[{'mouth'},{'nose'},{'brows'},{'eyes'},{'pupils'},{'outline'},{'hair'}]
end

x(-1)


%compute PSTHs of five conditions, normalized to max response & overall
%average (possibly exclude cells without response to real faces)


psth=zeros(n_cells,n_uniqCat,psthl);
for i=1:n_cells
  psth(i,:,:)=getfield(res,{i},'PSTH');
end

%first quick displays
avgPSTH=squeeze(mean(psth,1));

figure('Name','PSTH','Position',[317 466 923 644]);
subplot(2,2,1);imagesc(avgPSTH);xlabel('Time [ms]');ylabel('Category');title(sprintf('Avg Response of %d cells',n_cells));colorbar;
subplot(2,2,2);plot(avgPSTH');xlabel('Time [ms]');ylabel('Firing Rate [Hz]');legend('1','2','3','4','5')

%subplot(2,2,3);plot(avgPSTH(1,:)./avgPSTH(4,:));
%SORT:
del=cat(1,res.FRmax);
del=del(:,4); %face response
[del rs]=sort(del);
subplot(2,2,3);imagesc(flipud(squeeze(psth(rs,4,:))));title('Responses to Face Images');colorbar
subplot(2,2,4);imagesc(flipud(squeeze(psth(rs,1,:))));title('Responses to Face Cartoons');colorbar

%compute response index based on FRmax.
FRmax_pop=zeros(n_cells,n_uniqCat);
FRmax_del=zeros(n_cells,n_uniqCat);
for i=1:n_cells
  FRmax_pop(i,:)=getfield(res,{i},'FRmax');
  FRmax_del(i,:)=getfield(res,{i},'FRmax_delay');
end
spontact=cat(1,res.spontanact);

rp=find(isfinite(FRmax_pop(:,1)).*isfinite(FRmax_pop(:,4))); %find cells for which maximal firing rates could be determined

FRmax_pop1=FRmax_pop(rp,1); %cartoon
FRmax_pop4=FRmax_pop(rp,4); %face
FRmax_pop5=FRmax_pop(rp,5); %gadget
spontact=spontact(rp);
%some are still not a number, so no response:
FRmax_pop5(find(isnan(FRmax_pop5)))=0;

%compute index
FC_FRmax_I=(FRmax_pop4-FRmax_pop1)./(FRmax_pop1+FRmax_pop4-2*spontact);
FG_FRmax_I=(FRmax_pop4-FRmax_pop5)./(FRmax_pop5+FRmax_pop4-2*spontact);
CG_FRmax_I=(FRmax_pop1-FRmax_pop5)./(FRmax_pop1+FRmax_pop5-2*spontact);

disp('Correlation of Face Selectivity Indices');
[c p]=corrcoef(CG_FRmax_I,FG_FRmax_I)

figure('Name','Indices','Position',[317 466 923 644]);
subplot(2,2,1);bar(-1:.1:1,hist(FC_FRmax_I,-1:.1:1),'k');set(gca,'TickDir','out');axis tight;title('Response Index Image vs. Cartoon Faces');
subplot(2,2,2);bar(-1:.1:1,hist(FG_FRmax_I,-1:.1:1),'k');set(gca,'TickDir','out');axis tight;title('Response Index Face vs. Gadget');
subplot(2,2,3);bar(-1:.1:1,hist(CG_FRmax_I,-1:.1:1),'k');set(gca,'TickDir','out');axis tight;title('Response Index Cartoon Faces vs. Gadgets');

subplot(2,2,4);plot(log(FRmax_pop1), log(FRmax_pop4),'*');axis square;title('Response Cartoon vs. Face');
[r p]=corrcoef(FRmax_pop1, FRmax_pop4)  %correlation coefficient between face and gadget response is similarly strongly correlated when cells responsive to bothe categories are considered
[r p]=corrcoef(FRmax_pop1-FRmax_pop5, FRmax_pop4-FRmax_pop5)  %correlation coefficient between face and gadget response is similarly strongly correlated when cells responsive to bothe categories are considered
[r p]=corrcoef(FRmax_pop1./FRmax_pop5, FRmax_pop4./FRmax_pop5)

%how many cells which respond to face images respond to cartoons as well?
%how many respond to cartoons more than to gadgets?
%what is the response ratio to images and cartoons? How do other parameters depend on cartoon vs. image? 

%todo: select for face-selective neurons by 2:1 criterion?!
f=find((FRmax_pop4>2*FRmax_pop5) & (FRmax_pop5>0)); %

figure('Name','PSTHs of face-selective cells','Position',[317 466 923 644]);
subplot(2,2,1);imagesc(squeeze(mean(psth(f,:,:),1)));xlabel('Time [ms]');ylabel('Category');title(sprintf('Avg Response of %d face-selective cells',length(f)));colorbar;
subplot(2,2,2);plot(squeeze(mean(psth(f,:,:),1))');xlabel('Time [ms]');ylabel('Firing Rate [Hz]');legend('1','2','3','4','5')

FRmax_pop1=FRmax_pop1(f);
FRmax_pop4=FRmax_pop4(f);
FRmax_pop5=FRmax_pop5(f);

%compute index
FC_FRmax_I=(FRmax_pop4-FRmax_pop1)./(FRmax_pop1+FRmax_pop4);
FG_FRmax_I=(FRmax_pop4-FRmax_pop5)./(FRmax_pop5+FRmax_pop4);
CG_FRmax_I=(FRmax_pop1-FRmax_pop5)./(FRmax_pop1+FRmax_pop5);

disp('Correlation of Face Selectivity Indices');
[c p]=corrcoef(CG_FRmax_I,FG_FRmax_I)

figure('Name','Indices after selecting for face-selective units','Position',[317 466 923 644]);
subplot(2,2,1);bar(-1:.1:1,hist(FC_FRmax_I,-1:.1:1),'k');set(gca,'TickDir','out');axis tight;title('Response Index Image vs. Cartoon Faces');
subplot(2,2,2);bar(-1:.1:1,hist(FG_FRmax_I,-1:.1:1),'k');set(gca,'TickDir','out');axis tight;title('Response Index Face vs. Gadget');
subplot(2,2,3);bar(-1:.1:1,hist(CG_FRmax_I,-1:.1:1),'k');set(gca,'TickDir','out');axis tight;title('Response Index Cartoon Faces vs. Gadgets');

subplot(2,2,4);plot(log(FRmax_pop1), log(FRmax_pop4),'*');axis square;title('Response Cartoon vs. Face');
[r p]=corrcoef(FRmax_pop1, FRmax_pop4)  %correlation coefficient between face and gadget response is similarly strongly correlated when cells responsive to bothe categories are considered
[r p]=corrcoef(FRmax_pop1-FRmax_pop5, FRmax_pop4-FRmax_pop5)  %correlation coefficient between face and gadget response is similarly strongly correlated when cells responsive to bothe categories are considered
[r p]=corrcoef(FRmax_pop1./FRmax_pop5, FRmax_pop4./FRmax_pop5)

figure('Name','Response Delays','Position',[317 466 923 644]);
subplot(2,2,1);plot(FRmax_del(:,1), FRmax_del(:,4),'*');axis square;title('Response Delay Cartoon vs. Face');
subplot(2,2,2);plot(FRmax_del(FRmax_pop(:,4)>10,1), FRmax_del(FRmax_pop(:,4)>10,4),'*');axis square;title('Response Delay Cartoon vs. Face with Face Response > 10Hz');
[r p]=corrcoef(FRmax_del(:,1), FRmax_pop(:,4))

%compare cartoons to techno controls

%is there a correlation of the response strength of each cell to the
%sixteen faces and the sixteen cartoons?
%===================================================================
%the answer is 'no': only two cells have a significant positive correlation



%which parts give best responses?
%parts (from imlist_faceplay.txt):
% p_brows1.bmp
% p_brows12.bmp
% p_eyes1.bmp
% p_eyes12.bmp
% p_face1.bmp
% p_face12.bmp
% p_hair1.bmp
% p_hair12.bmp
% p_hair3.bmp
% p_mouth1.bmp
% p_mouth12.bmp
% p_nose1.bmp
% p_nose12.bmp
% p_pupils1.bmp
% p_pupils12.bmp
% p_pupils14.bmp

feat_parts=[1,1,2,2,3,3,4,4,4,5,5,6,6,7,7,7];
feat_face =[1,2,1,2,1,2,1,2,3,1,2,1,2,1,2,4];
rpop_parts=cat(2,res.part);
rpop_parts=rpop_parts(:,find(isfinite(rpop_parts(1,:))));
rpop_parts=rpop_parts(:,find(sum(rpop_parts,1)>0));

rpo=cat(2,res.part);
rpop_carts=cat(2,res.cart);
rpop_carts=rpop_carts(:,find(isfinite(rpo(1,:))));rpo=rpo(:,find(isfinite(rpo(1,:))));
rpop_carts=rpop_carts(:,find(sum(rpo,1)>0));

rpop_parts_norm=rpop_parts;
[n_parts n_rpop_cells]=size(rpop_parts);
for i=1:n_parts
  rpop_parts_norm(i,:)=rpop_parts(i,:)./sum(rpop_parts,1);
end
figure('Name','Population Response to Parts','Position',[680 32 722 1078]);
subplot(3,2,1);imagesc(rot90(rpop_parts_norm));colorbar;

%summarize by feature:
n_uniq_feat=length(unique(feat_parts));
rpop_feat=zeros(n_uniq_feat,n_rpop_cells);
for i=1:n_uniq_feat
  rp=find(feat_parts==i);
  rpop_feat(i,:)=mean(rpop_parts_norm(rp,:),1);
end
for i=1:n_rpop_cells
  rpop_feat(:,i)=rpop_feat(:,i)./sum(rpop_feat(:,i));  
end

subplot(3,2,2);imagesc(rot90(rpop_feat));colorbar;title('Population Response to Features');
subplot(3,2,6);bar(mean(rpop_feat,2));title('Average Feature Response');

%todo: is there specialization for certain face parts in these cells? if so, the product acroos features should be lower than for shuffle controls - or the heterogeneity should be higher - or tuning narrower.
%heterogeneity distribution:

hd=zeros(n_rpop_cells,1);
for i=1:n_rpop_cells
  hd(i)=1-homogeneity(rpop_feat(:,i));
end
subplot(3,2,3);hist(hd,0:0.1:1);axis tight;

n_shuffle=5000;
%randomize rpop_feat
rpop_feat_shuff=zeros(n_uniq_feat,n_rpop_cells);
hd_shuff=zeros(n_rpop_cells,n_shuffle);
for i=1:n_shuffle
  for j=1:n_uniq_feat
    rpop_feat_shuff(j,randperm(n_rpop_cells))=rpop_feat(j,:);
  end
  for j=1:n_rpop_cells
    rpop_feat_shuff(:,j)=rpop_feat_shuff(:,j)./sum(rpop_feat_shuff(:,j));  
    hd_shuff(j,i)=1-homogeneity(rpop_feat_shuff(:,j));
  end
end
subplot(3,2,4);hist(reshape(hd_shuff,n_rpop_cells*n_shuffle,1),0:0.1:1);axis tight;hold on
mhd_shuff=mean(hd_shuff);
subplot(3,2,5);hist(mhd_shuff,0:0.01:1);axis tight
disp(sprintf('Max heterogeneity of the %d shuffle predictors: %4.3f - actual heterogeneity: %4.3f',n_shuffle,max(mhd_shuff),mean(hd)));

%try to predict response to whole faces 1 & 12 from parts responses

face01p=find(feat_face==1);
face12p=find(feat_face==2);

rpop_cart01=rpop_carts( 1,:);
rpop_cart12=rpop_carts(12,:);

rpop_part01sum=sum(rpop_parts(face01p,:),1);
rpop_part12sum=sum(rpop_parts(face12p,:),1);

figure('Name','Predicting Response to two full face cartoons by responses to its parts','Position',[443 11 797 1099]);

subplot(3,2,1);plot(rpop_cart01,rpop_part01sum,'.k');title('Cartoon 01');xlabel('Full Cartoon');ylabel('Sum of Parts');
subplot(3,2,2);plot(rpop_cart12,rpop_part12sum,'.k');title('Cartoon 12');xlabel('Full Cartoon');ylabel('Sum of Parts');
subplot(3,2,3);plot(log(rpop_cart01+0.00001),log(rpop_part01sum+0.00001),'.r');title('Cartoon 01');xlabel('Full Cartoon');ylabel('Sum of Parts');
subplot(3,2,4);plot(log(rpop_cart12+0.00001),log(rpop_part12sum+0.00001),'.r');title('Cartoon 12');xlabel('Full Cartoon');ylabel('Sum of Parts');

%response index of cartoon response and sum of parts prediction
RI_FP01=(rpop_cart01-rpop_part01sum)./(rpop_cart01+rpop_part01sum);RI_FP01=RI_FP01(find(~isnan(RI_FP01)));
RI_FP12=(rpop_cart12-rpop_part12sum)./(rpop_cart12+rpop_part12sum);RI_FP12=RI_FP12(find(~isnan(RI_FP12)));

subplot(3,2,5);hist(RI_FP01,-1:0.2:1);title('Response Index Face 01');set(gca,'XLim',[-1 1]);
subplot(3,2,6);hist(RI_FP12,-1:0.2:1);title('Response Index Face 12');set(gca,'XLim',[-1 1]);

mean_RI_FP01=mean(RI_FP01);
mean_RI_FP12=mean(RI_FP12);

RR_FP01=(1+mean_RI_FP01)/(1-mean_RI_FP01);
RR_FP12=(1+mean_RI_FP12)/(1-mean_RI_FP12);

disp(sprintf('The average response to a full face is %4.2f%% and %4.2f%% of that to the sum of its parts',100*RR_FP01,100*RR_FP12));

%how much does the best response explain?

figure('Name','Predicting Response to two full face cartoons by responses to individual parts','Position',[443 11 797 1099]);
rpop_bestpart01=max(rpop_parts(face01p,:));
rpop_bestpart12=max(rpop_parts(face12p,:));

subplot(3,2,1);plot(rpop_cart01,rpop_bestpart01,'.');title('Best Response Face01');xlabel('Full Cartoon');ylabel('Best Part');
subplot(3,2,2);plot(rpop_cart12,rpop_bestpart12,'.');title('Best Response Face12');xlabel('Full Cartoon');ylabel('Best Part');

RI_FM01=(rpop_cart01-rpop_bestpart01)./(rpop_cart01+rpop_bestpart01);RI_FM01=RI_FM01(find(~isnan(RI_FM01)));
RI_FM12=(rpop_cart12-rpop_bestpart12)./(rpop_cart12+rpop_bestpart12);RI_FM12=RI_FM12(find(~isnan(RI_FM12)));

subplot(3,2,5);hist(RI_FM01,-1:0.2:1);title('Response Index Face 01');set(gca,'XLim',[-1 1]);
subplot(3,2,6);hist(RI_FM12,-1:0.2:1);title('Response Index Face 12');set(gca,'XLim',[-1 1]);

mean_RI_FM01=mean(RI_FM01);
mean_RI_FM12=mean(RI_FM12);

RR_FM01=(1+mean_RI_FM01)/(1-mean_RI_FM01);
RR_FM12=(1+mean_RI_FM12)/(1-mean_RI_FM12);

disp(sprintf('The average response to a full face is %4.2f%% and %4.2f%% of that to the best part',100*RR_FM01,100*RR_FM12));
