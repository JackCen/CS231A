numPos = 2000;
numNeg = 2000;
numTotal = numPos + numNeg;
numFeature = 34200;
numGroupFeature = 5000;
numGroup = ceil(numFeature/numGroupFeature);

numWeakClassifier = 50;
numStage = 20;

% >>> initialize the cascaded classifier <<< %
h = zeros(3*numStage, numWeakClassifier);
alpha = zeros(numStage, numWeakClassifier);
s = zeros(1, numStage);
t = zeros(1, numStage);

accuracy = zeros(4, numStage);
positive = ones(1, numTotal);
feature = zeros(numGroupFeature, numTotal);
f = zeros(numWeakClassifier, numTotal);

% >>> add stages until accuracy is 100% <<< %
stageCount = 0;
falsePos = inf;
falseNeg = inf;
while falsePos + falseNeg > 0
 
    stageCount = stageCount + 1;
    
    % >>> initialize the weights <<< %
    
    lPos = sum(positive(1:numPos));
    mNeg = sum(positive(numPos+1:numTotal));
    weight = [ones(1,numPos)/(2*lPos), ones(1,numNeg)/(2*mNeg)];
    fprintf('cascade stage %d\n', stageCount);
    fprintf('negative samples pruned =');
    
    % >>> add weak classifiers until 50% negative samples pruned <<< %
    
    count = 0;
    negCount = 0;
    while negCount < mNeg/2
        
        % >>> increment weak classifier count <<< %
        count = count + 1;
        
        % >>> normalize the weight <<< %
        weight = weight/sum(positive .* weight);
        
        % >>> search for the best weak classifier <<< %
        eMin = inf;
        totalPos = sum(positive(1:numPos) .* weight(1:numPos));
        totalNeg = sum(positive(numPos+1:numTotal) .* weight(numPos+1:numTotal));
        
        for i = 1:numGroup
            filename = sprintf('FEAT_TRAIN%02d.mat', i);
            load(filename, '-mat', 'feat');
            
            [sfeat, ifeat] = sort(feat, 2);
            numFeatures = size(feat, 1);
            fNew = 0;
            
            for j = 1:numFeatures  % >>> in each feature group
                SPos = 0;
                SNeg = 0;
                
                for k = 1:numTotal
                    if positive(ifeat(j, k)) ~= 1
                        continue;
                    end
                    
                    e1 = SPos + (totalNeg - SNeg);
                    e2 = SNeg + (totalPos - SPos);
                    
                    if e2 < e1
                        eTmp = e2;
                        pTmp = 1;
                    else
                        eTmp = e1;
                        pTmp = -1;
                    end
                   
                    if eTmp < eMin
                        fNew = 1;
                        eMin = eTmp;
                        h(3*(stageCount-1)+1, count) = numGroupFeature*(i-1)+j;
                        h(3*(stageCount-1)+2, count) = pTmp;
                        h(3*(stageCount-1)+3, count) = sfeat(j, k);
                    end
                    
                    if ifeat(j,k) > numPos
                        SNeg = SNeg + weight(ifeat(j,k));
                    else 
                        SPos = SPos + weight(ifeat(j,k));
                    end
                    
                end
                
            end
            
            if fNew == 1
                jFeat = h(3*(stageCount-1)+1, count) - numGroupFeature * (i-1);
                f(count,:) = feat(jFeat,:);
            end
        end
        
        % >>> update weights <<< %
        beta = eMin/(1-eMin);
        
        for i = 1:numPos
            if positive(i) ~= 1
                continue;
            end
            p = h(3*(stageCount-1)+2, count);
            theta = h(3*(stageCount-1)+3, count);
            if p * f(count, i) < p * theta
                weight(i) = weight(i) * beta;
            end
        end
        
        for i = numPos+1:numTotal
            if positive(i) ~= 1
                continue;
            end
            p = h(3*(stageCount-1)+2, count);
            theta = h(3*(stageCount-1)+3, count);
            if ~(p*f(count,i) < p*theta)
                weight(i) = weight(i) * beta;
            end
        end
        
        % >>> set threshold for strong classifier <<< %
        alpha(stageCount, count) = log(1/beta);
        
        HSMin = inf;
        for i = 1:numPos
            if positive(i) ~= 1
                continue;
            end
            HS = 0;
            for j = 1:count
                p = h(3*(stageCount-1)+2, j);
                theta = h(3*(stageCount-1)+3, j);
                if p*f(j,i) < p * theta
                    HS = HS + alpha(stageCount, j);
                end
            end
            if HS < HSMin
                HSMin = HS;
            end
        end
        
        % >>> test strong classifier on negative samples <<< %
        negCount = 0;
        for i = numPos+1:numTotal
            if positive(i) ~= 1
                continue;
            end
            HS = 0;
            for j = 1:count
                p = h(3*(stageCount-1)+2,j);
                theta = h(3*(stageCount-1)+3,j);
                if p*f(j,i) < p*theta
                    HS = HS+alpha(stageCount, j);
                end
            end
            if HS < HSMin
                negCount = negCount + 1;
            end
        end
        
        fprintf(' %d', negCount);
        
    end
    
    % >>> save weak class count and the strong class threshold <<< %
    s(stageCount) = count;
    t(stageCount) = HSMin;
    
    % >>> evaluate on samples classified as positive <<< %
    
    falseNeg = 0;
    for i = 1:numPos
        if positive(i) ~= 1
            continue;
        end
        HS = 0;
        for j = 1:count
            p = h(3*(stageCount-1)+2,j);
            theta = h(3*(stageCount-1)+3,j);
            if p*f(j,i) < p*theta
                HS = HS+alpha(stageCount,j);
            end
        end
        if HS >= HSMin
            positive(i) = 1;
        else
            falseNeg = falseNeg+1;
            positive(i) = 0;
        end
    end
    
    falsePos = 0;
    for i = numPos+1:numTotal
        if positive(i) ~= 1
            continue;
        end
        HS = 0;
        for j = 1:count
            p = h(3*(stageCount-1)+2,j);
            theta = h(3*(stageCount-1)+3,j);
            if p*f(j,i) < p*theta
                HS = HS+alpha(stageCount,j);
            end
        end
        if HS >= HSMin
            falsePos = falsePos+1;
            positive(i) = 1;
        else
            positive(i) = 0;
        end
    end

    accuracy(1,count) = falsePos;
    accuracy(2,count) = lPos;
    accuracy(3,count) = falseNeg;
    accuracy(4,count) = mNeg;
end
% >>> saev the result to a MAT file <<< %
save('results.mat', 'h','alpha','s','t','accuracy','-mat','-v7.3');
    







