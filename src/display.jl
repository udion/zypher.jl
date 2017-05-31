include("cpa.jl")
using PyPlot
plt = PyPlot

function display_cpa(results)
  println("The recovered key is: ", results.key)
  #to get the keymax, possible key strats from 0
  keymax = length(results.ρ[1,:,1]) - 1
  #to display the graphs for each key unit guessed
  for i in 1:length(results.keyGraphs)
    plt.figure()
    plt.plot(results.keyGraphs[i], color="maroon")
    plt.xlim(0,keymax)
    xlabel("key byte values")
    ylabel("maximum correlation values")
    title("max correlation vs key values for unit$(i)")
    plt.savefig(join([results.res_dir, "/max_cc_keyvals_for_byte$(i)"]))
  end
  #can add more functions to manipulate ρ and show details
end
