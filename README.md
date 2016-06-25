RV model-based kernel with LSM
==============================

This repository contains the source code for classification based on the liquid state machine (LSM).

We build our project on the basis of codes provided by Fengzhen Tang (fxt126@cs.bham.ac.uk). This repository integrates work from other literatures. All the contact information is retained in the preamble. *ALL* necessary codes can be obtained  *freely* from the Internet.

 `demo.m` is a script to allow a quick view, and from which a quick start for your own project.

### HOWTO

+ How to start?
	* download the data sets from website [here](http://www.cs.ucr.edu/~eamonn/time_series_data/) (The data sets are not included in this repo.)
    * firstly, run `initpath` to include some necessary folders.
    * run `NormalRV`, `GMMRV`, `fisherRV`, `SamplingRV` to test classification.
    * we have included a data set for testing purpose. Run `demo.m`, you will see the experimental result on that data.

+ How to adjust reservoir size (R_no) and regression coefficient (val) to get a best fitting?
    * You may run `lsm_weight_*.m` directly to see the fitting error, and you may also integrate your own own algorithm in adjusting `R_no` and `val`.
    * `test/test.m` is a useful in finding best combination of `R_no` and `val`.
    * In addition, default settings in `test/test.m` should not be ignored and they are good starting points for a beginner.

+ How to adjust svm parameters in svm, i.e. `cost` and `kp`?
    * Run `NormalRV`, `GMMRV`, `fisherRV`, `SamplingRV` by feeding a list of `cost` and `kp`, the best classification accuracy will come out.

### Dependencies Version

This repository includes a precompiled version of `csim 1.1.1` and `libsvm 3.2`, including mexw64, mexa64m, mexmaci64 for usage under Windows, Linux, Mac.

The csim can be found [here](http://www.lsm.tugraz.at/). N.B. the original version from the website was altered to meet the updated operational environment.

__libsvm 3.2__ or higher version is required. __libsvm__ is a library for support vector machines which was obtained from [here](http://www.csie.ntu.edu.tw/~cjlin/libsvm/).


### About

This repository is mainly contributed by Junyuan Hong(jyhong836@gmail.com), in cooperation with [Yang Li](emailto:csly@mail.ustc.edu.cn).

### License

This repository is distributed under the [GNU General Public License](http://www.gnu.org/copyleft/gpl.html).