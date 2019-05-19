require './common'


module Exercise1
  extend self

  #
  # @param f1 frequency of token of interest in dataset A
  # @param f2  frequency of token of interest in dataset B
  # @param t1  total number of observations in dataset A
  # @param t2  total number of observations in dataset B
  #
  #
  def rootLogLikelihoodRatio (f1, f2, t1, t2)

    e1 = t1 * (f1 + f2) / (t1 + t2)
    e2 = t2 * (f1 + f2) / (t1 + t2)

    result = 2 * (f1 * Math.log(f1 / e1 + (f1 == 0 ? 1 : 0)) + f2 * Math.log(f2 / e2 + (f2 == 0 ? 1 : 0)))
    begin
      result = Math.sqrt(result)
    rescue
      puts (result)
    end

    if ((f1 / t1) < (f2 / t2))
      result = result * -1
    end

    result
  end

  def cleanUpReddit(hash)
    # Remove words with only one occurence
    hash.delete_if {|key, value| value <= 1}
  end

  def run(size)
    hashReddit = self.cleanUpReddit (Common.loadPushShift("depression", size))
    puts "Load Common English Words"
    commonWords = Common.loadCommonWords()
    totalHashReddit = hashReddit.values.sum
    totalCommonWords = commonWords.values.sum
    rootLLR = {}
    puts "Calculate RootLogLikelihoodRatio"
    hashReddit.each do |k, v|
      rootLLR[k] = self.rootLogLikelihoodRatio(v.to_f, commonWords[k].to_f, totalHashReddit.to_f, totalCommonWords.to_f)
    end
    rootLLR = rootLLR.sort {|a1, a2| a2[1].to_i <=> a1[1].to_i}
    puts "Save to CSV"
    CSV.open("rootLLR#{size}.csv", "wb") {|csv| rootLLR.to_a.each {|elem| csv << elem}}
    puts "Finished Exercise 1"
  end

end