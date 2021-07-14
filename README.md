
# Solidity_Multi_Deflationary_Token_20210714

An example of a Deflationary Token with Multiple Rates depending on the Total Supply 

DISCLAIMER 

- This is just the result of an exercise to practice with Solidity, do not use this is in production 



# Instructions 

When you deploy the token, you can specify an array of supply thresholds and the corresponding deflationary rate 

Here is the way it works 

InitialSupply --------- Th_0 ------------ Th_1 ------------- Th_i ----------------- Th_N (Min Supply)

                Rate_0          Rate_1              Rate_i             Rate_N               After Rate=0 by default 





# Notes 

The computation of the new Rate requires some gas since there is a for loop and it can be triggered in 2 ways 

- by doing a normal payment 

- by explicitly calling the method computing the current rate 





