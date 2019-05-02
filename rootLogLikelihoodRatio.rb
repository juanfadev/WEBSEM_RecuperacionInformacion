require 'csv'
require 'mathn'

#
# @param a frequency of token of interest in dataset A 
# @param b  frequency of token of interest in dataset B 
# @param c  total number of observations in dataset A 
# @param d  total number of observations in dataset B
#
#

def loadCommonWords(file="unigram_freq.csv")
    table = CSV.parse(file, headers: true)
    table.each do |r| 
        puts r
    end
end

def rootLogLikelihoodRatio (a,b,c,d)
    e1 = c*(a+b)/(c+d)
    e2 = d*(a+b)/(c+d)

    result = 2*(a*Math.log(a/e1+(a==0?1:0))+b*Math.log(b/e2+(b==0?1:0)))
    result = Math.sqrt(result)

    if((a/c)<(b/d)) 
        result = result*-1
    end
    
    result
end


loadCommonWords()
