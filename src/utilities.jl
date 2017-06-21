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
function transformToMatrix(IV)
    matrixIV = zeros(UInt8,4,4)
    l = length(IV)
    for i in 2:2:l
        k = div(i,2)
        valstr = IV[i-1:i]
        val = parse(UInt8,valstr,16)
        if k%4 == 0
            r = 4
        else
            r = k%4
        end
        c = trunc(Int8,ceil(k/4))
        matrixIV[r,c] = val
    end
    matrixIV
end
#########################################################
################## maths functions ######################
function mvgaussian_pdf(x,μ,Σ)
  n = length(μ)
  pre_exp = 1/(det(Σ)*(2*pi)^(n/2))
  expo = *((x-μ)',inv(Σ),(x-μ))[1]
  pre_exp*e^(-0.5*expo)
end
