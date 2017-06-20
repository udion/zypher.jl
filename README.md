# zypher.jl
**zypher**: is a package developed in julia to perform side channel analysis on various encryption systems.

## Introduction
The zypher package is developed to provide side channel analysis tool to people working in the areas such as cryptography.
The structure is designed in an intuitive manner which may be extended and customised to meet one's own cipher apart from some pre loaded ciphers such as AES-128. One can also extend the package by including files (or function) of thier own versions of attacks apart from what is provided such as *Correlation Power Analysis (CPA)*, *Template Attacks (TA)* (coming soon). The API is designed to accept traces in *.csv* in the  following format: <br>
* First column is of plaintexts in hexadecimal format (without 0x prefix and L/l suffix)
* Second column is of ciphertexts in hexadecimal format (without 0x prefix and L/l suffix)
* Rest of the columns contain trace values

## API
Currently the follwoing methods are provided in the package, (users can extend this list to include their own methods):
* <code>loadSPNtrace("\<path_to_file\>", unitSize)</code> : This method is to load the traces corresponding to cipher which is a S-P Network like PRESENT, AES, etc. the unitSize refers to the number of bits which are to be calculated/guessed at a time. This method returns a *type* SPNdata which has the necessary information
* <code>cpa(attak_round, model_type, cipher_type, \<loaded_trace\>)</code> : This method performs cpa on the *type* returned by the loadSPNtrace() and returns another *type* cpaResults which has all the final statistics about the attack and the recovered keys.
  * attack_round can be "first" or "last" (user may include his/her own keywords)
  * model_type can be "HW" or "HD" (user may include his/her own keywords)
  * cipher_type can be "AES" (or other phrases as more SPN ciphers are included)
* <code>display_cpa(\<result_type\>)</code>: This function is to display the result of the cpa function, it also creates a direcorty to store all the graphs generated and displayed as a result of the attack
* <code>dpa(attack_round, target_bit, cipher_type, \<loaded_trace\>)</code> : This method performs dpa on the *type* returned by the loadSPNtrace() and returns another *type* dpaResults which has all the final dpa graphs, the grphs are saved in the separate directory which user will be informed about
  * attack_round can be "first" or "last" (user may include his/her own keywords)
  * target_bit represent the bit to be used for the selection function in the DPA
  * cipher_type can be "AES" (or other phrases as more SPN ciphers are included)
* <code>display_dpa(\<result_type\>)</code>: This function is to display and save the result of the dpa function, it also creates a direcorty to store all the graphs generated

## Installation and Usages
zypher is not yet included in official julia packages and hence the user will need to clone the repository to use the package, this can be done via julia terminal:
<code>julia> Pkg.clone("https://github.com/udion/zypher.jl.git")</code>

The following is using the sample trace provided in the trace folder
```
julia> using zypher
julia> data = loadSPNdata("\<path_to_tracefile\>",8)
julia> res = cpa("first", "HW", "AES", data)
julia> display_cpa(res)
```
The following output is generated also a director with the name of the trace file is created in the same place where the trace file is present, this direcorty has all the graphs plotted as a result of this attack.
```
The recovered key is: 000102030405060708090a0b0c0d0e0f
```
(16 graphs will appear on the screen which are saved in the newly created director, some of the sample graphs are)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/max_cc_keyvals_for_byte7.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/max_cc_keyvals_for_byte9.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/max_cc_keyvals_for_byte13.png)
![alt text](https://github.com/udion/zypher.jl/blob/master/images/max_cc_keyvals_for_byte16.png)
