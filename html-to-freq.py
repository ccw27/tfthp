import urllib.request, urllib.error, urllib.parse
import obo

import sys

if __name__ == "__main__":
  if len(sys.argv) != 2:
    print("Usage: python html-to-freq.py <IPaddress>\n")
  else:
    # get web page
    print(sys.argv[0])
    print(sys.argv[1])
    url = 'http://' + sys.argv[1] + ':80'
    response = urllib.request.urlopen(url)
    html = response.read()

    # parse web page
    text = obo.stripTags(html).lower().replace("\\n", " ")
    fullwordlist = obo.stripNonAlphaNum(text)
    wordlist = obo.removeStopwords(fullwordlist, obo.stopwords)
    dictionary = obo.wordListToFreqDict(wordlist)
    sorteddict = obo.sortFreqDict(dictionary)

    # print words with frequency > 1
    print ("{:<25} {:<15}".format('Words','Frequency'))
    print ("{:<25} {:<15}".format('-----','---------'))
    for s in sorteddict:
      if s[1] > 1:
        print("{:<25} {:<15}".format(str(s[0]), str(s[1])))
