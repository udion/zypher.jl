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
  unit_size = taTrainData[1].unit_size
  num_unit = taTrainData[1].num_unit
  n_templates = length(taTrainData)

  #total number of templates to be formed are
  #num_unit X 2^unit_size
  for i in 1:2^unit_size:n_templates
    means_of_unit = []
    temp_noises_of_unit = []
    for j in 1:2^unit_size
      t = taTrainData[(i-1)*(2^unit_size)+j]
      μ = mean(t.traces,1)
      noise_mat = t.traces .- μ'
      push!(means_of_unit,μ)
      push!(temp_noises_of_unit,noise_mat)
    end
    #calculation of poi
    poi = POI(means_of_unit)
    noises_of_unit = Array(Any,length(temp_noises_of_unit))
    for z in 1:length(temp_noises_of_unit)
      noises_of_unit[z] = temp_noises_of_unit[z][:,poi]
    end
    #calculating covariance matrices for the noises of this unit
    covmatrix = zeros(length(poi),length(poi))
    for z in 1:length(noises_of_unit)
      N = noises_of_unit[z]
      for u in 1:length(poi)
        for v in 1:length(poi)
          covmatrix[u,v] = cov(N[:,u],N[:,v])
        end
      end
      push!(templates,template(i,z-1,means_of_unit[z],covmat))
    end
    templates
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
