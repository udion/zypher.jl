include("cpa.jl")
using PyPlot
plt = PyPlot

function display_cpa(results)
  #to get the keymax, possible key strats from 0
  keymax = length(results.ρ[1,:,1]) - 1
  #to display the graphs for each key unit guessed
  for i in 1:length(results.keyGraphs)
    fig = plt.figure()
    plt.plot(results.keyGraphs[i], color="maroon")
    plt.xlim(0,keymax)
    xlabel("key byte values")
    ylabel("maximum correlation values")
    title("max correlation vs key values for unit$(i)")
    plt.savefig(join([results.res_dir, "/max_cc_keyvals_for_byte$(i)"]))
    plt.close(fig)
  end
  f = open(join([results.res_dir, "/log.txt"]),"w")
  write(f,join(["The recovered key is: ", results.key]))
  close(f)
  #can add more functions to manipulate ρ and show details
end

function display_dpa(results)
  num_unit = length(results.diff_of_means)
  for i in 1:num_unit
    dir = join([results.res_dir, "/byte$(i)"])
    mkdir(dir)
    diff_vecs = results.diff_of_means[i]
    for j in 1:length(diff_vecs)
      fig = plt.figure()
      plt.plot(diff_vecs[i])
      plt.xlim(0,length(diff_vecs[i]))
      xlabel("time")
      ylabel("difference mean power")
      t = "DPA subkey=$(j-1) for byte$(i)"
      title(t)
      plt.savefig(join([dir,"/","subkey$(j-1).png"]))
      plt.close(fig)
    end
  end
  println(join(["The resulting dpa plots are saved at ", results.res_dir]))
end
