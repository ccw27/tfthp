# Given a html page, extract body content and strip html tags

def stripTags(pageContents):
    pageContents = str(pageContents)
    startLoc = pageContents.find("<body>")
    endLoc = pageContents.rfind("</body>")

    pageContents = pageContents[startLoc:endLoc]

    inside = 0
    text = ''

    for char in pageContents:
        if char == '<':
            inside = 1
        elif (inside == 1 and char == '>'):
            inside = 0
        elif inside == 1:
            continue
        else:
            text += char

    return text

# Given a text string, remove all non-alphanumeric
# characters (using Unicode definition of alphanumeric).

def stripNonAlphaNum(text):
    import re
    return re.compile(r'\W+', re.UNICODE).split(text)

# Given a list of words,
# return a dictionary of word-frequency pairs.

def wordListToFreqDict(wordlist):
    wordfreq = [wordlist.count(p) for p in wordlist]
    return dict(list(zip(wordlist,wordfreq)))

# Sort a dictionary of word-frequency pairs in
# order of descending frequency,
# return a list of word-frequency pairs.

def sortFreqDict(freqdict):
    aux = [(key, freqdict[key]) for key in freqdict]
    aux = sorted(aux, key=lambda x: (-x[1],x[0]))
    return aux

# Given a list of words, remove any that are
# in a list of stop words.

stopwords = ['a']
stopwords += ['']

def removeStopwords(wordlist, stopwords):
    return [w for w in wordlist if w not in stopwords]
