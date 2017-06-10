include("components.jl")
using DataFrames

type SPNdata
  unit_size::Int
  num_unit::Int
  plaintexts::Array
  ciphertexts::Array
  traces::Array
  res_dir::String
end

type TA_TRAINdata
  unit_size::Int
  num_unit::Int
  plaintexts::Array
  ciphertexts::Array
  traces::Array
  this_unit::Int
  this_subkey::Int
  res_dir::String
end

type TA_TESTdata
  unit_size::Int
  num_unit::Int
  plaintexts::Array
  ciphertexts::Array
  traces::Array
  res_dir::String
end

function loadSPNtrace(path_to_csvtraces, unit_size)
  #creating directory to store the results
  part_names = split(path_to_csvtraces,"/")
  path_to_resdir = ""
  for a in part_names[1:end-1]
    path_to_resdir = join([path_to_resdir, a, "/"])
  end
  path_to_resdir = join([path_to_resdir, part_names[end], "results"])
  mkdir(path_to_resdir)

  pct = readtable(path_to_csvtraces)

  plaintexts = pct[1]; #all the plaintexts are suppose to be of the same length and in hex string
  ciphertexts = pct[2]; #all the ciphertexts are suppose to be of the same length and in hex string
  traces = Array(pct[:,3:end]);
  num_unit = div(length(plaintexts[1])*4, unit_size)

  #the HW creation
  for i in 0:2^unit_size-1
    HW[i] = hw_look_up_maker(bin(i,unit_size))
  end

  x = SPNdata(unit_size,num_unit,plaintexts,ciphertexts,traces,path_to_resdir)
end
#add more loading function for other types of cipher if needed


#this function will return the info (stored in array types) of the total number
#of templates that have to be built before classification of any new trace
function loadTA_TRAINtrace(path_to_csvtraces, unit_size)
  #creating the director to store the trained templates for later testing
  part_names = split(path_to_csvtraces,"/")
  path_to_resdir = ""
  for a in part_names[1:end-1]
    path_to_resdir = join([path_to_resdir, a, "/"])
  end
  path_to_resdir = join([path_to_resdir, part_names[end], "templates"])
  mkdir(path_to_resdir)

  pct = readtable(path_to_csvtraces)
  num_unit = div(length(pct[1,3])*4, unit_size) #pct[1,3] is a plaintext

  #HW creation may be needed in some kind of templates
  for i in 0:2^unit_size-1
    HW[i] = hw_look_up_maker(bin(i,unit_size))
  end

  #the return array which will return the final datatypes
  ret = TA_TRAINdata[]

  #now I need to group data by different unit numbers
  grouped_data = groupby(pct, 1) #this should give 16 groups for AES-128 8bit size

  for g in grouped_data
    #now I need to group data by different subkeys
    g_subkeys = groupby(g,2) #this should give 256 groups for AES-128 8bit size

    for gs in g_subkeys
      this_unit = gs[1,1]
      this_subkey = gs[1,2]
      plaintexts = gs[3]
      ciphertexts = gs[4]
      traces = Array(gs[:,5:end])
      x = TA_TRAINdata(unit_size, num_unit, plaintexts, ciphertexts, traces, this_unit, this_subkey, path_to_resdir)
      push!(ret, x)
    end
  end
  ret
end


function loadTA_TESTtrace(path_to_csvtraces, unit_size)
  #for the testing case the traces need not have plaintexts and ciphertexts
  #for some template models, In such casses user have to ensure that there are
  #plaintexts and ciphertexts cols are filled with 000...0 with apporpriate number of
  #zeros in so that num_unit can be calculated

  #creating the directory to store results
  part_names = split(path_to_csvtraces,"/")
  path_to_resdir = ""
  for a in part_names[1:end-1]
    path_to_resdir = join([path_to_resdir, a, "/"])
  end
  path_to_resdir = join([path_to_resdir, part_names[end], "results"])
  mkdir(path_to_resdir)

  pct = readtable(path_to_csvtraces)

  plaintexts = pct[1]; #all the plaintexts are suppose to be of the same length and in hex string
  ciphertexts = pct[2]; #all the ciphertexts are suppose to be of the same length and in hex string
  traces = Array(pct[:,3:end]);
  num_unit = div(length(plaintexts[1])*4, unit_size)

  #the HW creation
  for i in 0:2^unit_size-1
    HW[i] = hw_look_up_maker(bin(i,unit_size))
  end

  x = TA_TESTdata(unit_size,num_unit,plaintexts,ciphertexts,traces,path_to_resdir)
end
