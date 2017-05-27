include("components.jl")
include("tracereader.jl")

function hwV_maker(S_box)
  n_unit = div(len_pt,div(guess_unit,4))
  n_k_possible = 2^guess_unit

  V = zeros(Int8,n_unit,rows,n_k_possible)

  for i in 1:n_unit
    for keyguess in 0:n_k_possible-1
      for p in 1:rows
        pt_byte = parse(Int,trace_pct[1][p][((i-1)*div(guess_unit,4) +1) : i*div(guess_unit,4)],16)
        xor_val = pt_byte$keyguess
        if guess_unit == 4
          V[i,p,keyguess+1] = HW4[S_box[xor_val+1]] #S_box will depend upon AES,PRESENT.etc..
        else
          V[i,p,keyguess+1] = HW8[S_box[xor_val+1]] #S_box will depend upon AES,PRESENT.etc..
        end
      end
    end
  end
  V
end

function ρ_maker(V)
  n_unit = div(len_pt,div(guess_unit,4))
  n_k_possible = 2^guess_unit

  ρ = zeros(n_unit, n_k_possible, n_trace)

  for i in 1:n_unit
    for keyguess in 0:n_k_possible-1
      for t in 1:n_trace
        ρ[i,keyguess+1,t] = abs(cor(V[i,:,keyguess+1],traces[:,t]))
      end
    end
  end
  ρ
end

function cpaAttackfirst()
  n_unit = div(len_pt,div(guess_unit,4))
  n_k_possible = 2^guess_unit
  V = hwV_maker(S_box_AES)
  ρ = ρ_maker(V)

  println("Attack completed")

  recovered_key = ""
  for i in 1:n_unit
      predict_k = findmax(findmax(ρ[i,:,:],2)[1])[2]-1
      #println(predict_k)
      recovered_key = join([recovered_key,hex(predict_k,div(guess_unit,4))])
  end
  println("The recoverd key is: ",recovered_key)

  println("returning attack stats")

  ρ
end

@time cpaAttackfirst()
