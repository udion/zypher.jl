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
  keys::Array
  traces::Array
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

  pct = readtable(path_to_csvtraces,header=false)

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

  pct = readtable(path_to_csvtraces,header=false)

  #HW creation may be needed in some kind of templates
  for i in 0:2^unit_size-1
    HW[i] = hw_look_up_maker(bin(i,unit_size))
  end

  plaintexts = pct[1]
  ciphertexts = pct[2]
  keys = pct[3]
  traces = Array(pct[:,4:end])
  println("dbg: plaintexts[1] is: ",plaintexts[1])
  println("dbg: length(plaintexts[1)] is: ",length(plaintexts[1]))
  num_unit = div(length(plaintexts[1])*4, unit_size)

  return TA_TRAINdata(unit_size, num_unit, plaintexts, ciphertexts, keys, traces, path_to_resdir)
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

  pct = readtable(path_to_csvtraces,header=false)

  plaintexts = pct[1]; #all the plaintexts are suppose to be of the same length and in hex string
  ciphertexts = pct[2]; #all the ciphertexts are suppose to be of the same length and in hex string
  traces = Array(pct[:,3:end]);
  num_unit = div(length(plaintexts[1])*4, unit_size)

  #the HW creation
  for i in 0:2^unit_size-1
    HW[i] = hw_look_up_maker(bin(i,unit_size))
  end

  return TA_TESTdata(unit_size,num_unit,plaintexts,ciphertexts,traces,path_to_resdir)
end
