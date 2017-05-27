using DataFrames

println("Enter the path to the .csv trace file")
println("Note that the format for .csv file should be")
println("plaintext,ciphertext,tr_val1,tr_val2,tr_val3... :")

file_addr = input()

trace_pct = readtable(file_addr)
println("file loaded..")

#replacing NA's with 0.0
#for i in 1:cols
#  trace_pct[isna(trace_pct[i]),i] = 0.0
#end
##nacols = findin(isna(trace_pct[1,:]),true)
trace_pct = trace_pct[:,1:end-1] #to remove NA
cols = length(trace_pct[1,:])
rows = length(trace_pct[1])
n_trace = cols - 2 #first is pt, second is ct
len_pt = length(trace_pct[1,1])

traces = zeros(rows,n_trace) #to store the traces as array and not dataframe
for t in 1:n_trace
  traces[:,t] = trace_pct[t+2]
end

println("key to be guessed (byte/nibble) at a time? (enter 4 for nibble, 8 for byte)")
guess_unit = parse(Int,input(),10)

println("initiating attack..")
