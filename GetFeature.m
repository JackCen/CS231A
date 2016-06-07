clear all;
%{
filename = sprintf('train/face/face');
extractFeature(1000, filename, 'positive_train2.mat', 1000);
%}

%{
filename = sprintf('train/non-face/nonface');
extractFeature(1000, filename, 'negative_train4.mat', 3200);
%}

%{
filename = sprintf('test/face/cmu_');
extractFeature(471, filename, 'positive_test.mat', 0);
%}

%{
filename = sprintf('test/non-face/cmu_');
extractFeature(1000, filename, 'negative_test.mat', 0);
%}

%{
filename = sprintf('train/face/face');
extractFeature(429, filename, 'positive_test_train.mat', 2000);
%}

%{
filename = sprintf('train/non-face/nonface');
extractFeature(1000, filename, 'negative_test_train.mat', 3000);
%}


%{
filename = sprintf('train/face/face');
extractHoGFeature(2429, filename, 'positive_train_HOG.mat', 0);

filename = sprintf('train/non-face/nonface');
extractHoGFeature(2000, filename, 'negative_train_HOG.mat', 0);
%}

%{
filename = sprintf('test/face/cmu_');
extractHoGFeature(471, filename, 'positive_test_HOG.mat', 0);

filename = sprintf('test/non-face/cmu_');
extractHoGFeature(1000, filename, 'negative_test_HOG.mat', 0);
%}











