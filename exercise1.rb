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
    # Remove numbers
    hash.each do |k, v|
      if /\A\d+\z/.match(k)
        hash.delete(k)
      end
    end

    # Discard words with special chars
    hash.each do |k, v|
      special = "?<>',?[]}{=-)(*&^%$#`~{}"
      regex = /[#{special.gsub(/./) {|char| "\\#{char}"}}]/
      if (k =~ regex)
        hash.delete(k)
      end
    end
    # Remove words with only one occurence
    hash.delete_if {|key, value| value <= 1}
    # Short words (less or eq 2 in length) dont have much semantics in english or maybe single letter (I, we, of, my...)
    #hash.delete_if {|k, v| k.length <= 2}
    # Delete strange blank char
    hash.delete("x200b")
    # Clean URLS
    hash.delete_if {|k, v| k.start_with?("http")}
    return hash
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