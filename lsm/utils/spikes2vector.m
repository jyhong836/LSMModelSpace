function [ V ] = spikes2vector( S, Tsim, dt )
%SPIKES2VECTOR transfer spike train to vector data
%   V = SPIKES2VECTOR(S, Tsim, dt)
%   Transfer spike train S to Tsim/dt length of vector data,
%   Input:
%       S    - spike train
%       Tsim - simulate time length
%       dt   - output time step
%	Output:
%		V    - transfered time series
%
%   Author: Junyuan Hong, 5/2015, jyhong836@gmail.com

V = zeros(floor(Tsim/dt), 1);
V(ceil(S/dt)) = 1;
V = V(1:floor(Tsim/dt));


end

