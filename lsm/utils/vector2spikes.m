function [ S ] = vector2spikes( V, dt )
% VECTOR2SPIKES short transfer vector time series to spike train
%   S = VECTOR2SPIKES(S, Tsim, dt)
%   Transfer Tsim/dt length of vector data to spike train S 
%   Input:
%		V    - time series, size is Tsim/dt x 1
%       dt   - output time step, simulate time length = 
%		length(V) * dt
%	Output:
%       S    - spike train
%
%	Author: Junyuan Hong, 2015-05-27, jyhong836@gmail.com

S = find(V>0.5)*dt;

