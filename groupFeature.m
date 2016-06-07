numPos = 471;  %--->
numNeg = 1000;  %---> 
numTotal = numPos + numNeg;
numFeature = 34200;
numGroupFeature = 5000;
numGroup = ceil(numFeature/numGroupFeature);

fprintf('number of groups = %d\n', numGroup);
fprintf('groups processed =');

feat = zeros(numGroupFeature, numTotal);

%{
load('positive_train.mat','-mat','features');
features_pos1 = features;
clear features;
load('positive_train2.mat','-mat','features');
features_pos2 = features;
features_pos = cat(2, features_pos1, features_pos2);
clear features;
load('negative_train.mat','-mat','features'); 
features_neg1 = features;
clear features;
load('negative_train2.mat','-mat','features'); 
features_neg2 = features;
clear features;
load('negative_train3.mat','-mat','features');
features_neg3 = features;
clear features;
load('negative_train4.mat','-mat','features');
features_neg4 = features;
clear features;
%}

%features_neg = cat(2, features_neg1, features_neg2);
%features_neg = cat(2, features_neg4, features_neg3);
%features_neg = cat(2, features_neg, features_neg4);



load('positive_test.mat', '-mat', 'features');
features_pos = features;
clear features;
load('negative_test.mat', '-mat', 'features');
features_neg = features;
clear features;


for i = 1:floor(numFeature/numGroupFeature)
    startIndex = numGroupFeature * (i-1) + 1;
    endIndex = numGroupFeature * i;
    
    feat(:, 1:numPos) = features_pos(startIndex:endIndex, :);
    
    feat(:, numPos+1:numTotal) = features_neg(startIndex:endIndex, :);
   
    
    %filename = sprintf('FEAT_TRAIN%02d.mat', i); %--->
    filename = sprintf('FEAT_TEST%02d.mat', i); 
    save(filename, 'feat', '-mat', '-v7.3');
    fprintf(' %d', i);
end


%clear feat;
feat = zeros(mod(numFeature, numGroupFeature), numTotal);
size(feat)
startIndex = numGroupFeature * floor(numFeature/numGroupFeature) + 1;
endIndex = numFeature;

%load('positive_test.mat','-mat','features');
feat(:, 1:numPos) = features_pos(startIndex:endIndex, :);
%clear features;
    
%load('negative_test.mat','-mat','features');
feat(:, numPos+1:numTotal) = features_neg(startIndex:endIndex, :);
%clear features;

%filename = sprintf('FEAT_TRAIN%02d.mat', numGroup);  %--->
filename = sprintf('FEAT_TEST%02d.mat', numGroup);
save(filename, 'feat', '-mat', '-v7.3');
fprintf(' %d\n', numGroup);
fprintf('\n');

    
