function [tab2write] = compute_bootstrap_ci_pls(resultmat, LVnum)
%
%   resultmat = full path and filename to PLS resultmat
%   LVnum = number of LV you want
%

ORDERBY = 'TD';
mod_names_orig = {'M1 turquoise','M2 blue','M3 brown','M4 yellow', ...
    'M5 green','M6 red','M7 black','M8 pink','M9 magenta', ...
    'M10 purple','M11 greenyellow','M12 tan','M13 salmon', ...
    'M14 cyan','M15 midnightblue','M16 lightcyan','M17 grey60', ...
    'M18 lightgreen','M19 lightyellow','M20 royalblue','M21 darkred'};

mod_names = repmat(mod_names_orig',3,1);

[fpath, fname, fext] = fileparts(resultmat);
load(resultmat);

asd_good_idx = 1:length(mod_names_orig);
asd_poor_idx = (length(mod_names_orig)+1):(length(mod_names_orig)*2);
td_idx = ((length(mod_names_orig)*2)+1):(length(mod_names_orig)*3);

asd_good_bootres = squeeze(result.boot_result.distrib(asd_good_idx,LVnum,:));
asd_poor_bootres = squeeze(result.boot_result.distrib(asd_poor_idx,LVnum,:));
td_bootres = squeeze(result.boot_result.distrib(td_idx,LVnum,:));

ci_bounds = [2.5,97.5];
asd_good_ci = prctile(asd_good_bootres',ci_bounds)';
asd_poor_ci = prctile(asd_poor_bootres',ci_bounds)';
td_ci = prctile(td_bootres',ci_bounds)';

asd_good_corr = result.boot_result.orig_corr(asd_good_idx,LVnum);
asd_poor_corr = result.boot_result.orig_corr(asd_poor_idx,LVnum);
td_corr = result.boot_result.orig_corr(td_idx,LVnum);

if strcmp(ORDERBY,'TD')
    [idx, plot_order] = sort(td_corr,'ascend');
    plot_order(plot_order) = 1:length(mod_names_orig);
elseif strcmp(ORDERBY,'Good')
    [idx, plot_order] = sort(asd_good_corr,'ascend');
    plot_order(plot_order) = 1:length(mod_names_orig);
elseif strcmp(ORDERBY,'Poor')
    [idx, plot_order] = sort(asd_poor_corr,'ascend');
    plot_order(plot_order) = 1:length(mod_names_orig);
end

asd_good = [asd_good_corr asd_good_ci];
asd_poor = [asd_poor_corr asd_poor_ci];
td = [td_corr td_ci];

all_data = [asd_good; asd_poor; td];
all_data(:,4) = (sign(all_data(:,1)) == sign(all_data(:,2))) & (sign(all_data(:,1)) == sign(all_data(:,3)));
all_data(:,5) = repmat(plot_order,3,1);

group_labels = [repmat({'Good'},length(mod_names_orig),1);repmat({'Poor'},length(mod_names_orig),1);repmat({'TD'},length(mod_names_orig),1)];

tab2write = cell2table([group_labels, mod_names num2cell(all_data)], ...
    'VariableNames',{'Grp','ModName','corr','lo_lim','up_lim','nonzero','plot_order'});

fname2save = fullfile(fpath,sprintf('Subgrp_STRUCTresultMEfMRIcorr_bootlim_data4plotting_LV%d_ci%d.csv',LVnum,ci_bounds(2)-ci_bounds(1)));
writetable(tab2write,fname2save,'FileType','text','delimiter',',');
