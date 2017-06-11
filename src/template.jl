include("loadtrace.jl")

type template
  this_unit::Int
  this_subkey::Int
  μ::Array
  Σ::Array
end

#this function constructs templates in a standard manner as presented in
#the semiinal work on template attacks user may add different functions
#to make template in different manner
#this function takes in the output of loadTA_TRAINtrace which is array of TA_TRAINdata type
function templatemaker1(taTrainData)
  templates = [] #the array containing all the templates

  for t in taTrainData
    traces = t.traces
    unit_size = t.unit_size
    num_unit = t.num_unit

    #check the following flow, it doesnt seem right and its not complete!!!!
    for i in 1:num_unit
      means_of_unit = []
      temp_noises_of_unit = []
      for j in 0:(2^unit_size)-1
        μ = mean(traces,1)
        noise_vec = traces .- μ'
        push!(means_of_unit,μ)
        push!(temp_noises_of_unit,noise_vec)
      end
      #calculation of POI
      poi = POI(means_of_unit)
      noises_of_unit = Array(Any,length(temp_noises_of_unit))
      for z in 1:length(temp_noises_of_unit)
        noises_of_unit[z] = temp_noises_of_unit[z][:,poi]
      end

      covmat = zeros(length(poi), length(poi))
      for k in 1:length(noises_of_unit)
        for u in 1:length(poi)
          for v in 1:length(poi)
            covmat[u,v] = cov(noises_of_unit[k][:,u],noises_of_unit[k][:,v])
          end
        end
        push!(templates,template(t.this_unit, ))
      end

    end
  end
end

function POI(means_of_unit)
  n_mean = length(means_of_unit)
  sum_diff_vec = zeros(length(means_of_unit[1]))
  for i in 2:n_mean
    for j in 1:i-1
      sum_diff_vec += means_of_unit[i] - means_of_unit[j]
    end
  end

  #calculation of the highest peaks
  sdv_sort = sort(sum_diff_vec)
  poi = []
  n_top_peaks = 20
  for x in sdv_sort[end-n_top_peaks-1:end]
    push!(poi,find(sum_diff_vec .== x)[1])
  end
  poi
end
