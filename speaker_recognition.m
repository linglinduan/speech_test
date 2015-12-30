%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����������ڵ��˵�˵����ȷ��
clc;
clear all;
close all;
MFCC_size=12;%mfcc��ά��
GMMM_component=16;%GMM component ����

mu_model=zeros(MFCC_size,GMMM_component);%��˹ģ�� ���� ��ֵ
sigma_model=zeros(MFCC_size,GMMM_component);%��˹ģ�� ���� ����
weight_model=zeros(GMMM_component);%��˹ģ�� ���� Ȩ��

train_file_path='.\training\1\1_';%ģ��ѵ���ļ�·��
num_train=7;%Ŀ��˵����ģ��ѵ���ļ��ĸ���
test_file_path='.\testing\';%�����ļ�·��
num_test=1;%����������ʶ��Ĵ���
num_uttenance=7;%���������ÿ���ʶ��ľ��ӵ�����

all_train_feature=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%train model
%ʹ��1_1��1_7ѵ��
for i=1:num_train
    train_file=[train_file_path num2str(i) '.wav'];
    [wav_data ,fs]=wavread(train_file);
    train_feature=melcepst(wav_data ,fs);  
    all_train_feature=[all_train_feature;train_feature];
    
end
[mu_model,sigma_model,weight_model]=gmm_estimate(all_train_feature',GMMM_component);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%test
for i=1:num_test
    for j=1:num_uttenance
        test_file=[test_file_path num2str(i) '_' num2str(j) '.wav'];
        [wav_data ,fs]=wavread(test_file);
        test_feature=melcepst(wav_data ,fs);
        [lYM, lY] = lmultigauss(test_feature', mu_model, sigma_model, weight_model);
        score(i) = mean(lY);
        fprintf('Test��%d_%d  score:%f\n',i,j,score(i));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%result
[max_score,max_id]=max(score);
[min_score,min_id]=min(score);
fprintf('Max score:%f\nMin score:%f\n',max_score,min_score);