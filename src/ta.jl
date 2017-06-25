include("loadtrace.jl")

#this will basically use the template to figure out the keys
function ta(templates, trace_data, cipher_type)
  unit_size = trace_data.unit_size
  num_unit = trace_data.num_unit
  plaintexts = trace_data.plaintexts
  traces = trace_data.traces
  res_dir = trace_data.res_dir
  sbox = S_boxes[cipher_type]

  pt_unit = div(num_unit,unit_size)

  #res_key[i...byte_n] contains the best guess of the ith byte using templates
  res_key_num = []
  for byte_n in 1:num_unit
    #res[k] contains the score of the subkey k
    res = zeros(2^unit_size)
    classMeans = templates[byte_n].classMean
    classMeanCovs = templates[byte_n].classMeanCov
    POI = templates.POI
    for sk in 0:2^unit_size-1
      for p in 1:length(plaintexts)
        p_byte = parse(Int,plaintexts[p][(byte_n-1)*pt_unit+1:(byte_n-1)*pt_unit+2])
        hw = HW[sbox[(p_byte$sk)+1]]
        μ = classMeans[hw]
        Σ = classMeanCov[hw]
        pdf_val = mvgaussian_pdf(traces[p][POI], μ, Σ)
        res[sk+1] += log(pdf_val)
      end
    end
    max_prob_byte = indmax(res)-1
    push!(res_key_num, max_prob_byte)
  end

  recovered_key = ""
  for v in res_key_num
    recovered_key = join([recovered_key,hex(v,2)])
  end
  return recovered_key
end
