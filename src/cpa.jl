include("model.jl")

type cpaResults
  key
  ρ::Array
  keyGraphs::Array
  pointOfinterests::Array #the time instants at which the activity for the byte happened
end

function cpa(attack_round, model_type, cipher_type, trace_data)
  V = modelmaker(attack_round, model_type, cipher_type, trace_data)

  num_unit = trace_data.num_unit
  unit_size = trace_data.unit_size
  keymax = 2^unit_size -1
  num_trace = length(trace_data.traces[1,:])

  ρ = zeros(num_unit,keymax+1,num_trace)

  for i in 1:num_unit
    for keyGuess in 0:keymax
      for t in 1:num_trace
        ρ[i,keyGuess+1,t] = abs(cor(V[i,:,keyGuess+1], trace_data.traces[:,t]))
      end
    end
  end

  #now I have the final matrix, now to extract information
  #to recover key
  recovered_key = ""
  keyGraphs = Array{}[]
  poi = Int[]
  for i in 1:num_unit
    push!(keyGraphs, findmax(ρ[i,:,:],2)[1])
    predict_k = findmax(findmax(ρ[i,:,:],2)[1])[2]-1
    #now the correct key bytes has been found, calculating the instants of time
    #where the actual event occured for each byte
    push!(poi,findmax(ρ[i,predict_k+1,:])[2])
    recovered_key = join([recovered_key,hex(predict_k,div(unit_size,4))])
  end
  res = cpaResults(recovered_key, ρ, keyGraphs, poi)
end
