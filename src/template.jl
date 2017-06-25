include("loadtrace.jl")

type template
  this_unit::Int
  classMeans::Array
  POI::Array
  classMeanCov::Array
end

#this function constructs templates in a standard manner as presented in
#the semiinal work on template attacks user may add different functions
#to make template in different manner
#this function takes in the output of loadTA_TRAINtrace which is array of TA_TRAINdata type
function buildTemplates(data)
  unit_size = data.unit_size
  num_unit = data.num_unit
  plaintexts = data.plaintexts
  ciphertexts = data.ciphertexts
  keys = data.keys
  traces = data.traces
  res_dir = data.res_dir

  pt_unit = div(num_unit,unit_size)

  #will return this aaray of template
  templates = template[]

  #building templates for byte_n, templates will be
  #I have to build templates for all the bytes
  for byte_n in 1:16
      #based on the HW values which will vary from 0 to 8 hence 9 templates
      #storing the sbox result of the first bytes in the sample
      tempSbox = zeros(Int,length(plaintexts))
      for i in 1:length(plaintexts)
          p_byte = parse(Int,plaintexts[i][(byte_n-1)*pt_unit+1:(byte_n-1)*pt_unit+2],16)
          k_byte = parse(Int,keys[i][(byte_n-1)*pt_unit+1:(byte_n-1)*pt_unit+2],16)
          tempSbox[i] = sbox[p_byte$k_byte+1]
      end
      #storing the HW values of the first byte of the output of the sbox
      #this will decide which trace belongs to which class
      tempHW = zeros(Int,length(plaintexts))
      for i in 1:length(plaintexts)
          tempHW[i] = HW[tempSbox[i]]
      end
      #a dictionary which consistis of elements of the same class bunched together
      #as a 2D array with key equal to their representing HW values
      tempClass = Dict()
      for i in 0:unit_size
          tempClass[i] = []
      end
      #filling the dictionary with the right traces in right classes
      for i in 1:length(plaintexts)
          hw = tempHW[i]
          push!(tempClass[hw],traces[i,:])
      end
      #now I have to calculate the means of traces present in each of the classes
      tempMeans = Dict()
      for i in 0:unit_size
          tempMeans[i] = mean(tempClass[i])
      end
      POI = get_pois(tempMeans)
      #now for each class I want to build a multivariate model for which
      #I need to define the mean vector and the covariance matrix
      tempMeanCov = Dict()
      for i in 0:unit_size
          meanvec = mean(tempClass[i])[POI]
          traceMat = zeros(length(tempClass[i]),length(traces[1,:]))
          for j in 1:length(tempClass[i])
              tr = tempClass[i][j]
              for k in 1:length(traces[1,:])
                  traceMat[j,k] = tr[k]
              end
          end

          covmat = zeros(length(POI),length(POI))
          for u  in 1:length(POI)
              for v in 1:length(POI)
                  covmat[u,v] = cov(traceMat[:,POI[u]],traceMat[:,POI[v]])
              end
          end
          tempMeanCov[i] = [meanvec, covmat]
      end
      push!(templates,template(byte_n, tempMeans, POI, tempMeanCov))
  end
  #might wanna write it down in JLD file
  return templates
end

function get_pois(tempMeans)
    tempSumDiff = zeros(length(tempMeans[0]))
    for i in 0:unit_size
        for j in i+1:unit_size
            tempSumDiff += abs(tempMeans[i] - tempMeans[j])
        end
    end
    #now i need to find some POI's from tempSumDiff
    n_pois = 10
    poi_spacing = 5

    POI = []
    for i in 1:n_pois
        nextPoi = indmax(tempSumDiff)
        push!(POI,nextPoi)
        inv_left = max(1,nextPoi - poi_spacing)
        inv_right = min(length(tempSumDiff),nextPoi+poi_spacing)
        for j in inv_left:inv_right
            tempSumDiff[j] = 0
        end
    end

    return POI
end
