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
  n_unit = div(length(plaintexts[1])*4, unit_size)

  #the HW creation
  for i in 0:2^unit_size-1
    HW[i] = hw_look_up_maker(bin(i,unit_size))
  end

  x = SPNdata(unit_size,n_unit,plaintexts,ciphertexts,traces,path_to_resdir)
end
#add more loading function for other types of cipher if needed
