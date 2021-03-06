function [Y,Xf,Af] = myNeuralNetworkFunction(X,~,~)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Auto-generated by MATLAB, 11-Feb-2021 22:03:55.
%
% [Y] = myNeuralNetworkFunction(X,~,~) takes these arguments:
%
%   X = 1xTS cell, 1 inputs over TS timesteps
%   Each X{1,ts} = 2xQ matrix, input #1 at timestep ts.
%
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = 2xQ matrix, output #1 at timestep ts.
%
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [177.045572309832;11.1176468726744];
x1_step1.gain = [0.0133386625707999;0.0130367304231064];
x1_step1.ymin = -1;

% Layer 1
b1 = [-0.53133459450704534355;-0.033300349515098859321;-0.80240501168659583708;0.084428611330638864141;-0.054076898530889934424;-0.96578212050235801023;0.67006850100622294963;-0.57710545543248403799;-0.053739315992838029845;0.11903541266632758355];
IW1_1 = [-0.023699525406504693553 -0.75867269438816531402;-0.25511325955582131453 -0.19353670864902275395;0.92768572963006001864 -0.075586953357662453601;0.19438951734829601481 -0.0063813642175438401935;-0.18987179302245654755 -0.0060486898412317113491;-0.044775917554884435423 1.1611003190321300682;0.77404966784249695788 -0.022228383339839202781;0.090783448885435380493 -0.84317838271948408746;-0.18958344908335011958 -0.0063495244937397605015;0.26803462682834661157 -0.17838569211981783469];

% Layer 2
b2 = [-0.1483386026217008713;-0.11064999780482960567];
LW2_1 = [0.28479259588402983105 -0.15786712160845212116 0.6324259444381071793 0.26174115670327152694 -0.25136146106738466166 0.058384284425174230726 0.84682820350905996243 -0.32769842399603943406 -0.25019807076702377246 0.35076135141107500637;-0.58396174479985152317 0.30637949567578809384 0.18917064245241346776 -0.15922156226136072177 0.14455093684400621701 0.64157666283900671722 0.25669808384804748691 -0.64136208245097037217 0.14504354092937535303 -0.098205979581079572149];

% Output 1
y1_step1.ymin = -1;
y1_step1.gain = [0.01539252040677;0.0147535270398706];
y1_step1.xoffset = [39.6876497987359;22.994024284235];

% ===== SIMULATION ========

% Format Input Arguments
isCellX = iscell(X);
if ~isCellX
    X = {X};
end

% Dimensions
TS = size(X,2); % timesteps
if ~isempty(X)
    Q = size(X{1},2); % samples/series
else
    Q = 0;
end

% Allocate Outputs
Y = cell(1,TS);

% Time loop
for ts=1:TS
    
    % Input 1
    Xp1 = mapminmax_apply(X{1,ts},x1_step1);
    
    % Layer 1
    a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*Xp1);
    
    % Layer 2
    a2 = repmat(b2,1,Q) + LW2_1*a1;
    
    % Output 1
    Y{1,ts} = mapminmax_reverse(a2,y1_step1);
end

% Final Delay States
Xf = cell(1,0);
Af = cell(2,0);

% Format Output Arguments
if ~isCellX
    Y = cell2mat(Y);
end
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings)
x = bsxfun(@minus,y,settings.ymin);
x = bsxfun(@rdivide,x,settings.gain);
x = bsxfun(@plus,x,settings.xoffset);
end
