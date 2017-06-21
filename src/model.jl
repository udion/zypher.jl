include("loadtrace.jl")

function modelmaker(attack_round, model_type, cipher_type, trace_data)
  num_unit = trace_data.num_unit
  plaintexts = trace_data.plaintexts
  ciphertexts = trace_data.ciphertexts
  unit_size = trace_data.unit_size
  unit_in_pt = div(length(plaintexts[1]),num_unit)
  keymax = 2^unit_size -1

  #the vector to store the model
  V = zeros(Int, num_unit, length(plaintexts), keymax+1)

  if attack_round == "first"
    if model_type == "HW"
      sbox = S_boxes[cipher_type] #S_boxes is a Dict() which returns the S_box of
      #the cipher_type which is to be provided in components
      #for almost all SPN ciphers the first round before Sbox is similar

      for i in 1:num_unit
        for keyGuess in 0:keymax
          for p in 1:length(plaintexts)
            pt_unit = parse(Int,plaintexts[p][(i-1)*unit_in_pt + 1 : i*unit_in_pt],16)
            xor_val = pt_unit$keyGuess
            V[i,p,keyGuess+1] = HW[sbox[xor_val+1]] #HW is Dict needed to be formed depending upon unit_size
          end
        end
      end
    elseif model_type == "HD"
      #the specification of model user needs to provide algo as to how to build model
    end

  elseif attack_round == "last"
    if model_type == "HD"
      #the last round may have different structure for different cipher_type
      #example last round of AES, PRESENT have different structure
      #hence the user may need to provide the algo for the model making of the last round
      #if needed for some cipher type the following is for AES-128
      if cipher_type == "AES"
        invsbox = invS_boxes["AES"]

        for i in 1:num_unit
          if i%4 == 0
              r = 4
          else
              r = i%4
          end
          c = trunc(Int8,ceil(i/4))

          for keyGuess in 0:keymax
            for ct in 1:length(ciphertexts)
              mat_c = transformToMatrix(ciphertexts[ct])
              cell = mat_c[r,c]
              xor_val = cell$keyGuess
              b4_sbox = invsbox[xor_val+1]

              #to get the actual byte_index the particular cell corresponds to (before shiftRows)
              invr,invc = invShiftRows(r,c)
              actual_byte_index = 4*(invc-1) + invr

              V[actual_byte_index, ct, keyGuess+1] = HW[b4_sbox$cell]
            end
          end
        end
      #elseif cipher_type == "<cipher_name>"
        #the code for making model goes here
      end
    #elseif model_type == "<model_type(maybe HD or something)>"
      #the code goes here
    end
  end #the two standard places to perform attacks, can be extended to higher order DPA
V
end
