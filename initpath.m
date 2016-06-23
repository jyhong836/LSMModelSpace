function initpath(varargin)
% INITPATH init the matlab path 
%   INITPATH(TargetName)
%   TargetName:
%       lsm     - init lsm and lsm's subfolders
%       default - init 'lsm' target and RV_kernel,compute_Kernel_matrix,
%       prepared_datasets router
%
%   Author: Junyuan Hong, 2015-5, jyhong836@gmail.com

    [pathstr] = fileparts(mfilename('fullpath'));
	nvar = length(varargin);
	RV_folder = fullfile(pathstr,'RV model-based kernel');
    if nvar < 1
        nvar = 1;
        varargin{1} = 'default';
    end
	for i=1:nvar
		switch varargin{i}
			case 'lsm'
				addpath(fullfile(pathstr,genpath('lsm')));
			case 'default'
                disp('  * init default path *');
				addpath(fullfile(RV_folder,'RV_kernel'));
				addpath(fullfile(RV_folder,'compute_Kernel_matrix'));
				addpath(fullfile(RV_folder,'datasets'));
				addpath(fullfile(RV_folder,'libsvm'));
				addpath(genpath(fullfile(pathstr,'lsm')));
			otherwise
                help initpath;
				error(['Unknown target: ' varargin{i}]);
		end
	end

