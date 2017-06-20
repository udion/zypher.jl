include("loadtrace.jl")

type dpaResults
  diff_of_means::Array
  res_dir::String
end

#cipher type will determine the sbox to be used for the selectiong function (if at all needed)
#usually the first round is chosen for the DPA attack, however one may extend the attack
#for the other round by extending the if conditionals, by default the first round attack
#is implemented which will work for many SPN as the first round initial step is common for
#many SPN which is addition(xor) with key followed by substituion
#target_bit in the following represents the bit which is to be targeted in the selection function
function dpa(attack_round, target_bit, cipher_type, trace_data)
  unit_size = trace_data.unit_size
  num_unit = trace_data.num_unit
  plaintexts = trace_data.plaintexts
  ciphertexts = trace_data.ciphertexts
  traces = trace_data.traces
  res_dir = trace_data.res_dir
  unit_in_pt = div(length(plaintexts[1]),num_unit)
  keymax = 2^unit_size-1
  sbox = S_boxes[cipher_type]

  n_sample = length(plaintexts)
  diff_vecs_units = []

  if attack_round == "first"
    for i in 1:num_unit
      diff_vecs = Array{Float64}[]
      for subkey in 0:keymax
         marker = zeros(Int,n_sample)
         for p in 1:n_sample
           pt = plaintexts[p]
           ptval = parse(Int, pt[(i-1)*unit_in_pt+1:i*unit_in_pt], 16)
           xor_val = ptval$subkey
           sval = sbox[xor_val+1]
           if bin(sval,unit_size)[target_bit] == '1'
             marker[i] = 1
           end
         end
         #grouping the traces together depending upon
         #which class they belong to 'one' or 'zero'
         diff = mean(traces[find(marker .== 1),:],1)' - mean(traces[find(marker .== 0),:],1)'
         push!(diff_vecs,diff)
       end
       push!(diff_vecs_units,diff_vecs)
     end
   end

   x = dpaResults(diff_vecs_units,res_dir)
 end
