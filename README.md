# bosonnlp - Boson NLP SDK for Ruby

### Install

    gem install bosonnlp

### Usage

```ruby
# run `export BOSON_API_TOKEN="<your token from bosonnlp.com>"` first.

# ----- string and list style -----
require 'bosonnlp'
p '美好'.c_sentiment
p ['很好吃, 有点贵', '贵了点, 好吃', '价格贵, 但很好吃', '很好吃'].m_comments

# ----- normal style (Handle extra param) -----
nlp = Bosonnlp.new
query = { 'top_k' => 3 }
p nlp.s_suggest(['粉丝'], :query => query)

# -- push more than one time (Handle large amount of texts with mutiple API) --
mh = nlp.create_multiple(:comments)
mh.push(['很好吃, 有点贵', '贵了点, 好吃'])
mh.push(['价格贵, 但很好吃', '很好吃, 但很贵'])
mh.analysis  # Start computing on the server.
p mh.result  # Call this will block until receive result from the server.

mh.push(['很好吃, 有点贵', '贵了点, 好吃'])  # Yes, play it incrementally!
mh.analysis
p mh.result

mh.clear  # Clear the texts.
```

You must have noticed the prefix **'c_','m_','s_'** before API names, e.g. sentiment API is called with the name 'c_sentiment'.

There are three types of APIs provided by bosonnlp.com.

This SDK supports APIs that even don't exists yet. It just need to know what kind of API it's handling by given the prefix. It's logic is not related to the API's name.

- Start with "m_": Multiple texts ones, like cluster API, it's meaningless to
    cluster single text.
- Start with "s_": Single ones, that limited to one text a time, and retrun one
    result, e.g. keywords API.
- Start with "c_": Common single ones, just like single ones, but can accept
    multiple texts, and retrun multiple result, those results are not related
    to each other, e.g. sentiment API.


Check http://docs.bosonnlp.com for API details.

Check [examples/usage.rb](https://github.com/alal/bosonnlp/blob/master/examples/usage.rb) for more examples.
