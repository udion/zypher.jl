############ general functions neeeded ####################
#look up table for the HW values of a byte
function hw_look_up_maker(binstr)
    hw = 0
    for i in 1:length(binstr)
        if binstr[i] == '1'
            hw = hw+1
        end
    end
    hw
end
###########################################################

############ function needed for AES attacks ##############
#the following function is to apply the inverse of shift row operation on the matrix
function invShiftRows(i,j)
    i,(((j-1)+(i-1))%4)+1
end
#fucntion to apply inverse s layer in AES
function invSlayer(matrixstate)
    mat = zeros(UInt8,4,4)
    for j in 1:4
        for i in 1:4
            mat[i,j] = invSbox[matrixstate[i,j]+1]
        end
    end
    mat
end

#ρ is common to both the first and last round of CPA and maybe in other techniques
#function ρ_maker(V)
#  n_unit = div(len_pt,div(guess_unit,4))
#  n_k_possible = 2^guess_unit
#
#  ρ = zeros(n_unit, n_k_possible, n_trace)
#
#  for i in 1:n_unit
#    for keyguess in 0:n_k_possible-1
#      for t in 1:n_trace
#        ρ[i,keyguess+1,t] = abs(cor(V[i,:,keyguess+1],traces[:,t]))
#      end
#    end
#  end
#  ρ
#end
#########################################################
