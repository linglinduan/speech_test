clc;clear;close all;
MFCC_size=12;%mfcc的维数
GMM_component=16;%GMM component 个数
mu_model=zeros(MFCC_size,GMM_component);%高斯模型 分量 均值
sigma_model=zeros(MFCC_size,GMM_component);%高斯模型 分量 方差
weight_model=zeros(GMM_component);%高斯模型 分量 权重
train_file_path='1/1-';%训练文件路径、
num_train=6;%训练句数
test_file_path='./';%测试文件路径 2~15周
num_test=15;%朗读次数,共15周
num_uttenance=6;%测试句数 实际上是6*3

all_train_feature =[];
all_scores = [];

for i=1:num_train
    train_file=[train_file_path num2str(i) 'normal' '.wav']; %设置文件名
    [wav_data ,fs]=readwav(train_file); %读取音频文件
    train_feature=melcepst(wav_data ,fs); %获取特征
    all_train_feature=[all_train_feature;train_feature]; %将特征储存在数组中
end

[mu_model,sigma_model,weight_model]=gmm_estimate(all_train_feature',GMM_component); %用特征计算出模型矩
%测试
for i=1:num_test %对应第几周;共15周，其中包含了第一周中的训练用的语句
    for j=1:num_uttenance %对应第几句
        for k=1:3   %对应normal, fast, slow
            test_file=[num2str(i) '/' num2str(i) '-' num2str(j)]; %设置文件名
            if(k==1) str = 'normal.wav'; end
            if(k==2) str = 'fast.wav'; end
            if(k==3) str = 'slow.wav'; end   
            test_file = strcat(test_file,str);
            [wav_data ,fs]=readwav(test_file); %读取音频文件
            test_feature=melcepst(wav_data ,fs); %提取特征
            [lYM, lY] = lmultigauss(test_feature', mu_model,sigma_model, weight_model); %与模型进行比较
            score(i) = mean(lY); %获得评分
            all_scores(i,j,k) = score(i); %存储所有分数
            fprintf('Test:%d-%d%s score:%f\n',i,j,str,score(i)); %评分
        end
    end
end

max1 = max(max(all_scores(:,:,1)));
max2 = max(max(all_scores(:,:,2)));
max3 = max(max(all_scores(:,:,3)));

min1 = min(min(min(all_scores)));
means = mean(mean(mean(all_scores)));
threshold = min1*0.2+means*0.8;
srcPath = 'test/';
srcNum = 12;
scores = zeros(srcNum);
for i=1:srcNum
    srcName = [srcPath num2str(i) '.wav'];
    [wav_data,fs] = readwav(srcName);
    test_feature = melcepst(wav_data,fs);
    [lYM,lY] = lmultigauss(test_feature', mu_model,sigma_model, weight_model); %与模型进行比较
    scores(i) = mean(lY); %获得评分
    if(scores(i)<threshold) fprintf('%d is not the origin speaker\n',i); end
    
end