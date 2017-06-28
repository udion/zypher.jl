# zypher.jl
**zypher**: is a package developed in julia to perform side channel analysis on various encryption systems.

## Introduction
The zypher package is developed to provide side channel analysis tool to people working in the areas such as cryptography.
The structure is designed in an intuitive manner which may be extended and customised to meet one's own cipher apart from some pre loaded ciphers such as AES-128. One can also extend the package by including files (or function) of thier own versions of attacks apart from what is provided such as *Correlation Power Analysis (CPA)*, *Template Attacks (TA)*. The API is designed to accept traces in *.csv* in the  following format: <br>
* First column is of plaintexts in hexadecimal format (without 0x prefix and L/l suffix)
* Second column is of ciphertexts in hexadecimal format (without 0x prefix and L/l suffix)
* Rest of the columns contain trace values

## API
Currently the follwoing methods are provided in the package, (users can extend this list to include their own methods):
* <code>loadSPNtrace("\<path_to_file\>", unitSize)</code> : This method is to load the traces corresponding to cipher which is a S-P Network like PRESENT, AES, etc. the unitSize refers to the number of bits which are to be calculated/guessed at a time. This method returns a *type* SPNdata which has the necessary information
* <code>cpa(attak_round, model_type, cipher_type, \<loaded_trace\>)</code> : This method performs cpa on the *type* returned by the loadSPNtrace() and returns another *type* cpaResults which has all the final statistics about the attack and the recovered keys
  * attack_round can be "first" or "last" (user may include his/her own keywords)
  * model_type can be "HW" or "HD" (user may include his/her own keywords)
  * cipher_type can be "AES" (or other phrases as more SPN ciphers are included)
* <code>display_cpa(\<result_type\>)</code>: This function is to display the result of the cpa function, it also creates a direcorty to store all the graphs generated and displayed as a result of the attack
* <code>dpa(attack_round, target_bit, cipher_type, \<loaded_trace\>)</code> : This method performs dpa on the *type* returned by the loadSPNtrace() and returns another *type* dpaResults which has all the final dpa graphs, the grphs are saved in the separate directory which user will be informed about
  * attack_round can be "first" or "last" (user may include his/her own keywords)
  * target_bit represent the bit to be used for the selection function in the DPA
  * cipher_type can be "AES" (or other phrases as more SPN ciphers are included)
* <code>display_dpa(\<result_type\>)</code>: This function is to display and save the result of the dpa function, it also creates a direcorty to store all the graphs generated
* <code>loadTA_TRAINtrace("\<path to file\>", unitSize)</code> : This method takes the absolute path to the trace which can be used to build templates which will later be used to recover the key from new traces. The format of the traces for building template is as follows:
  * First column is plaintexts
  * Second column is of ciphertexts *(it's need depends upon the type of template one is building)*
  * Third colum is of keys used for encryption
* <code>loadTA_TESTtrace("\<path to file\>", unitSize)</code> : This method is to load the traces on which the template attack is to be performed. Since these are being attacked they don't have the column for keys, and the format is same as the SPN traces
* <code>buildTemplates(\<loaded_data\>, cipher_type)</code> : This takes the result of loadTA_TRAINtrace and the type of cipher which is being attacked (to load the appropriate sbox and other compnents) to build the templates for the template attacks, the templates created are for the **HW**(Hamming weight model, one may write other functions to build other kinds of templates)
* <code>ta(templates, \<loaded_data\>, unitSize)</code> : This method takes the result of the buildTemplates and the data which is needed to be attacked and the unitSize and returns the result of the attack
* <code>display_ta(\<result_ta\>)</code> : This methods takes the return value of the ```ta()``` and produces the log file and the appropriate graphs in a reult directory

## Installation and Usages
zypher is not yet included in official julia packages and hence the user will need to clone the repository to use the package, this can be done via julia terminal:
<code>julia> Pkg.clone("https://github.com/udion/zypher.jl.git")</code>

The following is using the sample trace provided in the trace folder, It's performing CPA on first round on AES(traces obtained from microcontroller)
```
julia> using zypher
julia> data = loadSPNtrace("\<path_to_AES_trace_firstround_micro.csv\>",8)
julia> res = cpa("first", "HW", "AES", data)
julia> display_cpa(res)
```
The following output is generated also a directory with the name of the trace file is created in the same place where the trace file is present, this direcorty has all the graphs plotted as a result of this attack and a log.txt file.
```
The recovered key is: 000102030405060708090a0b0c0d0e0f
```
(16 graphs will be saved in the newly created directory, some of the sample graphs are)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_micro_cpa/max_cc_keyvals_for_byte7.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_micro_cpa/max_cc_keyvals_for_byte9.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_micro_cpa/max_cc_keyvals_for_byte13.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_micro_cpa/max_cc_keyvals_for_byte16.png)

The following performs CPA on AES on the last round(traces has been obtained from the sasebo gII FPGA board)
```
julia> using zypher
julia> data = loadSPNtrace("\<path_to_AES_trace_fpga.csv\>",8)
julia> res = cpa("last", "HW", "AES", data)
julia> display_cpa(res)
```
The following output is generated also a directory with the name of the trace file is created in the same place where the trace file is present, this direcorty has all the graphs plotted as a result of this attack and a log.txt file.
```
The recovered key is: d014f9a8c9ee2589e13f0cc8b6630ca6
```
(16 graphs will be saved in the newly created directory, some of the sample graphs are)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_fpga_cpa/max_cc_keyvals_for_byte1.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_fpga_cpa/max_cc_keyvals_for_byte2.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_fpga_cpa/max_cc_keyvals_for_byte12.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_fpga_cpa/max_cc_keyvals_for_byte14.png)
The recovered key when using with the "last" option refers to the last round key, in the above example the key used for the encryption was **2b7e151628aed2a6abf7158809cf4f3c** and last round key corresponding to this is indeed **d014f9a8c9ee2589e13f0cc8b6630ca6**.

The following are the results of the Template attack perform on AES traces (traces not uploaded, big file!)
```
julia> d_train = loadTA_TRAINtrace("path_to_training_csv_file",8);
julia> templates = buildTemplates(d_train, "AES");
julia> d_test = loadTA_TESTtrace("path_to_attack_trace",8);
julia> res = ta(templates, d_test, "AES");
julia> display_ta(res);
```
The following log.txt file and 16 graphs representing the sum of different of means (for POI selection) will be saved in the directory in which the test csv file was present
```
The recoverd key: 489db4b3f3172961cc2bcb4ed2e28eb7

_____________________
byte1
POI: 2322 2311 2329 2335 2341 2304 905 2298 2347 916 

_____________________
byte2
POI: 4134 2428 2417 4122 2435 4709 4140 2441 4128 4721 

_____________________
byte3
POI: 4965 2535 2523 4953 2541 4971 2529 4959 2547 4977 

_____________________
byte4
POI: 2641 2630 2647 2653 2659 1111 2616 2665 2622 1122 

_____________________
byte5
POI: 2747 2736 2753 2759 2765 1180 2728 2771 2722 2716 

_____________________
byte6
POI: 2853 2842 4184 4359 2860 2866 4172 4190 4365 4346 

_____________________
byte7
POI: 2960 2948 2966 2972 2954 2978 2935 2941 2984 1317 

_____________________
byte8
POI: 3066 3054 3072 3060 3078 3084 3041 3047 1386 3090 

_____________________
byte9
POI: 3172 3160 3178 3166 3184 3190 3147 3153 1455 3196 

_____________________
byte10
POI: 3278 3267 4234 4222 3285 4472 3291 4240 4259 4765 

_____________________
byte11
POI: 3384 3373 3390 3396 3402 3366 3360 3408 3428 3354 

_____________________
byte12
POI: 3491 3479 3497 3485 3503 3509 3466 3472 3460 1661 

_____________________
byte13
POI: 3597 3585 3603 3609 3591 3615 1731 3621 3572 3578 

_____________________
byte14
POI: 3703 3692 4285 3709 4590 3715 4291 4865 4596 4858 

_____________________
byte15
POI: 3809 3798 3816 3822 3828 1867 3784 3790 3834 1878 

_____________________
byte16
POI: 3915 3904 3922 3928 3934 4009 1936 3897 3940 3891 
```
(16 graphs will be saved in the newly created directory, some of the sample graphs are)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_micro_ta/sumdiffmean_12.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_micro_ta/sumdiffmean_14.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_micro_ta/sumdiffmean_2.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/AES_micro_ta/sumdiffmean_3.png)

## Notes
* Make sure that your python environment variable is set to python2 for julia usages as [PyCall](https://github.com/JuliaPy/PyCall.jl) might give error
* When attacking AES, keep *unitSize* equal to 8(which is equivalent to 1 byte) as for most of the scenarios the inverse and other utilities will be defined considering a byte as smallest unit
