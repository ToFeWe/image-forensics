function [F1Map,CFADetected, F1] = CFATamperDetection_F1(im)
    
    StdThresh=5;
    Depth=3;
    
    im=double(im(1:round(floor(end/(2^Depth))*(2^Depth)),1:round(floor(end/(2^Depth))*(2^Depth)),:));
    
    SmallCFAList={[2 1;3 2] [2 3;1 2] [3 2;2 1] [1 2;2 3]};
    LargeCFAList={ [1 2;2 3] [3 2;2 1] [2 1;3 2]  [2 3;1 2] [1 2; 3 1] [1 3;2 1] [2 1;1 3] [3 1;1 2] [3 1;2 3] [3 2;1 3] [1  3;3 2] [2 3;3 1]                  [1 2;1 3] [1 3;1 2] [1 1;2 3] [1 1;3 2] [2 1;3 1] [3 1;2 1] [2 3;1 1] [3 2;1 1] [3 1;3 2] [3 2;3 1] [3 3;1 2] [3 3;2 1] [1 3;2 3] [2 3;1 3] [1 2;3 3] [2 1;3 3]                                                   [2 1;2 3] [2 3;2 1] [2 2;1 3] [2 2;3 1]  [1 2;3 2] [3 2;1 2] [1 3;2 2] [3 1;2 2]};
    
    CFAList=SmallCFAList;
    
    %block size
    W1=16;
    
    if size(im,1)<W1 || size(im,2)<W1
        F1Map=zeros([size(im,1), size(im,2)]);
        CFADetected=[0 0 0 0];
        return
    end

    MeanError=inf(length(CFAList),1);
    for TestArray=1:length(CFAList)
        
        BinFilter=[];
        ProcIm=[];
        CFA=CFAList{TestArray};
        R=CFA==1;
        G=CFA==2;
        B=CFA==3;
        BinFilter(:,:,1)=repmat(R,size(im,1)/2,size(im,2)/2);
        BinFilter(:,:,2)=repmat(G,size(im,1)/2,size(im,2)/2);
        BinFilter(:,:,3)=repmat(B,size(im,1)/2,size(im,2)/2);
        CFAIm=double(im).*BinFilter;
        BilinIm=bilinInterp(CFAIm,BinFilter,CFA);
        
        
        ProcIm(:,:,1:3)=im;
        ProcIm(:,:,4:6)=double(BilinIm);
        
        %ProcIm(:,:,4:6)=(im-double(BilinIm)).^2;
        
        ProcIm=double(ProcIm);
        BlockResult=blockproc(ProcIm,[W1 W1],@eval_block);
        
        Stds=BlockResult(:,:,4:6);
        BlockDiffs=BlockResult(:,:,1:3);
        NonSmooth=Stds>StdThresh;

        
        MeanError(TestArray)=mean(mean(mean(BlockDiffs(NonSmooth))));
        BlockDiffs=BlockDiffs./repmat(sum(BlockDiffs,3),[1 1 3]);
        
        %imagesc(BlockDiffs);
        %pause;
        
        Diffs(TestArray,:)=reshape(BlockDiffs(:,:,2),1,numel(BlockDiffs(:,:,2)));
        
        F1Maps{TestArray}=BlockDiffs(:,:,2);

    end
    
    Diffs(isnan(Diffs))=0;
    
    [~,val]=min(MeanError);
    U=sum(abs(Diffs-0.25),1);
    F1=median(U);
    CFADetected=CFAList{val}==2;
    F1Map=F1Maps{val};
    
end

function [ Out ] = eval_block( block_struc )
    %EVAL_BLOCK Summary of this function goes here
    %   Detailed explanation goes here
    im=block_struc.data;
    %Out(:,:,1:3)=mean(mean((double(block_struc.data(:,:,1:3))-double(block_struc.data(:,:,4:6))).^2));
    Out(:,:,1)=mean2((double(block_struc.data(:,:,1))-double(block_struc.data(:,:,4))).^2);
    Out(:,:,2)=mean2((double(block_struc.data(:,:,2))-double(block_struc.data(:,:,5))).^2);
    Out(:,:,3)=mean2((double(block_struc.data(:,:,3))-double(block_struc.data(:,:,6))).^2);
    
    Out(:,:,4)=std(reshape(im(:,:,1),1,numel(im(:,:,1))));
    Out(:,:,5)=std(reshape(im(:,:,2),1,numel(im(:,:,2))));
    Out(:,:,6)=std(reshape(im(:,:,3),1,numel(im(:,:,3))));
end